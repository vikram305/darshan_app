import 'dart:async';
import 'package:darshan_app/core/error/exception.dart';
import 'package:darshan_app/features/call/data/models/consumer_model.dart';
import 'package:darshan_app/features/call/data/models/producer_model.dart';
import 'package:darshan_app/features/call/data/models/room_model.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'call_remote_data_source.dart';

class SocketCallRemoteDataSourceImpl implements CallRemoteDataSource {
  final io.Socket socket;
  Device? _device;
  Transport? _sendTransport;
  Transport? _recvTransport;
  Completer<Transport>? _recvTransportCompleter;
  final Map<String, Completer<Consumer>> _consumerCompleters = {};
  String? _peerId;
  String? _roomId;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  SocketCallRemoteDataSourceImpl(this.socket) {
    _initSocketListeners();
  }

  @override
  Stream<Map<String, dynamic>> get onEvent => _eventController.stream;

  void _initSocketListeners() {
    socket.onConnect((_) {
      _eventController.add({'type': 'connected', 'socketId': socket.id});
    });

    socket.onDisconnect((_) {
      _eventController.add({'type': 'disconnected'});
    });

    // Mediasoup peer/producer events (Backend constants)
    final events = [
      'peer-joined',
      'peer-left',
      'new-producer',
      'producer-closed',
      'producer-paused',
      'producer-resumed',
    ];
    for (final event in events) {
      socket.on(event, (data) {
        _eventController.add({'type': event, 'data': data});
      });
    }
  }

  /// Helper for promising socket.emitWithAck
  Future<dynamic> _emitWithAck(String event, [dynamic data]) {
    if (!socket.connected) {
      socket.connect();
    }

    final completer = Completer<dynamic>();
    socket.emitWithAck(
      event,
      data,
      ack: (response) {
        if (response != null && response is Map && response['error'] != null) {
          final error = response['error'];
          String message;
          if (error is Map) {
            // Handle Zod format() or custom error objects
            message = error.toString();
          } else {
            message = error.toString();
          }
          print('🔴 Server Error: $message');
          completer.completeError(ServerException(message));
        } else {
          completer.complete(response);
        }
      },
    );

    // Fallback timeout to prevent infinite hangs
    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        final status = socket.connected ? 'Connected' : 'Disconnected';
        throw ServerException(
          'Socket timeout on event $event (Status: $status, ID: ${socket.id})',
        );
      },
    );
  }

  @override
  Future<RoomModel> createRoom(String displayName) async {
    try {
      final response = await _emitWithAck('create-room', {
        'displayName': displayName,
      });

      // Backend returns { roomId, deviceId, success } for create-room
      _roomId = response['roomId'];
      _peerId = response['deviceId'];

      return RoomModel(
        id: _roomId!,
        hostPeerId: _peerId!,
        peers: [],
        createdAt: DateTime.now(),
        isActive: true,
        myPeerId: _peerId,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create room: $e');
    }
  }

  @override
  Future<RoomModel> joinRoom(String roomId, String displayName) async {
    try {
      final response = await _emitWithAck('join-room', {
        'code': roomId,
        'peerName': displayName,
      });

      // Requesting capabilities separately if needed
      final capsResponse = await _emitWithAck('get-router-rtp-capabilities', {
        'roomId': roomId,
      });
      final routerRtpCapabilities = capsResponse['rtpCapabilities'];
      print('📦 Received Router RTP Capabilities');

      _device = Device();
      await _device!.load(
        routerRtpCapabilities: routerRtpCapabilities is Map
            ? RtpCapabilities.fromMap(
                routerRtpCapabilities as Map<String, dynamic>,
              )
            : routerRtpCapabilities,
      );
      print('✅ Mediasoup Device loaded');

      _roomId = roomId;
      _peerId = response['peer'] != null ? response['peer']['id'] : null;

      // Handle initial producers already in the room
      if (response['producers'] != null) {
        final List initialProducers = response['producers'];
        print('📋 Handling ${initialProducers.length} initial producers');
        for (var p in initialProducers) {
          // Send to event controller with a small delay to ensure repository is listening
          Future.delayed(const Duration(milliseconds: 500), () {
            _eventController.add({'type': 'new-producer', 'data': p});
          });
        }
      }

      return RoomModel.fromJson(response['room'] ?? {}, myPeerId: _peerId);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to join room: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String peerId) async {
    try {
      await _emitWithAck('leave-room', {'roomId': roomId, 'peerId': peerId});
      // Cleanup transports
      _sendTransport?.close();
      _recvTransport?.close();
      _sendTransport = null;
      _recvTransport = null;
      _device = null;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to leave room: $e');
    }
  }

  @override
  Future<ProducerModel> produce({
    required String roomId,
    required MediaKind kind,
    required MediaStreamTrack track,
    required MediaStream stream,
  }) async {
    print('🎙️ Starting produce for room: $roomId, kind: ${kind.name}');
    if (_device == null || !_device!.loaded) {
      throw TransportException('Mediasoup device not initialized');
    }

    try {
      if (_sendTransport == null) {
        print('🌐 Creating send transport...');
        final transportInfo = await _emitWithAck('create-transport', {
          'roomId': roomId,
          'peerId': _peerId,
          'direction': 'send',
        });

        final options = transportInfo['transportOptions'];
        print('📦 Received send transport options: $options');
        _sendTransport = _device!.createSendTransportFromMap(options);

        _sendTransport!.on('connect', (Map data) async {
          final Function callback = data['callback'];
          final Function? errback = data['errback'];
          print('🔗 Send transport connect event triggered');
          try {
            final payload = {
              'roomId': roomId,
              'peerId': _peerId,
              'transportId': _sendTransport!.id,
              'dtlsParameters': data['dtlsParameters'] is Map
                  ? data['dtlsParameters']
                  : data['dtlsParameters'].toMap(),
            };
            print('📡 Sending connect-transport: $payload');
            await _emitWithAck('connect-transport', payload);
            print('✅ Send transport connected on server');
            callback();
          } catch (e) {
            final msg = e is ServerException ? e.message : e.toString();
            print('❌ Error connecting send transport: $msg');
            if (errback != null) errback(e);
          }
        });

        _sendTransport!.on('connectionstatechange', (state) {
          print('🌐 Send Transport connection state changed to: $state');
        });

        _sendTransport!.on('produce', (Map data) async {
          final Function callback = data['callback'];
          final Function? errback = data['errback'];
          print(
            '📤 Send transport produce event triggered: kind=${data['kind']}',
          );
          try {
            final payload = {
              'roomId': roomId,
              'peerId': _peerId,
              'transportId': _sendTransport!.id,
              'kind': data['kind'],
              'rtpParameters': data['rtpParameters'] is Map
                  ? data['rtpParameters']
                  : data['rtpParameters'].toMap(),
              if (data['appData'] != null)
                'appData': Map<String, dynamic>.from(data['appData']),
            };
            print('📡 Sending produce: $payload');
            final response = await _emitWithAck('produce', payload);
            print('✅ Server producer created: ${response['id']}');
            callback(response['id']);
          } catch (e) {
            final msg = e is ServerException ? e.message : e.toString();
            print('❌ Error producing media: $msg');
            if (errback != null) errback(e);
          }
        });
      }

      final completer = Completer<Producer>();
      _sendTransport!.producerCallback = (Producer producer) {
        print('🎉 Producer created locally: ${producer.id}');
        if (!completer.isCompleted) {
          completer.complete(producer);
        }
      };

      print('🚀 Calling transport.produce...');
      // NOTE: Passing the original stream on mobile causes UnifiedPlan.send to crash or fail to extract the video track.
      // So we dynamically create a new wrapper stream containing only the requested track.
      final wrappedStream = await createLocalMediaStream('produce_${track.id}');
      await wrappedStream.addTrack(track);

      _sendTransport!.produce(
        track: track,
        stream: wrappedStream,
        source: kind == MediaKind.video ? 'webcam' : 'mic',
        appData: {'kind': kind.name},
      );

      final producer = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw ServerException(
          'Timed out waiting for local producer creation',
        ),
      );

      return ProducerModel(
        id: producer.id,
        kind: kind,
        isPaused: !track.enabled,
        isScreenShare: false,
      );
    } catch (e) {
      final message = e is ServerException ? e.message : e.toString();
      print('❌ Overall production failure: $message');
      throw ServerException('Failed to produce media: $message');
    }
  }

  @override
  Future<ConsumerModel> consume({
    required String roomId,
    required String producerId,
    required String peerId,
  }) async {
    print('👁️ Starting consume: producer=$producerId from peer=$peerId');
    if (_device == null || !_device!.loaded) {
      throw TransportException('Mediasoup device not initialized');
    }

    try {
      if (_recvTransport == null) {
        if (_recvTransportCompleter != null) {
          print('⏳ Waiting for recv transport creation in progress...');
          _recvTransport = await _recvTransportCompleter!.future;
        } else {
          _recvTransportCompleter = Completer<Transport>();
          print('🌐 Creating recv transport...');
          final transportInfo = await _emitWithAck('create-transport', {
            'roomId': roomId,
            'peerId': _peerId,
            'direction': 'recv',
          });

          final options = transportInfo['transportOptions'];
          print('📦 Received recv transport options: $options');
          // Log the first candidate for debugging
          if (options['iceCandidates'] != null &&
              options['iceCandidates'].isNotEmpty) {
            final candidate = options['iceCandidates'][0];
            print(
              '📍 Remote ICE Candidate: ${candidate['ip']}:${candidate['port']} (${candidate['protocol']})',
            );
          }

          final transport = _device!.createRecvTransportFromMap(options);

          transport.on('connect', (Map data) async {
            final Function callback = data['callback'];
            final Function? errback = data['errback'];
            print('🔗 Recv transport connect event triggered');
            try {
              final payload = {
                'roomId': roomId,
                'peerId': _peerId,
                'transportId': transport.id,
                'dtlsParameters': data['dtlsParameters'] is Map
                    ? data['dtlsParameters']
                    : data['dtlsParameters'].toMap(),
              };
              print('📡 Sending connect-transport (recv): $payload');
              await _emitWithAck('connect-transport', payload);
              print('✅ Recv transport connected on server');
              callback();
            } catch (e) {
              final msg = e is ServerException ? e.message : e.toString();
              print('❌ Error connecting recv transport: $msg');
              if (errback != null) errback(e);
            }
          });

          transport.consumerCallback = (Consumer consumer, [Function? accept]) {
            print('🎉 Consumer callback triggered for local ID: ${consumer.localId}, remote ID: ${consumer.id}');
            if (accept != null) {
              print('👌 Accepting consumer...');
              accept();
            }
            final completer = _consumerCompleters.remove(consumer.id);
            if (completer != null && !completer.isCompleted) {
              completer.complete(consumer);
            }
          };

          transport.on('connectionstatechange', (state) {
            print('🌐 Recv Transport connection state changed to: $state');
          });

          _recvTransport = transport;
          _recvTransportCompleter!.complete(transport);
          _recvTransportCompleter = null;
        }
      }

      final completer = Completer<Consumer>();

      final rtpCapabilities = _device!.rtpCapabilities;
      print('📥 Signaling consume to server...');
      final response = await _emitWithAck('consume', {
        'roomId': roomId,
        'peerId': _peerId,
        'producerId': producerId,
        'rtpCapabilities': rtpCapabilities is Map
            ? rtpCapabilities
            : rtpCapabilities.toMap(),
      });

      final options = response['consumerOptions'];
      final consumerId = options['id'];
      _consumerCompleters[consumerId] = completer;
      print('📦 Received consumer options: $options');

      print('🚀 Calling transport.consume locally for $consumerId...');
      _recvTransport!.consume(
        id: consumerId,
        producerId: options['producerId'],
        peerId: peerId,
        kind: RTCRtpMediaTypeExtension.fromString(options['kind']),
        rtpParameters: RtpParameters.fromMap(options['rtpParameters']),
      );

      final consumer = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          _consumerCompleters.remove(consumerId);
          throw ServerException('Timed out waiting for local consumer creation: $consumerId');
        },
      );

      // Explicitly enable the track
      print('📺 Consumer stream: tracks=${consumer.stream.getTracks().length}, trackId=${consumer.track.id}, kind=${consumer.track.kind}');
      consumer.track.enabled = true;

      print('⏯️ Signaling resume-consumer...');
      await _emitWithAck('resume-consumer', {
        'roomId': roomId,
        'peerId': _peerId,
        'consumerId': consumer.id,
      });
      print('✅ Consumer resumed successfully');

      return ConsumerModel(
        id: consumer.id,
        producerId: producerId,
        peerId: peerId,
        kind: options['kind'] == 'video' ? MediaKind.video : MediaKind.audio,
        isPaused: options['producerPaused'] ?? false,
        rtpParameters: options['rtpParameters'],
        stream: consumer.stream,
      );
    } catch (e) {
      final message = e is ServerException ? e.message : e.toString();
      print('❌ Overall consumption failure: $message');
      throw ServerException('Failed to consume media: $message');
    }
  }

  @override
  Future<void> toggleAudio({
    required String producerId,
    required bool pause,
  }) async {
    try {
      await _emitWithAck(pause ? 'pauseProducer' : 'resumeProducer', {
        'producerId': producerId,
      });
    } catch (e) {
      throw ServerException('Failed to toggle audio: $e');
    }
  }

  @override
  Future<void> toggleCamera({
    required String producerId,
    required bool pause,
  }) async {
    try {
      await _emitWithAck(pause ? 'pauseProducer' : 'resumeProducer', {
        'producerId': producerId,
      });
    } catch (e) {
      throw ServerException('Failed to toggle camera: $e');
    }
  }
}

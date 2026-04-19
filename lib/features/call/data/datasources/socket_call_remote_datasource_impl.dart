import 'dart:async';
import 'package:darshan_app/core/error/exception.dart';
import 'package:darshan_app/features/call/data/models/consumer_model.dart';
import 'package:darshan_app/features/call/data/models/producer_model.dart';
import 'package:darshan_app/features/call/data/models/room_model.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'call_remote_data_source.dart';

class SocketCallRemoteDataSourceImpl implements CallRemoteDataSource {
  final io.Socket socket;
  Device? _device;
  Transport? _sendTransport;
  Transport? _recvTransport;



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

    // Mediasoup peer/producer events
    final events = ['newPeer', 'peerClosed', 'newProducer', 'producerClosed', 'producerPaused', 'producerResumed'];
    for (final event in events) {
      socket.on(event, (data) {
        _eventController.add({'type': event, 'data': data});
      });
    }
  }


  /// Helper for promising socket.emitWithAck
  Future<dynamic> _emitWithAck(String event, [dynamic data]) {
    final completer = Completer<dynamic>();
    socket.emitWithAck(event, data, ack: (response) {
      if (response != null && response['error'] != null) {
        completer.completeError(ServerException(response['error']));
      } else {
        completer.complete(response);
      }
    });

    // Fallback timeout to prevent infinite hangs
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw ServerException('Socket timeout on event $event'),
    );
  }

  @override
  Future<RoomModel> createRoom(String displayName) async {
    try {
      final response = await _emitWithAck('createRoom', {'displayName': displayName});
      // A full implementation would map the response directly.
      // Below is an example parsing.
      return RoomModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create room: $e');
    }
  }

  @override
  Future<RoomModel> joinRoom(String roomId, String displayName) async {
    try {
      final response = await _emitWithAck('joinRoom', {
        'roomId': roomId,
        'displayName': displayName,
      });

      // Initialize Mediasoup Device after joining room and getting Router RTP Capabilities
      final routerRtpCapabilities = response['routerRtpCapabilities'];
      _device = Device();
      await _device!.load(routerRtpCapabilities: RtpCapabilities.fromMap(routerRtpCapabilities));

      return RoomModel.fromJson(response['room']);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to join room: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String peerId) async {
    try {
      await _emitWithAck('leaveRoom', {
        'roomId': roomId,
        'peerId': peerId,
      });
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
  }) async {
    if (_device == null || !_device!.loaded) {
      throw TransportException('Mediasoup device not initialized');
    }

    try {
      if (_sendTransport == null) {
        final transportInfo = await _emitWithAck('createWebRtcTransport', {
          'forceTcp': false,
          'producing': true,
          'consuming': false,
        });

        _sendTransport = _device!.createSendTransportFromMap(transportInfo);

        _sendTransport!.on('connect', (Map data) async {
          final Function callback = data['callback'];
          await _emitWithAck('connectWebRtcTransport', {
            'transportId': _sendTransport!.id,
            'dtlsParameters': data['dtlsParameters'].toMap(),
          });
          callback();
        });

        _sendTransport!.on('produce', (Map data) async {
          final Function callback = data['callback'];
          final response = await _emitWithAck('produce', {
            'transportId': _sendTransport!.id,
            'kind': data['kind'],
            'rtpParameters': data['rtpParameters'].toMap(),
            if (data['appData'] != null) 'appData': Map<String, dynamic>.from(data['appData']),
          });
          callback(response['id']);
        });
      }

      final completer = Completer<Producer>();
      _sendTransport!.producerCallback = (Producer producer) {
        completer.complete(producer);
      };

      final dummyStream = await createLocalMediaStream('dummy');
      dummyStream.addTrack(track);

      _sendTransport!.produce(
        track: track,
        stream: dummyStream,
        source: kind == MediaKind.video ? 'webcam' : 'mic',
        appData: {'kind': kind.name},
      );

      final producer = await completer.future;

      return ProducerModel(
        id: producer.id,
        kind: kind,
        isPaused: !track.enabled,
        isScreenShare: false,
      );
    } catch (e) {
      throw ServerException('Failed to produce media: $e');
    }
  }

  @override
  Future<ConsumerModel> consume({
    required String roomId,
    required String producerId,
    required String peerId,
  }) async {
    if (_device == null || !_device!.loaded) {
      throw TransportException('Mediasoup device not initialized');
    }

    try {
      if (_recvTransport == null) {
        final transportInfo = await _emitWithAck('createWebRtcTransport', {
          'forceTcp': false,
          'producing': false,
          'consuming': true,
        });

        _recvTransport = _device!.createRecvTransportFromMap(transportInfo);

        _recvTransport!.on('connect', (Map data) async {
          final Function callback = data['callback'];
          await _emitWithAck('connectWebRtcTransport', {
            'transportId': _recvTransport!.id,
            'dtlsParameters': data['dtlsParameters'].toMap(),
          });
          callback();
        });
      }

      final completer = Completer<Consumer>();
      _recvTransport!.consumerCallback = (Consumer consumer, [Function? accept]) {
        if (accept != null) accept();
        completer.complete(consumer);
      };

      final rtpCapabilities = _device!.rtpCapabilities;
      final response = await _emitWithAck('consume', {
        'producerId': producerId,
        'rtpCapabilities': rtpCapabilities.toMap(),
      });

      _recvTransport!.consume(
        id: response['id'],
        producerId: response['producerId'],
        peerId: peerId,
        kind: RTCRtpMediaTypeExtension.fromString(response['kind']),
        rtpParameters: RtpParameters.fromMap(response['rtpParameters']),
      );

      final consumer = await completer.future;

      return ConsumerModel(
        id: consumer.id,
        producerId: producerId,
        peerId: peerId,
        kind: response['kind'] == 'video' ? MediaKind.video : MediaKind.audio,
        isPaused: false,
        rtpParameters: response['rtpParameters'],
        stream: consumer.stream,
      );

    } catch (e) {
      throw ServerException('Failed to consume media: $e');
    }
  }


  @override
  Future<void> toggleAudio({required String producerId, required bool pause}) async {
    try {
      await _emitWithAck(pause ? 'pauseProducer' : 'resumeProducer', {'producerId': producerId});
    } catch (e) {
      throw ServerException('Failed to toggle audio: $e');
    }
  }

  @override
  Future<void> toggleCamera({required String producerId, required bool pause}) async {
    try {
      await _emitWithAck(pause ? 'pauseProducer' : 'resumeProducer', {'producerId': producerId});
    } catch (e) {
      throw ServerException('Failed to toggle camera: $e');
    }
  }
}

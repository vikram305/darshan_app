import 'dart:async';
import 'package:darshan_app/core/cubit/base_ui_cubit.dart';
import 'package:darshan_app/features/call/domain/entities/call_event.dart';
import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/peer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/repositories/call_repository.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/produce_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/consume_media_usecase.dart';
import 'call_ui_state.dart';

class CallUiCubit extends BaseUiCubit<RoomEntity, CallUiState> {
  final InitLocalMediaUsecase _initLocalMediaUsecase;
  final SwitchCameraUsecase _switchCameraUsecase;
  final ConsumeMediaUsecase _consumeMediaUsecase;
  final CallRepository _repository;
  StreamSubscription? _eventSubscription;

  CallUiCubit({
    required InitLocalMediaUsecase initLocalMediaUsecase,
    required SwitchCameraUsecase switchCameraUsecase,
    required ConsumeMediaUsecase consumeMediaUsecase,
    required ProduceMediaUsecase produceMediaUsecase,
    required CallRepository repository,
  }) : _initLocalMediaUsecase = initLocalMediaUsecase,
       _switchCameraUsecase = switchCameraUsecase,
       _consumeMediaUsecase = consumeMediaUsecase,
       _produceMediaUsecase = produceMediaUsecase,
       _repository = repository,
       super(const CallUiState()) {
    _initEventListener();
  }

  final ProduceMediaUsecase _produceMediaUsecase;

  void _initEventListener() {
    _eventSubscription = _repository.onCallEvent.listen((event) {
      if (event is PeerJoinedEvent) {
        peerJoined(event.peer);
      } else if (event is PeerLeftEvent) {
        peerLeft(event.peerId);
      } else if (event is ProducerJoinedEvent) {
        _handleNewProducer(event);
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }

  Future<void> _handleNewProducer(ProducerJoinedEvent event) async {
    if (state.viewData == null) return;

    // Check if we already have this consumer to avoid duplicates/race conditions
    final alreadyConsuming = state.viewData!.peers.any((p) => 
      p.consumers.any((c) => c.producerId == event.producerId));
    if (alreadyConsuming) {
      print('ℹ️ Already consuming producer ${event.producerId}, skipping.');
      return;
    }

    // Auto-consume remote producers
    final result = await _consumeMediaUsecase(
      ConsumeMediaParams(
        roomId: state.viewData!.id,
        producerId: event.producerId,
        peerId: event.peerId,
      ),
    );

    result.fold(
      (failure) => print('❌ Failed to consume producer ${event.producerId}: ${failure.message}'),
      (success) {
        final consumer = success.data;
        print('✅ Successfully consumed producer ${event.producerId}, kind: ${consumer.kind.name}');
        if (state.viewData == null) return;

        final updatedPeers = state.viewData!.peers.map((peer) {
          if (peer.id == event.peerId) {
            // Add or update consumer
            final consumers = List<ConsumerEntity>.from(peer.consumers)
              ..removeWhere((c) => c.id == consumer.id)
              ..add(consumer);
            return peer.copyWith(consumers: consumers);
          }
          return peer;
        }).toList();

        final updatedRoom = state.viewData!.copyWith(peers: updatedPeers);
        emit(state.copyWith(viewData: updatedRoom, originalData: updatedRoom));
      },
    );
  }

  /// Initializes local camera/mic stream
  Future<void> initLocalMedia({
    bool enableAudio = true,
    bool enableVideo = true,
  }) async {
    final result = await _initLocalMediaUsecase(
      InitLocalMediaParams(enableAudio: enableAudio, enableVideo: enableVideo),
    );

    result.fold((failure) => null, (success) async {
      emit(state.copyWith(localMedia: success.data));
      // Once local media is ready, publish it to the room
      await publishLocalMedia();
    });
  }

  /// Publishes local tracks to the server
  Future<void> publishLocalMedia() async {
    final localStream = state.localMedia?.localStream;
    final roomId = state.viewData?.id;
    if (localStream == null || roomId == null) return;

    for (final track in localStream.getVideoTracks()) {
      final result = await _produceMediaUsecase(
        ProduceMediaParams(
          roomId: roomId, 
          kind: MediaKind.video, 
          track: track,
          stream: localStream,
        ),
      );
      result.fold(
        (failure) => print('❌ Failed to produce video: ${failure.message}'),
        (success) => print('✅ Video track produced successfully'),
      );
    }

    for (final track in localStream.getAudioTracks()) {
      final result = await _produceMediaUsecase(
        ProduceMediaParams(
          roomId: roomId, 
          kind: MediaKind.audio, 
          track: track,
          stream: localStream,
        ),
      );
      result.fold(
        (failure) => print('❌ Failed to produce audio: ${failure.message}'),
        (success) => print('✅ Audio track produced successfully'),
      );
    }
  }

  /// Toggles local mic state
  void toggleMic() {
    if (state.localMedia == null) return;
    final updated = state.localMedia!.copyWith(
      isMicEnabled: !state.localMedia!.isMicEnabled,
    );
    emit(state.copyWith(localMedia: updated));
  }

  /// Toggles local camera state
  void toggleCamera() {
    if (state.localMedia == null) return;
    final updated = state.localMedia!.copyWith(
      isCameraEnabled: !state.localMedia!.isCameraEnabled,
    );
    emit(state.copyWith(localMedia: updated));
  }

  /// Flips between front and rear camera
  Future<void> switchCamera() async {
    final result = await _switchCameraUsecase(const SwitchCameraParams());
    result.fold(
      (failure) => null,
      (success) => emit(state.copyWith(localMedia: success.data)),
    );
  }

  /// Called when a remote peer joins
  void peerJoined(PeerEntity peer) {
    if (state.viewData == null) return;

    // Deduplicate
    if (state.viewData!.peers.any((p) => p.id == peer.id)) return;

    final updatedPeers = List<PeerEntity>.from(state.viewData!.peers)
      ..add(peer);
    final updatedRoom = state.viewData!.copyWith(peers: updatedPeers);

    emit(state.copyWith(viewData: updatedRoom, originalData: updatedRoom));
  }

  /// Called when a remote peer leaves
  void peerLeft(String peerId) {
    if (state.viewData == null) return;

    final updatedPeers = state.viewData!.peers
        .where((p) => p.id != peerId)
        .toList();
    final updatedRoom = state.viewData!.copyWith(peers: updatedPeers);

    emit(state.copyWith(viewData: updatedRoom, originalData: updatedRoom));
  }

  /// Update transport readiness
  void setTransportReady({required bool isSend, required bool ready}) {
    if (isSend) {
      emit(state.copyWith(isSendingTransportReady: ready));
    } else {
      emit(state.copyWith(isReceivingTransportReady: ready));
    }
  }

  /// Signals leave to server and resets UI state
  Future<void> leaveRoom() async {
    final roomId = state.viewData?.id;
    final peerId = state.viewData?.myPeerId;

    if (roomId != null && peerId != null) {
      await _repository.leaveRoom(roomId: roomId, peerId: peerId);
    }

    reset();
  }

  /// Resets the cubit to initial state
  void reset() {
    emit(const CallUiState());
  }

  /// Initializes state from join/create result
  void initializeData(RoomEntity room) {
    emit(
      state.copyWith(
        viewData: room,
        originalData: room,
        myPeerId: room.myPeerId,
      ),
    );
  }
}

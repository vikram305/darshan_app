import 'package:darshan_app/core/cubit/base_ui_state.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';

class CallUiState extends BaseUiState<RoomEntity> {
  final LocalMediaEntity? localMedia;
  final bool isSendingTransportReady;
  final bool isReceivingTransportReady;

  const CallUiState({
    super.originalData,
    super.viewData,
    this.localMedia,
    this.isSendingTransportReady = false,
    this.isReceivingTransportReady = false,
  });

  @override
  CallUiState copyWith({
    RoomEntity? originalData,
    RoomEntity? viewData,
    LocalMediaEntity? localMedia,
    bool? isSendingTransportReady,
    bool? isReceivingTransportReady,
  }) {
    return CallUiState(
      originalData: originalData ?? this.originalData,
      viewData: viewData ?? this.viewData,
      localMedia: localMedia ?? this.localMedia,
      isSendingTransportReady: isSendingTransportReady ?? this.isSendingTransportReady,
      isReceivingTransportReady: isReceivingTransportReady ?? this.isReceivingTransportReady,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        localMedia,
        isSendingTransportReady,
        isReceivingTransportReady,
      ];
}

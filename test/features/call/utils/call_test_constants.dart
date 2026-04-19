// ignore_for_file: avoid_redundant_argument_values

import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/peer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/transport_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/consume_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/leave_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/params/room_peer_params.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_audio_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_camera_usecase.dart';
import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// ---------------------------------------------------------------------------
// IDs & Strings
// ---------------------------------------------------------------------------

const tRoomId = 'room-uuid-abc';
const tHostPeerId = 'peer-host-001';
const tPeerId = 'peer-guest-002';
const tProducerId = 'producer-video-001';
const tConsumerId = 'consumer-video-002';
const tRemoteProducerId = 'producer-remote-001';
const tDisplayName = 'Alice';
const tGuestDisplayName = 'Bob';
const tErrorMessage = 'Something went wrong.';
const tRoomNotFoundMessage = 'Room not found.';
const tRoomFullMessage = 'Room is full.';
const tMediaPermissionMessage = 'Camera/mic permission denied.';
const tTransportMessage = 'Send transport not initialized.';
const tNoInternetMessage = 'No internet connection.';

// ---------------------------------------------------------------------------
// RTP / ICE raw data
// ---------------------------------------------------------------------------

final tRtpParameters = <String, dynamic>{
  'codecs': [
    {'mimeType': 'video/VP8', 'payloadType': 96, 'clockRate': 90000}
  ]
};

final tIceParameters = <String, dynamic>{'usernameFragment': 'frag', 'password': 'pass'};
final tIceCandidates = <Map<String, dynamic>>[
  {'foundation': '1', 'priority': 100, 'ip': '192.168.1.1', 'port': 5000}
];
final tDtlsParameters = <String, dynamic>{
  'fingerprints': [
    {'algorithm': 'sha-256', 'value': 'AA:BB:CC'}
  ]
};

// ---------------------------------------------------------------------------
// Entities
// ---------------------------------------------------------------------------

const tAudioProducer = ProducerEntity(
  id: tProducerId,
  kind: MediaKind.audio,
  isPaused: false,
  isScreenShare: false,
);

const tVideoProducer = ProducerEntity(
  id: 'producer-video-001',
  kind: MediaKind.video,
  isPaused: false,
  isScreenShare: false,
);

final tConsumer = ConsumerEntity(
  id: tConsumerId,
  producerId: tRemoteProducerId,
  peerId: tPeerId,
  kind: MediaKind.video,
  isPaused: false,
  rtpParameters: tRtpParameters,
);

const tHostPeer = PeerEntity(
  id: tHostPeerId,
  displayName: tDisplayName,
  producers: [tAudioProducer, tVideoProducer],
  consumers: [],
  isAudioMuted: false,
  isCameraOff: false,
  isScreenSharing: false,
);

const tGuestPeer = PeerEntity(
  id: tPeerId,
  displayName: tGuestDisplayName,
  producers: [],
  consumers: [],
  isAudioMuted: false,
  isCameraOff: false,
  isScreenSharing: false,
);

final tRoom = RoomEntity(
  id: tRoomId,
  hostPeerId: tHostPeerId,
  peers: const [tHostPeer],
  createdAt: DateTime(2026, 4, 14, 10, 0, 0),
  isActive: true,
);

final tRoomWithGuest = RoomEntity(
  id: tRoomId,
  hostPeerId: tHostPeerId,
  peers: const [tHostPeer, tGuestPeer],
  createdAt: DateTime(2026, 4, 14, 10, 0, 0),
  isActive: true,
);

final tRoomEmpty = RoomEntity(
  id: tRoomId,
  hostPeerId: tHostPeerId,
  peers: const [],
  createdAt: DateTime(2026, 4, 14, 10, 0, 0),
  isActive: true,
);

final tTransport = TransportEntity(
  id: 'transport-001',
  iceParameters: tIceParameters,
  iceCandidates: tIceCandidates,
  dtlsParameters: tDtlsParameters,
  sctpParameters: null,
);

final tLocalMedia = LocalMediaEntity(
  localStream: null, // MediaStream cannot be constructed without a native context in unit tests
  isMicEnabled: true,
  isCameraEnabled: true,
  isFrontCamera: true,
  availableDevices: const [],
);

final tLocalMediaSwitched = LocalMediaEntity(
  localStream: null,
  isMicEnabled: true,
  isCameraEnabled: true,
  isFrontCamera: false, // flipped
  availableDevices: const [],
);

// ---------------------------------------------------------------------------
// Success wrappers
// ---------------------------------------------------------------------------

final tSuccessRoom = Success<RoomEntity>(tRoom);
final tSuccessRoomWithGuest = Success<RoomEntity>(tRoomWithGuest);
final tSuccessVoid = Success<void>(null);
final tSuccessProducer = Success<ProducerEntity>(tVideoProducer);
final tSuccessConsumer = Success<ConsumerEntity>(tConsumer);
final tSuccessLocalMedia = Success<LocalMediaEntity>(tLocalMedia);
final tSuccessLocalMediaSwitched = Success<LocalMediaEntity>(tLocalMediaSwitched);

// ---------------------------------------------------------------------------
// Failures
// ---------------------------------------------------------------------------

const tServerFailure = ServerFailure(tErrorMessage);
const tInternetFailure = InternetFailure(tNoInternetMessage);
const tRoomNotFoundFailure = RoomNotFoundFailure(tRoomNotFoundMessage);
const tRoomFullFailure = RoomFullFailure(tRoomFullMessage);
const tMediaPermissionFailure = MediaPermissionFailure(tMediaPermissionMessage);
const tTransportFailure = TransportFailure(tTransportMessage);
const tBadFilterFailure = BadFilterFailure('Invalid filter type');

// ---------------------------------------------------------------------------
// Use-case Params
// ---------------------------------------------------------------------------

const tCreateRoomParams = CreateRoomParams(displayName: tDisplayName);
const tJoinRoomParams = JoinRoomParams(roomId: tRoomId, displayName: tGuestDisplayName);
const tJoinRoomParamsEmptyId = JoinRoomParams(roomId: '', displayName: tGuestDisplayName);
const tLeaveRoomParams = RoomPeerParams(roomId: tRoomId, peerId: tHostPeerId);
const tToggleAudioParamsPause = ToggleAudioParams(producerId: tProducerId, pause: true);
const tToggleCameraParamsPause = ToggleCameraParams(producerId: tProducerId, pause: true);
const tSwitchCameraParams = SwitchCameraParams();
const tInitMediaParams = InitLocalMediaParams(enableAudio: true, enableVideo: true);
const tInitMediaParamsAudioOnly = InitLocalMediaParams(enableAudio: true, enableVideo: false);
const tInitMediaParamsBothOff = InitLocalMediaParams(enableAudio: false, enableVideo: false);

// ---------------------------------------------------------------------------
// JSON Maps (Data Layer)
// ---------------------------------------------------------------------------

final tProducerJson = {
  'id': tProducerId,
  'kind': 'audio',
  'isPaused': false,
  'isScreenShare': false,
};

final tConsumerJson = {
  'id': tConsumerId,
  'producerId': tRemoteProducerId,
  'peerId': tPeerId,
  'kind': 'video',
  'isPaused': false,
  'rtpParameters': tRtpParameters,
};

final tPeerJson = {
  'id': tHostPeerId,
  'displayName': tDisplayName,
  'producers': [tProducerJson],
  'consumers': [],
  'isAudioMuted': false,
  'isCameraOff': false,
  'isScreenSharing': false,
};

final tRoomJson = {
  'id': tRoomId,
  'hostPeerId': tHostPeerId,
  'peers': [tPeerJson],
  'createdAt': '2026-04-14T10:00:00.000',
  'isActive': true,
};

final tTransportJson = {
  'id': 'transport-001',
  'iceParameters': tIceParameters,
  'iceCandidates': tIceCandidates,
  'dtlsParameters': tDtlsParameters,
  'sctpParameters': null,
};


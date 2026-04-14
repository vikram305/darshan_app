# Call Feature — Senior Architect Outline
> Darshan App · Clean Architecture + DDD + BLoC
> Based on `ARCHITECTURE_PROMPT.md` patterns

---

## 1. Domain Entities

All entities: `extends Equatable`, `const` constructor, **zero** framework imports.

---

### 1.1 `RoomEntity`
**Scope:** Represents the active Mediasoup room/session that a user creates or joins.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Unique room identifier (UUID) |
| `hostPeerId` | `String` | The peer who created the room |
| `peers` | `List<PeerEntity>` | All current active peers |
| `createdAt` | `DateTime` | Server timestamp of room creation |
| `isActive` | `bool` | Whether the room is still live |

---

### 1.2 `PeerEntity`
**Scope:** Represents a single participant inside a room. Each peer may hold multiple media tracks.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Socket-assigned peer ID |
| `displayName` | `String` | Human-readable name |
| `producers` | `List<ProducerEntity>` | Media tracks this peer is sending |
| `consumers` | `List<ConsumerEntity>` | Media tracks this peer is consuming |
| `isAudioMuted` | `bool` | Local or remote mute state |
| `isCameraOff` | `bool` | Local or remote camera state |
| `isScreenSharing` | `bool` | Whether peer is screen-sharing |

---

### 1.3 `ProducerEntity`
**Scope:** Represents a single outbound media track (microphone or camera) belonging to the local peer.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Mediasoup producer ID |
| `kind` | `MediaKind` (enum) | `audio` or `video` |
| `isPaused` | `bool` | Muted/paused without closing |
| `isScreenShare` | `bool` | Differentiates camera vs screen |

> **`MediaKind`** enum: `audio`, `video`

---

### 1.4 `ConsumerEntity`
**Scope:** Represents an inbound media track that the local peer receives from a remote producer.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Mediasoup consumer ID |
| `producerId` | `String` | Remote producer this is linked to |
| `peerId` | `String` | The remote peer being consumed |
| `kind` | `MediaKind` | `audio` or `video` |
| `isPaused` | `bool` | |
| `rtpParameters` | `Map<String, dynamic>` | Raw RTP params from server; passed to Mediasoup Device |

---

### 1.5 `TransportEntity`
**Scope:** Wraps the Mediasoup WebRTC transport parameters returned by the server. Used to create Send and Receive transports on the device.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Mediasoup transport ID |
| `iceParameters` | `Map<String, dynamic>` | ICE credentials |
| `iceCandidates` | `List<Map<String, dynamic>>` | STUN/TURN candidates |
| `dtlsParameters` | `Map<String, dynamic>` | DTLS fingerprint |
| `sctpParameters` | `Map<String, dynamic>?` | Optional for data channels |

---

### 1.6 `LocalMediaEntity`
**Scope:** Represents the local device's raw camera/mic stream state before it is sent to the server. Lives in the UI layer's "memory" via `BaseUiCubit`.

| Field | Type | Notes |
|---|---|---|
| `localStream` | `MediaStream?` | From `flutter_webrtc` |
| `isMicEnabled` | `bool` | |
| `isCameraEnabled` | `bool` | |
| `isFrontCamera` | `bool` | For switch-camera toggling |
| `availableDevices` | `List<MediaDeviceInfo>` | Enumerated mic/camera devices |

---

## 2. Use Cases

All use cases: `extends UseCase<ReturnType, ParamType>`, single `call()`, returns `Future<Either<Failure, Success<T>>>`.

---

### 2.1 `CreateRoomUsecase`
- **Input Params:** `CreateRoomParams(displayName: String)`
- **Returns:** `Success<RoomEntity>` — the created room with the host peer pre-populated.
- **Failures:** `ServerFailure`, `InternetFailure`

---

### 2.2 `JoinRoomUsecase`
- **Input Params:** `JoinRoomParams(roomId: String, displayName: String)`
- **Returns:** `Success<RoomEntity>` — the full room including all existing peers at join-time.
- **Failures:** `ServerFailure` (e.g. room not found, room full), `InternetFailure`

---

### 2.3 `LeaveRoomUsecase`
- **Input Params:** `LeaveRoomParams(roomId: String, peerId: String)`
- **Returns:** `Success<void>` — signals clean disconnect from server.
- **Failures:** `ServerFailure`, `InternetFailure`
- **Edge note:** Must be called even if no media was produced (joined but never enabled camera).

---

### 2.4 `ProduceMediaUsecase`
- **Input Params:** `ProduceMediaParams(roomId: String, kind: MediaKind, track: MediaStreamTrack)`
- **Returns:** `Success<ProducerEntity>` — the newly created producer entity with its assigned ID.
- **Failures:** `ServerFailure` (transport not ready), `InternetFailure`, `MediaPermissionFailure` (new custom failure)

---

### 2.5 `ConsumeMediaUsecase`
- **Input Params:** `ConsumeMediaParams(roomId: String, producerId: String, peerId: String)`
- **Returns:** `Success<ConsumerEntity>` — with RTP params populated, ready to render in `RTCVideoView`.
- **Failures:** `ServerFailure`, `InternetFailure`

---

### 2.6 `ToggleAudioUsecase`
- **Input Params:** `ToggleAudioParams(producerId: String, pause: bool)`
- **Returns:** `Success<void>`
- **Failures:** `ServerFailure`
- **Note:** "Pause" vs "close" distinction — pause keeps the producer alive on the server; close tears it down. This use case only pauses/resumes.

---

### 2.7 `ToggleCameraUsecase`
- **Input Params:** `ToggleCameraParams(producerId: String, pause: bool)`
- **Returns:** `Success<void>`
- **Failures:** `ServerFailure`

---

### 2.8 `SwitchCameraUsecase`
- **Input Params:** `SwitchCameraParams()` — no server call, device-only operation.
- **Returns:** `Success<LocalMediaEntity>` — updated stream after camera flip.
- **Failures:** `MediaPermissionFailure` (e.g., no front camera on device)
- **Note:** This is a local device operation that does NOT hit the socket. The repository delegates to `WebRTCDatasource` only.

---

### 2.9 `InitLocalMediaUsecase`
- **Input Params:** `InitLocalMediaParams(enableAudio: bool, enableVideo: bool)`
- **Returns:** `Success<LocalMediaEntity>` — contains the live `MediaStream` and device list.
- **Failures:** `MediaPermissionFailure` (user denied permission), `ServerFailure` (device enumeration error)

---

### ⚙️ Shared Params (placed in `usecases/params/`)
Since `roomId` + `peerId` appear in multiple use cases, extract:
- `RoomPeerParams(roomId: String, peerId: String)` — used by `LeaveRoom`, `ConsumeMedia`.

---

### ⚙️ Custom Failure Types (additions to `core/error/failure.dart`)
| Failure | When |
|---|---|
| `RoomNotFoundFailure` | Server signals the room ID doesn't exist |
| `RoomFullFailure` | Server rejects join because room has hit peer limit |
| `MediaPermissionFailure` | OS-level mic/camera permission denied |
| `TransportFailure` | WebRTC ICE/DTLS negotiation failure |

---

## 3. Test Scenarios

### Notation key
- ✅ Happy Path
- ❌ Edge / Failure Case

---

### 3.1 Data Layer — `SocketDatasource`

| # | Scenario | Type |
|---|---|---|
| 1 | Connects to `http://localhost:5000` successfully and emits `connected` state | ✅ |
| 2 | `createRoom` emits correct socket event and returns `RoomDto` on `ack` | ✅ |
| 3 | `joinRoom` emits correct event and returns full peer list in `RoomDto` | ✅ |
| 4 | `new-peer` event from server correctly adds `PeerDto` to stream | ✅ |
| 5 | `new-producer` event triggers consumer creation correctly | ✅ |
| 6 | `producer-closed` event removes the correct producer from the peer | ✅ |
| 7 | Socket connection times out → throws `ServerException` with timeout message | ❌ |
| 8 | Server returns `ack` with `success: false` → throws `ServerException` with server message | ❌ |
| 9 | Socket disconnects mid-call → emits disconnect event on the stream | ❌ |
| 10 | `joinRoom` with non-existent room ID → server ack returns error → `ServerException` thrown | ❌ |
| 11 | `joinRoom` with full room → server ack returns room-full error → `ServerException` thrown | ❌ |
| 12 | Duplicate socket event `new-peer` for already-known peer ID → de-duplicated / ignored | ❌ |

---

### 3.2 Data Layer — `WebRTCDatasource`

| # | Scenario | Type |
|---|---|---|
| 1 | `getUserMedia` returns a valid `MediaStream` with both audio and video tracks | ✅ |
| 2 | `getUserMedia` with `enableVideo: false` returns stream with audio only | ✅ |
| 3 | `enumerateDevices` returns a populated list of `MediaDeviceInfo` | ✅ |
| 4 | `switchCamera` flips from front to rear, returns new `MediaStream` | ✅ |
| 5 | User denies mic/camera permission → `getUserMedia` throws `ServerException` | ❌ |
| 6 | Device has no front camera → `switchCamera` rethrows `ServerException` | ❌ |
| 7 | `enumerateDevices` returns empty list on emulator/simulator | ❌ |

---

### 3.3 Repository — `CallRepositoryImpl`

| # | Scenario | Type |
|---|---|---|
| 1 | `createRoom()` online → datasource succeeds → returns `Right(Success<RoomEntity>)` | ✅ |
| 2 | `joinRoom()` online → datasource succeeds → maps DTO to entity with all peers | ✅ |
| 3 | `produce()` online → returns `Right(Success<ProducerEntity>)` | ✅ |
| 4 | `consume()` online → returns `Right(Success<ConsumerEntity>)` with RTP params | ✅ |
| 5 | Device offline → any call → returns `Left(InternetFailure())` without calling datasource | ❌ |
| 6 | `createRoom()` datasource throws `ServerException` → returns `Left(ServerFailure(...))` | ❌ |
| 7 | `joinRoom()` with invalid room ID → `ServerException` → `Left(RoomNotFoundFailure())` | ❌ |
| 8 | `joinRoom()` room is full → `ServerException` → `Left(RoomFullFailure())` | ❌ |
| 9 | `leaveRoom()` datasource throws mid-cleanup → still returns `Left(ServerFailure)`, no unhandled exception | ❌ |
| 10 | `initLocalMedia()` with permission denied → `Left(MediaPermissionFailure())` | ❌ |
| 11 | `produce()` when send transport not initialized → `Left(TransportFailure())` | ❌ |
| 12 | `consume()` with malformed RTP params from server → `Left(ServerFailure(...))` | ❌ |

---

### 3.4 Use Cases

| # | Scenario | Type |
|---|---|---|
| 1 | `CreateRoomUsecase` delegates `call()` to repository and returns its `Either` unchanged | ✅ |
| 2 | `JoinRoomUsecase` passes `roomId` and `displayName` correctly to repository | ✅ |
| 3 | `ToggleAudioUsecase(pause: true)` calls repository with correct `producerId` | ✅ |
| 4 | `SwitchCameraUsecase` only touches `WebRTCDatasource`, never touches socket | ✅ |
| 5 | `LeaveRoomUsecase` called when online → success | ✅ |
| 6 | `ProduceMediaUsecase` with `kind: MediaKind.video` passes video track correctly | ✅ |
| 7 | `JoinRoomUsecase` called with empty `roomId` → delegates to repo which returns `Left(ServerFailure)` | ❌ |
| 8 | `ProduceMediaUsecase` while offline → repo returns `Left(InternetFailure)` → use case passes it through | ❌ |
| 9 | `ConsumeMediaUsecase` for own `peerId` → call should be rejected logically before reaching repo | ❌ |
| 10 | `InitLocalMediaUsecase` with `enableAudio: false, enableVideo: false` → both disabled, should return failure or valid muted stream | ❌ |

---

### 3.5 State Management — `CallFetcherBloc`

| # | Scenario | Type |
|---|---|---|
| 1 | `FetchData(JoinRoomFilter(...))` emits `[loading, success]` with `RoomEntity` | ✅ |
| 2 | `FetchData(CreateRoomFilter(...))` emits `[loading, success]` with new `RoomEntity` | ✅ |
| 3 | `FetchData(JoinRoomFilter(...))` → repository fails → emits `[loading, failure(message)]` | ❌ |
| 4 | Unknown filter type passed → emits `[loading, failure(BadFilterFailure)]` | ❌ |
| 5 | Two `FetchData` events dispatched rapidly → second cancels first (if cancellable) | ❌ |
| 6 | `InternetFailure` → emits `FetcherFailure` with the no-internet string constant | ❌ |

---

### 3.6 State Management — `CallUiCubit`

| # | Scenario | Type |
|---|---|---|
| 1 | `initializeData(room)` populates `originalData` and `viewData` with room | ✅ |
| 2 | `peerJoined(peer)` appends peer to list, `viewData` reflects the new count | ✅ |
| 3 | `peerLeft(peerId)` removes correct peer from both `originalData` and `viewData` | ✅ |
| 4 | `toggleMic()` flips `LocalMediaEntity.isMicEnabled` in state | ✅ |
| 5 | `toggleCamera()` flips `LocalMediaEntity.isCameraEnabled` in state | ✅ |
| 6 | `switchCamera()` updates `isFrontCamera` flag | ✅ |
| 7 | `producerClosed(producerId)` removes producer from correct peer's list | ✅ |
| 8 | `peerJoined` called with same peer ID twice → state deduplicates (no duplicates in list) | ❌ |
| 9 | `peerLeft` called for non-existent peer ID → state unchanged, no crash | ❌ |
| 10 | `initializeData` called with room that has 0 peers → state is valid empty list | ❌ |
| 11 | `producerClosed` with producerId that doesn't exist in any peer → state unchanged | ❌ |

---

### 3.7 UI Layer — Screen Tests (Widget / Integration)

| # | Scenario | Screen | Type |
|---|---|---|---|
| 1 | `HomeScreen` renders "Create Room" and "Join Room" buttons | Home | ✅ |
| 2 | Tapping "Create Room" navigates to `WaitingScreen` with room code displayed | Home → Waiting | ✅ |
| 3 | `WaitingScreen` shows shareable room code and a copy-to-clipboard action | Waiting | ✅ |
| 4 | Entering valid room code and tapping "Join" in `HomeScreen` triggers `JoinRoomUsecase` | Home | ✅ |
| 5 | `CallScreen` renders `RTCVideoView` for each peer in `CallActive` state | Call | ✅ |
| 6 | Mic button tapped → `ToggleAudioUsecase` called, icon updates to muted | Call | ✅ |
| 7 | Camera button tapped → `ToggleCameraUsecase` called, local video view shows black frame | Call | ✅ |
| 8 | Switch camera tapped → local stream updates with flipped front/back camera | Call | ✅ |
| 9 | Leave button tapped → `LeaveRoomUsecase` called → nav pops to `HomeScreen` | Call | ✅ |
| 10 | `HomeScreen` "Join" tapped with empty room code → shows inline validation error, no navigation | Home | ❌ |
| 11 | `CallBloc` emits `CallError` → `CallScreen` shows an error snackbar/overlay with message | Call | ❌ |
| 12 | Remote peer leaves mid-call → their `RTCVideoView` is removed from the grid | Call | ❌ |
| 13 | All remote peers leave → grid shows only local video, no empty grid crash | Call | ❌ |
| 14 | App goes to background mid-call → camera/mic producers are paused, not closed | Call | ❌ |
| 15 | App returns to foreground → producers are resumed, stream continues | Call | ❌ |
| 16 | Network drops mid-call → `CallBloc` transitions to `CallError` with reconnect message | Call | ❌ |
| 17 | `WaitingScreen` displayed for >30s without a peer joining → optional timeout/hint shown | Waiting | ❌ |

---

> **Total test scenarios: ~60**
> Coverage targets suggested: Domain + Data = 100%, BLoC = 100%, UI = critical flows only.

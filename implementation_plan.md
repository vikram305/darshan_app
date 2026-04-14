# Feature-Wise Implementation Plan

Based on the feedback, we will use `mediasoup_client_flutter` to guarantee FaceTime-like quality and stability for our SFU architecture. We will also stick to the defined Material 3 theme (`AppTheme`).

Here is the sequential, feature-by-feature execution plan.

## Proposed Execution Steps

### Feature Step 1: Base Configurations & Models
**Goal:** Setup network sockets, WebRTC dependencies, and define Data Transfer Objects (DTOs) for rooms/peers.
- **Add Dependencies:** Add `mediasoup_client_flutter` to `pubspec.yaml` and install it.
- **DTOs:** Create `RoomDto` and `PeerDto` in `lib/features/call/data/models/`.
- **Entities:** Create `MediaStreamEntity` and abstract models in `lib/features/call/domain/entities/`.
- **Socket Environment:** Ensure `http://localhost:5000` is defined and read from `.env`.

### Feature Step 2: Datasources (Socket & WebRTC)
**Goal:** Build the low-level communication classes.
- **SocketDatasource:** Implements connection to the backend Mediasoup socket, listening for `new-peer`, `new-producer`, `producer-closed` events.
- **WebRTCDatasource:** Handles camera/microphone initialization, device enumeration using `flutter_webrtc`.
- **Mediasoup Client Init:** Setting up the internal Mediasoup `Device` and creating Send/Receive transports linked to the signaling Socket.

### Feature Step 3: Domain & Repositories
**Goal:** Bridge data and UI with solid use cases.
- **CallRepository:** Implement `createRoom()`, `joinRoom()`, `produce()`, `consume()`. It acts as the orchestrator.
- **Usecases:** Build robust classes `CreateRoomUsecase`, `JoinRoomUsecase`, `ToggleMediaUsecase` that the BLoC will call.

### Feature Step 4: State Management (Call BLoC)
**Goal:** Manage active peers and track mapping for the UI.
- **CallBloc:** Will manage states such as `CallInitial`, `CallConnecting`, `CallActive` (with list of peers and tracks), and `CallError`.
- **Registration:** Inject everything into `injection_container.dart` via `get_it`.

### Feature Step 5: Core UI Implementation
**Goal:** Build out the screens applying `AppTheme`.
- **HomeScreen:** Simple landing page to create or join a room.
- **WaitingScreen:** For hosts sending invites/codes.
- **CallScreen:** Group video grid using `flutter_webrtc`'s `RTCVideoView`. 
- **Controls:** Add mic, camera, switch camera, and leave actions.

## User Action Required

> [!IMPORTANT]  
> Are you ready to approve this serialized plan? If so, I will begin right away with **Feature Step 1 (Base Configurations & Models)**.

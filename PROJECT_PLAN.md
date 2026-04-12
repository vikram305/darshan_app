# Darshan - Project Plan

> **Mission:** Build an open-source, FaceTime-quality video calling platform with Flutter + Mediasoup

## 📋 Table of Contents
- [Product Vision](#product-vision)
- [MVP Scope](#mvp-scope)
- [Technology Stack](#technology-stack)
- [Timeline Overview](#timeline-overview)
- [Milestones](#milestones)
- [Success Metrics](#success-metrics)
- [Risk Management](#risk-management)

---

## 🎯 Product Vision

### What We're Building
A production-ready, self-hostable video calling platform that demonstrates:
- WebRTC/Mediasoup expertise
- Flutter mobile development
- Clean architecture principles
- TypeScript + Dart best practices
- Real-time system design
- Cross-platform capabilities

### Target Audience
1. **Primary:** Software engineers (reference implementation)
2. **Secondary:** Privacy-conscious users (self-hosting)
3. **Tertiary:** Companies (white-label solution)

### Differentiation
- ✅ FaceTime-quality audio/video processing
- ✅ Native mobile experience (Flutter)
- ✅ Open source with excellent documentation
- ✅ Self-hostable (privacy-first)
- ✅ Clean, tested, production-ready code
- ✅ Cross-platform (iOS + Android from single codebase)

---

## 📦 MVP Scope

### ✅ In Scope (MVP)
- [x] **Backend:** Mediasoup SFU server
- [x] **Flutter App:** Native mobile app (iOS + Android)
- [x] **React Web (Optional):** Testing client
- [x] Create video call room
- [x] Join room with 6-digit code
- [x] 1:1 video calls
- [x] Group calls up to 10 people (SFU)
- [x] Audio/video controls (mute/camera toggle)
- [x] Self-hosting deployment (Docker)
- [x] One-click deploy to DigitalOcean
- [x] Demo server with limits
- [x] Comprehensive documentation

### ❌ Out of Scope (Post-MVP)
- Screen sharing
- Text chat
- Recording
- Virtual backgrounds
- User authentication
- Room persistence
- Advanced audio processing (voice isolation - later)
- Background blur (later)
- Analytics dashboard

---

## 🛠 Technology Stack

### Backend
```
Language: TypeScript
Runtime: Node.js 18+
Framework: Express
WebRTC SFU: Mediasoup 3.14+
Signaling: Socket.io
Testing: Jest + Supertest
Database: In-memory (MVP) → PostgreSQL (later)
```

### Flutter App (Primary Frontend)
```
Language: Dart
Framework: Flutter 3.16+
State Management: BLoC (flutter_bloc)
WebRTC: flutter_webrtc
Signaling: socket_io_client
Architecture: Clean Architecture (feature-first)
Testing: flutter_test + mockito
Platforms: iOS 12+ and Android 8+
```

### React Web Client (Secondary - For Testing)
```
Language: TypeScript
Framework: React 18+
State Management: Context API
WebRTC: Native WebRTC APIs
Purpose: Testing with Flutter app
```

### Infrastructure
```
Containerization: Docker + Docker Compose
Reverse Proxy: Nginx
SSL: Let's Encrypt (Certbot)
Deployment: DigitalOcean (MVP) → AWS (scale)
CI/CD: GitHub Actions (later)
```

---

## 📅 Timeline Overview

**Total Duration:** 16 weeks (4 months)
```
Month 1: Backend Foundation (Week 1-4)
Month 2: Flutter App Core (Week 5-8)
Month 3: Integration & Testing (Week 9-12)
Month 4: React Web + Deployment (Week 13-16)
```

### Detailed Breakdown
- **Week 1-2:** Backend core + Mediasoup
- **Week 3-4:** WebRTC signaling + REST API
- **Week 5-6:** Flutter project + WebRTC integration
- **Week 7-8:** Flutter UI + call features
- **Week 9-10:** Cross-device testing + bug fixes
- **Week 11-12:** Flutter polish + performance
- **Week 13-14:** React web client (testing)
- **Week 15-16:** Deployment + documentation

---

## 🎯 Milestones

### Milestone 1: Backend Core ✅
**Duration:** Week 1-2  
**Goal:** Working Mediasoup backend with room management

#### Deliverables
- [x] TypeScript project setup
- [x] Core entities (Room, Peer) with tests
- [x] Error handling system
- [x] Mediasoup worker + router
- [x] REST API (create/join room)
- [x] Basic Socket.io handlers
- [x] 80%+ test coverage

#### Success Criteria
- ✅ Can create room via API
- ✅ Can join room via Socket.io
- ✅ Mediasoup router created successfully
- ✅ All unit tests passing
- ✅ No TypeScript errors
- ✅ Postman collection for testing

#### Tech Stack
- Node.js + TypeScript
- Express + Socket.io
- Mediasoup
- Jest

---

### Milestone 2: WebRTC Signaling ✅
**Duration:** Week 3-4  
**Goal:** Complete WebRTC signaling flow

#### Deliverables
- [x] Create transport endpoints
- [x] Connect transport handlers
- [x] Produce media handlers
- [x] Consume media handlers
- [x] Peer management (join/leave)
- [x] Error handling & recovery
- [x] Integration tests
- [x] Socket.io events documented

#### Success Criteria
- ✅ Transport creation works
- ✅ Producers/consumers created
- ✅ Can test with 2 browser tabs
- ✅ Graceful disconnect handling
- ✅ All signaling events working

#### Testing Approach
- Postman for REST
- Browser console for Socket.io
- Chrome DevTools for WebRTC stats

---

### Milestone 3: Flutter Project Setup ✅
**Duration:** Week 5  
**Goal:** Flutter project foundation with clean architecture

#### Deliverables
- [x] Flutter project created
- [x] Folder structure (feature-first clean architecture)
- [x] flutter_webrtc integration
- [x] socket_io_client integration
- [x] BLoC state management setup
- [x] Dependency injection (get_it)
- [x] Navigation setup (go_router)
- [x] Theme/design system

#### Success Criteria
- ✅ App runs on iOS simulator
- ✅ App runs on Android emulator
- ✅ Can connect to Socket.io server
- ✅ Can request camera/mic permissions
- ✅ Clean architecture validated

#### Tech Stack
- Flutter 3.16+
- flutter_webrtc
- flutter_bloc
- socket_io_client
- get_it (DI)
- go_router

#### Folder Structure
```
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── error/
│   ├── network/
│   └── utils/
├── features/
│   └── call/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart
└── main.dart
```

---

### Milestone 4: Flutter WebRTC Integration ✅
**Duration:** Week 6  
**Goal:** WebRTC working in Flutter

#### Deliverables
- [x] WebRTC service layer
- [x] Device enumeration (cameras/mics)
- [x] Local media stream capture
- [x] RTCPeerConnection setup
- [x] Transport creation (send/receive)
- [x] Producer creation (video/audio)
- [x] Consumer creation
- [x] Media renderer widgets

#### Success Criteria
- ✅ Can capture local video
- ✅ Local video preview works
- ✅ Can connect to Mediasoup
- ✅ Can create producers
- ✅ Can create consumers
- ✅ Video renders in Flutter widget

#### Key Files
```
lib/features/call/
├── data/
│   ├── datasources/
│   │   └── webrtc_datasource.dart
│   └── repositories/
│       └── call_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── media_stream.dart
│   ├── repositories/
│   │   └── call_repository.dart
│   └── usecases/
│       ├── create_room.dart
│       ├── join_room.dart
│       └── start_call.dart
└── presentation/
    └── bloc/
```

---

### Milestone 5: Flutter UI & Call Features ✅
**Duration:** Week 7-8  
**Goal:** Complete call experience in Flutter

#### Deliverables
- [x] Home screen (create/join room)
- [x] Waiting screen (room created)
- [x] Call screen (main UI)
- [x] Video grid layout
- [x] Local video preview
- [x] Remote video tiles
- [x] Control bar (mute/camera/leave)
- [x] Peer connection indicators
- [x] Loading/error states
- [x] Responsive design

#### Success Criteria
- ✅ 2-person call works (Flutter ↔ Flutter)
- ✅ Video quality good (720p)
- ✅ Audio quality good
- ✅ UI responsive
- ✅ Controls work correctly
- ✅ Graceful error handling
- ✅ Works on both iOS and Android

#### Screens
```
1. HomeScreen
   ├── Create call button
   ├── Join call input
   └── Join button

2. WaitingScreen
   ├── Room code display
   ├── Share button
   └── Waiting for others...

3. CallScreen
   ├── Video grid (1-10 people)
   ├── Local preview (PIP)
   ├── Control bar
   │   ├── Mute/unmute
   │   ├── Camera on/off
   │   ├── Switch camera
   │   └── Leave call
   └── Peer count indicator
```

---

### Milestone 6: Cross-Platform Testing ✅
**Duration:** Week 9-10  
**Goal:** Ensure quality across devices

#### Deliverables
- [x] Test on real iOS device
- [x] Test on real Android device
- [x] Test different network conditions
- [x] Test with 10 participants
- [x] Performance optimization
- [x] Memory leak fixes
- [x] Battery optimization
- [x] Bug fixes

#### Success Criteria
- ✅ Works on iOS 12+
- ✅ Works on Android 8+
- ✅ 10-person call stable
- ✅ No memory leaks
- ✅ Battery drain acceptable
- ✅ <2 second connection time
- ✅ Video smooth (30fps)

#### Testing Matrix
```
Devices to Test:
├── iOS
│   ├── iPhone 12 (or newer)
│   └── iPhone SE 2020 (budget)
└── Android
    ├── Pixel 6 (flagship)
    └── Samsung A54 (mid-range)

Test Scenarios:
├── 1:1 call (5 min)
├── Group call 4 people (5 min)
├── Group call 10 people (5 min)
├── Mute/unmute during call
├── Camera switch during call
├── Background/foreground app
├── Network interruption recovery
└── Call while on poor network
```

---

### Milestone 7: React Web Client (Testing) ✅
**Duration:** Week 11-12  
**Goal:** Web client for cross-platform testing

#### Deliverables
- [x] React + TypeScript setup
- [x] WebRTC integration
- [x] Socket.io client
- [x] Basic UI (minimal)
- [x] Same API as Flutter app
- [x] Deployment ready

#### Success Criteria
- ✅ Can join room from browser
- ✅ Can call Flutter app
- ✅ Flutter ↔ React call works
- ✅ Useful for testing/demo

#### Purpose
```
Why React Web Client?
├── Test Flutter app from laptop
├── Demo to recruiters (web is easier)
├── Cross-platform validation
└── Fallback if Flutter issues

Not Main Focus:
- Minimal UI (functional, not beautiful)
- Just enough to test backend
```

---

### Milestone 8: Deployment & Infrastructure ✅
**Duration:** Week 13-14  
**Goal:** Production-ready deployment

#### Deliverables
- [x] Backend Dockerfile
- [x] Docker Compose setup
- [x] Nginx configuration
- [x] SSL/TLS (Let's Encrypt)
- [x] Environment variables
- [x] One-click deploy (DigitalOcean)
- [x] Health check endpoints
- [x] Logging setup
- [x] Monitoring (basic)

#### Success Criteria
- ✅ Deploys to DigitalOcean
- ✅ HTTPS working
- ✅ Flutter app connects
- ✅ React app connects
- ✅ One-click deploy works
- ✅ Server auto-restarts

#### Infrastructure Files
```
├── backend/
│   └── Dockerfile
├── web-client/
│   └── Dockerfile
├── docker-compose.yml
├── nginx.conf
└── deploy/
    ├── setup.sh
    └── deploy.sh
```

---

### Milestone 9: Documentation & Launch ✅
**Duration:** Week 15-16  
**Goal:** Public launch ready

#### Deliverables
- [x] README.md (comprehensive)
- [x] ARCHITECTURE.md (diagrams)
- [x] BACKEND_SETUP.md
- [x] FLUTTER_SETUP.md
- [x] DEPLOYMENT.md
- [x] API documentation
- [x] Contributing guide
- [x] Demo video (Flutter app)
- [x] Screenshots/GIFs
- [x] Blog post

#### Success Criteria
- ✅ Anyone can deploy backend
- ✅ Anyone can run Flutter app
- ✅ Code quality excellent
- ✅ Demo video compelling
- ✅ GitHub repo professional
- ✅ Ready for App Store (later)

#### Documentation Structure
```
docs/
├── architecture/
│   ├── system-design.md
│   ├── backend-architecture.md
│   └── flutter-architecture.md
├── setup/
│   ├── backend-setup.md
│   ├── flutter-setup.md
│   └── web-client-setup.md
├── deployment/
│   ├── digitalocean.md
│   ├── aws.md
│   └── self-hosting.md
├── api/
│   ├── rest-api.md
│   └── websocket-events.md
└── guides/
    ├── contributing.md
    └── troubleshooting.md
```

---

## 📊 Success Metrics

### Code Quality Metrics
```
Backend:
✅ Test Coverage: >80%
✅ TypeScript Strict: 100%
✅ Linting Errors: 0

Flutter:
✅ Test Coverage: >70%
✅ Dart Analysis: 0 errors
✅ Widget Tests: Core features
✅ No deprecated APIs
```

### Performance Metrics
```
Backend:
✅ Signaling Latency: <150ms
✅ Memory: <500MB per 10 users

Flutter:
✅ Frame Rate: 60fps (UI)
✅ Connection Time: <2 seconds
✅ Video Quality: 720p @ 30fps
✅ Memory: <300MB during call
✅ Battery: <15% per hour
```

### User Experience
```
✅ Intuitive UI (no tutorial needed)
✅ <3 taps to start call
✅ Clear visual feedback
✅ Graceful error messages
✅ Works on slow networks (3G)
```

---

## ⚠️ Risk Management

### Risk 1: Flutter WebRTC Complexity
**Probability:** HIGH | **Impact:** HIGH

**Mitigation:**
- Study flutter_webrtc examples first
- Build simple 1:1 demo before MVP
- Join Flutter WebRTC Discord
- Allocate 2 extra weeks for learning

---

### Risk 2: iOS/Android Platform Differences
**Probability:** MEDIUM | **Impact:** MEDIUM

**Mitigation:**
- Test on both platforms weekly
- Handle platform-specific code early
- Use conditional imports
- Keep platform code isolated

---

### Risk 3: App Store Approval (Later)
**Probability:** LOW (not MVP) | **Impact:** MEDIUM

**Mitigation:**
- Follow Apple guidelines from start
- Add privacy policy
- Request minimal permissions
- Clear permission explanations

---

### Risk 4: Cross-Device Testing Access
**Probability:** MEDIUM | **Impact:** LOW

**Mitigation:**
- Use emulators primarily
- Borrow devices from friends
- Test on personal phone
- Use TestFlight/Firebase App Distribution

---

### Risk 5: Scope Creep (Flutter Features)
**Probability:** HIGH | **Impact:** HIGH

**Mitigation:**
- Resist adding "one more feature"
- Focus on core call quality
- Keep UI minimal (MVP)
- Beautiful UI is post-MVP

---

## 🎯 Definition of Done

### For Backend Tasks
- [ ] Code written and tested
- [ ] Tests passing (>80%)
- [ ] TypeScript strict mode
- [ ] API documented
- [ ] Postman tested

### For Flutter Tasks
- [ ] Code written and tested
- [ ] Works on iOS and Android
- [ ] No dart analysis errors
- [ ] UI matches design (basic)
- [ ] Performance acceptable

### For Milestones
- [ ] All tasks completed
- [ ] Success criteria met
- [ ] Integration tested
- [ ] Manual testing done
- [ ] Documentation updated

### For MVP
- [ ] All 9 milestones done
- [ ] Backend deployed
- [ ] Flutter app working
- [ ] Demo video recorded
- [ ] Documentation complete
- [ ] Ready to share

---

## 📈 Progress Tracking

### Weekly Review
1. What did I complete?
2. Flutter vs Backend balance?
3. On track for milestone?
4. Blockers?
5. Next week's focus?

### Testing Checklist (Weekly)
```
Backend:
- [ ] Unit tests passing
- [ ] Can create room (Postman)
- [ ] Can join room (Socket.io)
- [ ] WebRTC signaling works

Flutter:
- [ ] App builds on iOS
- [ ] App builds on Android
- [ ] Can connect to backend
- [ ] Video renders correctly
```

---

## 🚀 Development Workflow

### Backend Development
```bash
# Terminal 1: Run backend
cd darshan-backend
npm run dev

# Terminal 2: Run tests
npm run test:watch

# Terminal 3: Test API
# Use Postman/curl
```

### Flutter Development
```bash
# Terminal 1: Backend (must be running)
cd darshan-backend
npm run dev

# Terminal 2: Expose backend for device
ngrok http 5000

# Terminal 3: Run Flutter
cd darshan-app
flutter run

# Hot reload: Press 'r'
# Hot restart: Press 'R'
```

### Testing Flutter ↔ Backend
```
1. Start backend on laptop
2. Use ngrok to expose (for real device)
3. Update Flutter config with ngrok URL
4. Run Flutter on device
5. Test call creation/joining
```

---

## 📱 Flutter-Specific Considerations

### Permissions
```yaml
# iOS (Info.plist)
- Camera usage
- Microphone usage

# Android (AndroidManifest.xml)
- CAMERA
- RECORD_AUDIO
- INTERNET
- MODIFY_AUDIO_SETTINGS
```

### Platform Channels (If Needed)
```
Keep platform-specific code minimal:
- Use flutter_webrtc (handles most)
- Only custom code if absolutely needed
```

### State Management (BLoC)
```
Why BLoC?
✅ Predictable state
✅ Testable
✅ Separation of concerns
✅ Industry standard
✅ Works well with streams (WebRTC)
```

---

## 🎯 Next Steps

### Immediate Actions
1. ✅ Review this plan
2. ⬜ Set up task tracking (GitHub Projects)
3. ⬜ Create backend repository
4. ⬜ Create Flutter repository
5. ⬜ Start Milestone 3

### Week 3 Focus
- Clean up any backend technical debt
- Prepare for Flutter testing

### First Month Goal
- ✅ Backend working
- ✅ Can test with 2 browser tabs
- ✅ Ready for Flutter integration

---

**Last Updated:** 2026-04-05  
**Current Milestone:** Milestone 3 - Flutter Project Setup  
**Status:** Completed Backend Core -> Ready for Flutter  
**Primary Focus:** Flutter app architecture
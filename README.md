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
Language: TypeScript Runtime: Node.js 18+ Framework: Express WebRTC SFU: Mediasoup 3.14+ Signaling: Socket.io Testing: Jest + Supertest Database: In-memory (MVP) → PostgreSQL (later)

### Flutter App (Primary Frontend)
Language: Dart Framework: Flutter 3.16+ State Management: BLoC (flutter_bloc) WebRTC: flutter_webrtc Signaling: socket_io_client Architecture: Clean Architecture (feature-first) Testing: flutter_test + mockito Platforms: iOS 12+ and Android 8+

### React Web Client (Secondary - For Testing)
Language: TypeScript Framework: React 18+ State Management: Context API WebRTC: Native WebRTC APIs Purpose: Testing with Flutter app

### Infrastructure
Containerization: Docker + Docker Compose Reverse Proxy: Nginx SSL: Let's Encrypt (Certbot) Deployment: DigitalOcean (MVP) → AWS (scale) CI/CD: GitHub Actions (later)

---

## 📅 Timeline Overview

**Total Duration:** 16 weeks (4 months)

- Month 1: Backend Foundation (Week 1-4) 
- Month 2: Flutter App Core (Week 5-8) 
- Month 3: Integration & Testing (Week 9-12) 
- Month 4: React Web + Deployment (Week 13-16)

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

**Last Updated:** 2026-04-03
**Current Milestone:** Milestone 1 - Backend Core  
**Status:** Planning → Ready to Build  
**Primary Focus:** Backend (Week 1-4) → Flutter (Week 5-12)

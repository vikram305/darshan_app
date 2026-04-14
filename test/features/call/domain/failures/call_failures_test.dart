// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Core failures (pre-existing) — verify they all share the same Failure API
  // ─────────────────────────────────────────────────────────────────────────
  group('Core Failures', () {
    test('ServerFailure: extends Failure and exposes message', () {
      const f = ServerFailure('server error');
      expect(f, isA<Failure>());
      expect(f.message, 'server error');
    });

    test('InternetFailure: extends Failure and exposes message', () {
      const f = InternetFailure('no internet');
      expect(f, isA<Failure>());
      expect(f.message, 'no internet');
    });

    test('BadFilterFailure: extends Failure and exposes message', () {
      const f = BadFilterFailure('bad filter');
      expect(f, isA<Failure>());
      expect(f.message, 'bad filter');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FL-01 RoomNotFoundFailure
  // ─────────────────────────────────────────────────────────────────────────
  group('RoomNotFoundFailure', () {
    const msg = 'Room not found.';

    test('FL-01a: extends Failure', () {
      const f = RoomNotFoundFailure(msg);
      expect(f, isA<Failure>());
    });

    test('FL-01b: message is propagated correctly', () {
      const f = RoomNotFoundFailure(msg);
      expect(f.message, msg);
    });

    test('FL-01c: two instances with same message are equal (Equatable)', () {
      const a = RoomNotFoundFailure(msg);
      const b = RoomNotFoundFailure(msg);
      expect(a, equals(b));
    });

    test('FL-01d: two instances with different messages are NOT equal', () {
      const a = RoomNotFoundFailure('room-abc not found');
      const b = RoomNotFoundFailure('room-xyz not found');
      expect(a, isNot(equals(b)));
    });

    test('FL-01e: props contains only the message', () {
      const f = RoomNotFoundFailure(msg);
      expect(f.props, [msg]);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FL-02 RoomFullFailure
  // ─────────────────────────────────────────────────────────────────────────
  group('RoomFullFailure', () {
    const msg = 'Room is full.';

    test('FL-02a: extends Failure', () {
      const f = RoomFullFailure(msg);
      expect(f, isA<Failure>());
    });

    test('FL-02b: message is propagated correctly', () {
      const f = RoomFullFailure(msg);
      expect(f.message, msg);
    });

    test('FL-02c: same message → equal (Equatable)', () {
      const a = RoomFullFailure(msg);
      const b = RoomFullFailure(msg);
      expect(a, equals(b));
    });

    test('FL-02d: different messages → not equal', () {
      const a = RoomFullFailure('full A');
      const b = RoomFullFailure('full B');
      expect(a, isNot(equals(b)));
    });

    test('FL-02e: props contains only the message', () {
      const f = RoomFullFailure(msg);
      expect(f.props, [msg]);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FL-03 MediaPermissionFailure
  // ─────────────────────────────────────────────────────────────────────────
  group('MediaPermissionFailure', () {
    const msg = 'Camera/mic permission denied.';

    test('FL-03a: extends Failure', () {
      const f = MediaPermissionFailure(msg);
      expect(f, isA<Failure>());
    });

    test('FL-03b: message is propagated correctly', () {
      const f = MediaPermissionFailure(msg);
      expect(f.message, msg);
    });

    test('FL-03c: same message → equal (Equatable)', () {
      const a = MediaPermissionFailure(msg);
      const b = MediaPermissionFailure(msg);
      expect(a, equals(b));
    });

    test('FL-03d: different messages → not equal', () {
      const a = MediaPermissionFailure('mic denied');
      const b = MediaPermissionFailure('camera denied');
      expect(a, isNot(equals(b)));
    });

    test('FL-03e: props contains only the message', () {
      const f = MediaPermissionFailure(msg);
      expect(f.props, [msg]);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FL-04 TransportFailure
  // ─────────────────────────────────────────────────────────────────────────
  group('TransportFailure', () {
    const msg = 'ICE negotiation failed.';

    test('FL-04a: extends Failure', () {
      const f = TransportFailure(msg);
      expect(f, isA<Failure>());
    });

    test('FL-04b: message is propagated correctly', () {
      const f = TransportFailure(msg);
      expect(f.message, msg);
    });

    test('FL-04c: same message → equal (Equatable)', () {
      const a = TransportFailure(msg);
      const b = TransportFailure(msg);
      expect(a, equals(b));
    });

    test('FL-04d: different messages → not equal', () {
      const a = TransportFailure('ICE failed');
      const b = TransportFailure('DTLS failed');
      expect(a, isNot(equals(b)));
    });

    test('FL-04e: props contains only the message', () {
      const f = TransportFailure(msg);
      expect(f.props, [msg]);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FL-05 Cross-type: different Failure subclasses with same message ≠ equal
  // ─────────────────────────────────────────────────────────────────────────
  group('Cross-type Failure inequality', () {
    const msg = 'identical message';

    test('FL-05a: RoomNotFoundFailure ≠ RoomFullFailure (same message)', () {
      const a = RoomNotFoundFailure(msg);
      const b = RoomFullFailure(msg);
      // Equatable uses runtimeType, so these must NOT be equal
      expect(a, isNot(equals(b)));
    });

    test('FL-05b: MediaPermissionFailure ≠ ServerFailure (same message)', () {
      const a = MediaPermissionFailure(msg);
      const b = ServerFailure(msg);
      expect(a, isNot(equals(b)));
    });

    test('FL-05c: TransportFailure ≠ InternetFailure (same message)', () {
      const a = TransportFailure(msg);
      const b = InternetFailure(msg);
      expect(a, isNot(equals(b)));
    });

    // All subtypes are Failure — polymorphic assignment must work
    test('FL-05d: all custom failures assignable to Failure (polymorphism)', () {
      final List<Failure> failures = [
        const RoomNotFoundFailure('r'),
        const RoomFullFailure('r'),
        const MediaPermissionFailure('r'),
        const TransportFailure('r'),
      ];
      expect(failures.length, 4);
      for (final f in failures) {
        expect(f, isA<Failure>());
      }
    });
  });
}

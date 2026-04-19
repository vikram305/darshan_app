import 'dart:convert';
import 'package:darshan_app/features/call/data/models/room_model.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/call_test_constants.dart';

void main() {
  test('RoomModel should be a subclass of RoomEntity', () async {
    final tRoomModel = RoomModel.fromJson(tRoomJson);
    expect(tRoomModel, isA<RoomEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      final result = RoomModel.fromJson(tRoomJson);
      expect(result.id, tRoomId);
      expect(result.peers.length, 1);
      expect(result.isActive, isTrue);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      final tRoomModel = RoomModel.fromJson(tRoomJson);
      final result = tRoomModel.toJson();
      final expectedMap = {
        'id': tRoomId,
        'hostPeerId': tHostPeerId,
        'peers': [tPeerJson],
        'createdAt': '2026-04-14T10:00:00.000',
        'isActive': true,
      };
      expect(result, expectedMap);
    });
  });
}

import 'package:darshan_app/features/call/data/models/consumer_model.dart';
import 'package:darshan_app/features/call/data/models/peer_model.dart';
import 'package:darshan_app/features/call/data/models/producer_model.dart';
import 'package:darshan_app/features/call/data/models/transport_model.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/call_test_constants.dart';

void main() {
  group('ProducerModel', () {
    test('fromJson should return valid model', () {
      final result = ProducerModel.fromJson(tProducerJson);
      expect(result.id, tProducerId);
      expect(result.kind, MediaKind.audio);
    });

    test('toJson should return valid map', () {
      final model = ProducerModel.fromJson(tProducerJson);
      expect(model.toJson(), tProducerJson);
    });
  });

  group('ConsumerModel', () {
    test('fromJson should return valid model', () {
      final result = ConsumerModel.fromJson(tConsumerJson);
      expect(result.id, tConsumerId);
      expect(result.kind, MediaKind.video);
      expect(result.rtpParameters, tRtpParameters);
    });

    test('toJson should return valid map', () {
      final model = ConsumerModel.fromJson(tConsumerJson);
      expect(model.toJson(), tConsumerJson);
    });
  });

  group('PeerModel', () {
    test('fromJson should return valid model', () {
      final result = PeerModel.fromJson(tPeerJson);
      expect(result.id, tHostPeerId);
      expect(result.producers.length, 1);
    });

    test('toJson should return valid map', () {
      final model = PeerModel.fromJson(tPeerJson);
      expect(model.toJson(), tPeerJson);
    });
  });

  group('TransportModel', () {
    test('fromJson should return valid model', () {
      final result = TransportModel.fromJson(tTransportJson);
      expect(result.id, 'transport-001');
      expect(result.iceParameters, tIceParameters);
    });

    test('toJson should return valid map', () {
      final model = TransportModel.fromJson(tTransportJson);
      expect(model.toJson(), tTransportJson);
    });
  });
}

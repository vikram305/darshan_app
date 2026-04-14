// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/produce_media_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';
import 'produce_media_usecase_test.mocks.dart';

/// [MediaStreamTrack] is a native platform object — it must be mocked in unit tests.
@GenerateMocks([MediaStreamTrack])
void main() {
  late MockCallRepository mockRepo;
  late ProduceMediaUsecase usecase;
  late MockMediaStreamTrack mockTrack;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = ProduceMediaUsecase(mockRepo);
    mockTrack = MockMediaStreamTrack();
    provideDummy<Either<Failure, Success<ProducerEntity>>>(Right(tSuccessProducer));
  });

  group('ProduceMediaUsecase', () {
    // Scenario 3.4 #6 — video track correctly passed to repo.
    test(
      'SC-UC-12: passes kind=video and track to repository correctly, returns Right(ProducerEntity)',
      () async {
        when(mockRepo.produce(
          roomId: anyNamed('roomId'),
          kind: anyNamed('kind'),
          track: anyNamed('track'),
        )).thenAnswer((_) async => Right(tSuccessProducer));

        final params = ProduceMediaParams(
          roomId: tRoomId,
          kind: MediaKind.video,
          track: mockTrack,
        );
        final result = await usecase.call(params);

        expect(result, Right<Failure, Success<ProducerEntity>>(tSuccessProducer));
        verify(mockRepo.produce(
          roomId: tRoomId,
          kind: MediaKind.video,
          track: mockTrack,
        )).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // Scenario 3.4 #8 — offline → Left(InternetFailure) passed through.
    test(
      'SC-UC-13: offline → Left(InternetFailure) passed through from repository',
      () async {
        when(mockRepo.produce(
          roomId: anyNamed('roomId'),
          kind: anyNamed('kind'),
          track: anyNamed('track'),
        )).thenAnswer((_) async => const Left(tInternetFailure));

        final params = ProduceMediaParams(
          roomId: tRoomId,
          kind: MediaKind.video,
          track: mockTrack,
        );
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<ProducerEntity>>(tInternetFailure));
      },
    );

    // TransportFailure passthrough (transport not ready).
    test(
      'SC-UC-14: passes through Left(TransportFailure) when transport not initialized',
      () async {
        when(mockRepo.produce(
          roomId: anyNamed('roomId'),
          kind: anyNamed('kind'),
          track: anyNamed('track'),
        )).thenAnswer((_) async => const Left(tTransportFailure));

        final params = ProduceMediaParams(
          roomId: tRoomId,
          kind: MediaKind.audio,
          track: mockTrack,
        );
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<ProducerEntity>>(tTransportFailure));
      },
    );
  });
}

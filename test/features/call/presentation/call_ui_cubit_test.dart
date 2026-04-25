import 'package:bloc_test/bloc_test.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:darshan_app/features/call/presentation/cubit/call_ui_cubit.dart';
import 'package:darshan_app/features/call/presentation/cubit/call_ui_state.dart';
import 'package:darshan_app/core/error/failure.dart';

import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils/call_test_constants.dart';

import 'call_ui_cubit_test.mocks.dart';

import 'package:darshan_app/features/call/domain/usecases/produce_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/consume_media_usecase.dart';
import 'package:darshan_app/features/call/domain/repositories/call_repository.dart';

@GenerateMocks([
  InitLocalMediaUsecase,
  SwitchCameraUsecase,
  ConsumeMediaUsecase,
  ProduceMediaUsecase,
  CallRepository,
])
void main() {
  late CallUiCubit cubit;
  late MockInitLocalMediaUsecase mockInitLocalMedia;
  late MockSwitchCameraUsecase mockSwitchCamera;
  late MockConsumeMediaUsecase mockConsumeMedia;
  late MockProduceMediaUsecase mockProduceMedia;
  late MockCallRepository mockRepository;

  setUp(() {
    provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(Success(tLocalMedia)));
    mockInitLocalMedia = MockInitLocalMediaUsecase();
    mockSwitchCamera = MockSwitchCameraUsecase();
    mockConsumeMedia = MockConsumeMediaUsecase();
    mockProduceMedia = MockProduceMediaUsecase();
    mockRepository = MockCallRepository();

    // Mock onCallEvent stream to avoid errors
    when(mockRepository.onCallEvent).thenAnswer((_) => const Stream.empty());

    cubit = CallUiCubit(
      initLocalMediaUsecase: mockInitLocalMedia,
      switchCameraUsecase: mockSwitchCamera,
      consumeMediaUsecase: mockConsumeMedia,
      produceMediaUsecase: mockProduceMedia,
      repository: mockRepository,
    );
  });


  group('CallUiCubit', () {
    test('initial state should be empty CallUiState', () {
      expect(cubit.state, const CallUiState());
    });

    blocTest<CallUiCubit, CallUiState>(
      'Scenario 3.6 #1: initializeData should populate originalData and viewData',
      build: () => cubit,
      act: (cubit) => cubit.initializeData(tRoom),
      expect: () => [
        isA<CallUiState>()
            .having((s) => s.originalData, 'originalData', tRoom)
            .having((s) => s.viewData, 'viewData', tRoom),
      ],
    );

    blocTest<CallUiCubit, CallUiState>(
      'Scenario 3.6 #2: peerJoined should append peer and update data',
      build: () => cubit,
      seed: () => CallUiState(originalData: tRoom, viewData: tRoom),
      act: (cubit) => cubit.peerJoined(tGuestPeer),
      expect: () => [
        isA<CallUiState>().having((s) => s.viewData?.peers.length, 'peer count', 2),
      ],
    );

    blocTest<CallUiCubit, CallUiState>(
      'Scenario 3.6 #3: peerLeft should remove peer',
      build: () => cubit,
      seed: () => CallUiState(originalData: tRoomWithGuest, viewData: tRoomWithGuest),
      act: (cubit) => cubit.peerLeft(tPeerId),
      expect: () => [
        isA<CallUiState>().having((s) => s.viewData?.peers.length, 'peer count', 1),
      ],
    );

    blocTest<CallUiCubit, CallUiState>(
      'Scenario 3.6 #4: toggleMic should flip isMicEnabled',
      build: () => cubit,
      seed: () => CallUiState(localMedia: tLocalMedia),
      act: (cubit) => cubit.toggleMic(),
      expect: () => [
        isA<CallUiState>().having((s) => s.localMedia?.isMicEnabled, 'mic enabled', false),
      ],
    );

    blocTest<CallUiCubit, CallUiState>(
      'Scenario 3.6 #8: peerJoined should deduplicate',
      build: () => cubit,
      seed: () => CallUiState(originalData: tRoom, viewData: tRoom),
      act: (cubit) => cubit.peerJoined(tHostPeer), // already exists
      expect: () => [], // should not emit anything
    );
  });
}

import 'package:darshan_app/core/error/exception.dart';
import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/network/network_info.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/data/datasources/call_remote_data_source.dart';
import 'package:darshan_app/features/call/data/datasources/media_data_source.dart';
import 'package:darshan_app/features/call/data/models/room_model.dart';
import 'package:darshan_app/features/call/data/repositories/call_repository_impl.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'call_repository_impl_test.mocks.dart';

@GenerateMocks([
  CallRemoteDataSource,
  MediaDataSource,
  NetworkInfo,
  MediaStreamTrack,
  MediaStream,
])
void main() {
  late CallRepositoryImpl repository;
  late MockCallRemoteDataSource mockRemoteDataSource;
  late MockMediaDataSource mockMediaDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockMediaStreamTrack mockTrack;
  late MockMediaStream mockStream;

  setUp(() {
    mockRemoteDataSource = MockCallRemoteDataSource();
    mockMediaDataSource = MockMediaDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockTrack = MockMediaStreamTrack();
    mockStream = MockMediaStream();
    repository = CallRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      mediaDataSource: mockMediaDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('createRoom', () {
    final tRoomModel = RoomModel.fromJson(tRoomJson);

    runTestsOnline(() {
      test('should return remote data when the call to remote data source is successful', () async {
        when(mockRemoteDataSource.createRoom(any)).thenAnswer((_) async => tRoomModel);
        final result = await repository.createRoom(displayName: tDisplayName);
        verify(mockRemoteDataSource.createRoom(tDisplayName));
        expect(result, equals(Right<Failure, Success<RoomEntity>>(Success(tRoomModel))));
      });


      test('should return server failure when the call to remote data source is unsuccessful', () async {
        when(mockRemoteDataSource.createRoom(any)).thenThrow(ServerException(tErrorMessage));
        final result = await repository.createRoom(displayName: tDisplayName);
        expect(result, equals(const Left(ServerFailure(tErrorMessage))));
      });
    });

    runTestsOffline(() {
      test('should return internet failure when offline', () async {
        final result = await repository.createRoom(displayName: tDisplayName);
        expect(result, equals(const Left(InternetFailure('No internet connection'))));
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });

  group('joinRoom', () {
    final tRoomModel = RoomModel.fromJson(tRoomJson);

    runTestsOnline(() {
      // Scenario 3.3 #7 - RoomNotFound
      test('should return RoomNotFoundFailure when room not found', () async {
        when(mockRemoteDataSource.joinRoom(any, any)).thenThrow(RoomNotFoundException(tRoomNotFoundMessage));
        final result = await repository.joinRoom(roomId: tRoomId, displayName: tDisplayName);
        expect(result, equals(const Left(RoomNotFoundFailure(tRoomNotFoundMessage))));
      });

      // Scenario 3.3 #8 - RoomFull
      test('should return RoomFullFailure when room is full', () async {
        when(mockRemoteDataSource.joinRoom(any, any)).thenThrow(RoomFullException(tRoomFullMessage));
        final result = await repository.joinRoom(roomId: tRoomId, displayName: tDisplayName);
        expect(result, equals(const Left(RoomFullFailure(tRoomFullMessage))));
      });
    });
  });

  group('produce', () {
    runTestsOnline(() {
      // Scenario 3.3 #11 - TransportFailure
      test('should return TransportFailure when send transport not initialized', () async {
        when(mockRemoteDataSource.produce(
          roomId: anyNamed('roomId'),
          kind: anyNamed('kind'),
          track: anyNamed('track'),
          stream: anyNamed('stream'),
        )).thenThrow(TransportException(tTransportMessage));

        final result = await repository.produce(
          roomId: tRoomId,
          kind: MediaKind.audio,
          track: mockTrack,
          stream: mockStream,
        );
        expect(result, equals(const Left(TransportFailure(tTransportMessage))));
      });
    });
  });

  group('consume', () {
    runTestsOnline(() {
      // Scenario 3.3 #12 - ServerFailure (malformed RTP)
      test('should return ServerFailure when RTP params are malformed', () async {
        when(mockRemoteDataSource.consume(
          roomId: anyNamed('roomId'),
          producerId: anyNamed('producerId'),
          peerId: anyNamed('peerId'),
        )).thenThrow(ServerException('Malformed RTP'));

        final result = await repository.consume(
          roomId: tRoomId,
          producerId: tRemoteProducerId,
          peerId: tPeerId,
        );
        expect(result, equals(const Left(ServerFailure('Malformed RTP'))));
      });
    });
  });

  group('initLocalMedia', () {
    // Scenario 3.3 #10 - MediaPermissionFailure
    test('should return MediaPermissionFailure when permission denied', () async {
      when(mockMediaDataSource.getUserMedia(
        enableAudio: anyNamed('enableAudio'),
        enableVideo: anyNamed('enableVideo'),
      )).thenThrow(MediaPermissionException(tMediaPermissionMessage));

      final result = await repository.initLocalMedia(enableAudio: true, enableVideo: true);
      expect(result, equals(const Left(MediaPermissionFailure(tMediaPermissionMessage))));
    });
  });
}

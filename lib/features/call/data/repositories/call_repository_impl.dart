import 'package:darshan_app/core/error/exception.dart';
import 'package:darshan_app/core/network/network_info.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/data/datasources/call_remote_data_source.dart';
import 'package:darshan_app/features/call/data/datasources/media_data_source.dart';
import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/repositories/call_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/features/call/domain/entities/call_event.dart';
import 'package:darshan_app/features/call/data/models/peer_model.dart';


class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remoteDataSource;
  final MediaDataSource mediaDataSource;
  final NetworkInfo networkInfo;

  CallRepositoryImpl({
    required this.remoteDataSource,
    required this.mediaDataSource,
    required this.networkInfo,
  });

  @override
  Stream<CallEvent> get onCallEvent {
    return remoteDataSource.onEvent.map((event) {
      final type = event['type'];
      final data = event['data'];

      switch (type) {
        case 'newPeer':
          return PeerJoinedEvent(PeerModel.fromJson(data));
        case 'peerClosed':
          return PeerLeftEvent(data['peerId']);
        case 'newProducer':
          return ProducerJoinedEvent(
            peerId: data['peerId'],
            producerId: data['producerId'],
            kind: data['kind'] == 'video' ? MediaKind.video : MediaKind.audio,
          );
        case 'producerClosed':
          return ProducerClosedEvent(
            peerId: data['peerId'],
            producerId: data['producerId'],
          );
        default:
          // For MVP, we can treat other events as null or just ignored.
          // Returning a dummy or handled separately.
          return const PeerLeftEvent(''); // Placeholder
      }
    }).where((event) => event is! PeerLeftEvent || event.peerId.isNotEmpty);
  }


  @override
  Future<Either<Failure, Success<RoomEntity>>> createRoom({
    required String displayName,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      final room = await remoteDataSource.createRoom(displayName);
      return Success(room);
    });
  }

  @override
  Future<Either<Failure, Success<RoomEntity>>> joinRoom({
    required String roomId,
    required String displayName,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      final room = await remoteDataSource.joinRoom(roomId, displayName);
      return Success(room);
    });
  }

  @override
  Future<Either<Failure, Success<void>>> leaveRoom({
    required String roomId,
    required String peerId,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      await remoteDataSource.leaveRoom(roomId, peerId);
      return const Success(null);
    });
  }

  @override
  Future<Either<Failure, Success<ProducerEntity>>> produce({
    required String roomId,
    required MediaKind kind,
    required MediaStreamTrack track,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      final producer = await remoteDataSource.produce(
        roomId: roomId,
        kind: kind,
        track: track,
      );
      return Success(producer);
    });
  }

  @override
  Future<Either<Failure, Success<ConsumerEntity>>> consume({
    required String roomId,
    required String producerId,
    required String peerId,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      final consumer = await remoteDataSource.consume(
        roomId: roomId,
        producerId: producerId,
        peerId: peerId,
      );
      return Success(consumer);
    });
  }

  @override
  Future<Either<Failure, Success<void>>> toggleAudio({
    required String producerId,
    required bool pause,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      await remoteDataSource.toggleAudio(producerId: producerId, pause: pause);
      return const Success(null);
    });
  }

  @override
  Future<Either<Failure, Success<void>>> toggleCamera({
    required String producerId,
    required bool pause,
  }) async {
    return _handleNetworkAndServerErrors(() async {
      await remoteDataSource.toggleCamera(producerId: producerId, pause: pause);
      return const Success(null);
    });
  }

  @override
  Future<Either<Failure, Success<LocalMediaEntity>>> initLocalMedia({
    required bool enableAudio,
    required bool enableVideo,
  }) async {
    try {
      final media = await mediaDataSource.getUserMedia(
        enableAudio: enableAudio,
        enableVideo: enableVideo,
      );
      return Right(Success(media));
    } on MediaPermissionException catch (e) {
      return Left(MediaPermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success<LocalMediaEntity>>> switchCamera() async {
    try {
      final media = await mediaDataSource.switchCamera();
      return Right(Success(media));
    } on MediaPermissionException catch (e) {
      return Left(MediaPermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Private helper to wrap boilerplate internet connection and error mapping.
  Future<Either<Failure, Success<T>>> _handleNetworkAndServerErrors<T>(
    Future<Success<T>> Function() action,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(InternetFailure('No internet connection'));
    }
    try {
      final result = await action();
      return Right(result);
    } on RoomNotFoundException catch (e) {
      return Left(RoomNotFoundFailure(e.message));
    } on RoomFullException catch (e) {
      return Left(RoomFullFailure(e.message));
    } on TransportException catch (e) {
      return Left(TransportFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/media_kind.dart';
import '../entities/producer_entity.dart';
import '../repositories/call_repository.dart';

/// Publishes a media track ([kind] = audio or video) to the room via the server send transport.
/// Possible failures: [ServerFailure] (transport not ready), [InternetFailure], [MediaPermissionFailure].
class ProduceMediaUsecase extends UseCase<ProducerEntity, ProduceMediaParams> {
  final CallRepository repository;
  ProduceMediaUsecase(this.repository);

  @override
  Future<Either<Failure, Success<ProducerEntity>>> call(ProduceMediaParams params) {
    return repository.produce(
      roomId: params.roomId,
      kind: params.kind,
      track: params.track,
    );
  }
}

class ProduceMediaParams extends Equatable {
  final String roomId;
  final MediaKind kind;
  final MediaStreamTrack track;

  const ProduceMediaParams({
    required this.roomId,
    required this.kind,
    required this.track,
  });

  @override
  List<Object?> get props => [roomId, kind, track];
}

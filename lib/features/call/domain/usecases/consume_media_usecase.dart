import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/consumer_entity.dart';
import '../repositories/call_repository.dart';

/// Requests consumption of a remote producer.
/// Returns [ConsumerEntity] with RTP params populated, ready to render in `RTCVideoView`.
/// Callers must never pass their own [peerId] as the consumer target — validate before calling.
/// Possible failures: [ServerFailure], [InternetFailure].
class ConsumeMediaUsecase extends UseCase<ConsumerEntity, ConsumeMediaParams> {
  final CallRepository repository;
  ConsumeMediaUsecase(this.repository);

  @override
  Future<Either<Failure, Success<ConsumerEntity>>> call(ConsumeMediaParams params) {
    return repository.consume(
      roomId: params.roomId,
      producerId: params.producerId,
      peerId: params.peerId,
    );
  }
}

class ConsumeMediaParams extends Equatable {
  final String roomId;
  final String producerId;
  final String peerId;

  const ConsumeMediaParams({
    required this.roomId,
    required this.producerId,
    required this.peerId,
  });

  @override
  List<Object?> get props => [roomId, producerId, peerId];
}

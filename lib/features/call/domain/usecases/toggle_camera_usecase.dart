import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/call_repository.dart';

/// Pauses or resumes a local video producer on the server without closing it.
/// Possible failures: [ServerFailure].
class ToggleCameraUsecase extends UseCase<void, ToggleCameraParams> {
  final CallRepository repository;
  ToggleCameraUsecase(this.repository);

  @override
  Future<Either<Failure, Success<void>>> call(ToggleCameraParams params) {
    return repository.toggleCamera(producerId: params.producerId, pause: params.pause);
  }
}

class ToggleCameraParams extends Equatable {
  final String producerId;

  /// True to pause (hide camera); false to resume.
  final bool pause;

  const ToggleCameraParams({required this.producerId, required this.pause});

  @override
  List<Object?> get props => [producerId, pause];
}

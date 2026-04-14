import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/local_media_entity.dart';
import '../repositories/call_repository.dart';

/// Flips the active camera between front (selfie) and rear without any socket interaction.
/// Delegates exclusively to `WebRTCDatasource` — no network call is made.
/// Possible failures: [MediaPermissionFailure] (e.g., device has no front camera).
class SwitchCameraUsecase extends UseCase<LocalMediaEntity, SwitchCameraParams> {
  final CallRepository repository;
  SwitchCameraUsecase(this.repository);

  @override
  Future<Either<Failure, Success<LocalMediaEntity>>> call(SwitchCameraParams params) {
    return repository.switchCamera();
  }
}

/// Empty params — switch-camera requires no external input.
class SwitchCameraParams extends Equatable {
  const SwitchCameraParams();

  @override
  List<Object?> get props => [];
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/local_media_entity.dart';
import '../repositories/call_repository.dart';

/// Requests mic/camera permission, opens the media stream, and enumerates available devices.
/// Returns a fully populated [LocalMediaEntity] on success.
/// Possible failures: [MediaPermissionFailure] (OS permission denied),
/// [ServerFailure] (device enumeration error).
/// Edge: passing `enableAudio: false, enableVideo: false` results in a [MediaPermissionFailure]
/// since a completely muted stream is unsafe to publish.
class InitLocalMediaUsecase extends UseCase<LocalMediaEntity, InitLocalMediaParams> {
  final CallRepository repository;
  InitLocalMediaUsecase(this.repository);

  @override
  Future<Either<Failure, Success<LocalMediaEntity>>> call(InitLocalMediaParams params) {
    return repository.initLocalMedia(
      enableAudio: params.enableAudio,
      enableVideo: params.enableVideo,
    );
  }
}

class InitLocalMediaParams extends Equatable {
  final bool enableAudio;
  final bool enableVideo;

  const InitLocalMediaParams({required this.enableAudio, required this.enableVideo});

  @override
  List<Object?> get props => [enableAudio, enableVideo];
}

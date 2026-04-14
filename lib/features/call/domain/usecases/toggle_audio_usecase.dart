import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/call_repository.dart';

/// Pauses or resumes a local audio producer on the server without closing it.
/// Using "pause" (not "close") keeps the producer alive on the server-side,
/// allowing instant resume without renegotiating transport.
/// Possible failures: [ServerFailure].
class ToggleAudioUsecase extends UseCase<void, ToggleAudioParams> {
  final CallRepository repository;
  ToggleAudioUsecase(this.repository);

  @override
  Future<Either<Failure, Success<void>>> call(ToggleAudioParams params) {
    return repository.toggleAudio(producerId: params.producerId, pause: params.pause);
  }
}

class ToggleAudioParams extends Equatable {
  final String producerId;

  /// True to pause (mute); false to resume.
  final bool pause;

  const ToggleAudioParams({required this.producerId, required this.pause});

  @override
  List<Object?> get props => [producerId, pause];
}

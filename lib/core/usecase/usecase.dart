import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';
import 'success.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Success<Type>>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

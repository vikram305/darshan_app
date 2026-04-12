import 'package:equatable/equatable.dart';

sealed class FetcherState<T> extends Equatable {
  const FetcherState();

  @override
  List<Object?> get props => [];
}

class FetcherInitial<T> extends FetcherState<T> {
  const FetcherInitial();
}

class FetcherLoading<T> extends FetcherState<T> {
  const FetcherLoading();
}

class FetcherSuccess<T> extends FetcherState<T> {
  final T data;
  const FetcherSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class FetcherFailure<T> extends FetcherState<T> {
  final String message;
  const FetcherFailure(this.message);

  @override
  List<Object?> get props => [message];
}

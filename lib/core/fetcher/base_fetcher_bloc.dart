import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';
import '../usecase/success.dart';
import '../usecase/filter.dart';
import 'fetcher_event.dart';
import 'fetcher_state.dart';

abstract class BaseFetcherBloc<T> extends Bloc<FetcherEvent, FetcherState<T>> {
  BaseFetcherBloc() : super(const FetcherInitial<T>()) {
    on<FetchData>(
      (event, emit) async {
        emit(FetcherLoading<T>());

        final result = await operation(filter: event.filter ?? const NoFilter());
        if (isClosed) return;

        result.fold(
          (failure) => emit(FetcherFailure<T>(failure.message)),
          (success) => emit(FetcherSuccess<T>(success.data)),
        );
      },
    );
  }

  /// Override this to hook up the specific usecase logic
  Future<Either<Failure, Success<T>>> operation({required Filter filter});
}

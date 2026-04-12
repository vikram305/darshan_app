import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_ui_state.dart';

abstract class BaseUiCubit<T, State extends BaseUiState<T>> extends Cubit<State> {
  BaseUiCubit(State initialState) : super(initialState);

  /// Called when the FetcherBloc succeeds. Saves the raw API payload to both references.
  void initializeData(T data) {
     emit(state.copyWith(originalData: data, viewData: data) as State);
  }
  
  /// Reverts any filtered viewData back to the original payload
  void resetFilters() {
     emit(state.copyWith(viewData: state.originalData) as State);
  }
}

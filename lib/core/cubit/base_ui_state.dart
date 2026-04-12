import 'package:equatable/equatable.dart';

abstract class BaseUiState<T> extends Equatable {
  final T? originalData;
  final T? viewData;

  const BaseUiState({this.originalData, this.viewData});

  /// Abstract copyWith to enforce child classes to properly implement it so UI filtering works
  BaseUiState<T> copyWith({T? originalData, T? viewData});

  @override
  List<Object?> get props => [originalData, viewData];
}

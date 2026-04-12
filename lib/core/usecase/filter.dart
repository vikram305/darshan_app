import 'package:equatable/equatable.dart';

abstract class Filter extends Equatable {
  const Filter();
}

class NoFilter extends Filter {
  const NoFilter();
  @override
  List<Object?> get props => [];
}

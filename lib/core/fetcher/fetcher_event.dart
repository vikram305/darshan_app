import 'package:equatable/equatable.dart';
import '../usecase/filter.dart';

abstract class FetcherEvent extends Equatable {
  const FetcherEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchData extends FetcherEvent {
  final Filter? filter;
  const FetchData({this.filter});

  @override
  List<Object?> get props => [filter];
}

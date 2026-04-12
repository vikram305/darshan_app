import 'package:equatable/equatable.dart';

class Success<T> extends Equatable {
  final T data;
  final String? message;
  
  const Success(this.data, {this.message});
  
  @override
  List<Object?> get props => [data, message];
}

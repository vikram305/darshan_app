import '../../../../core/usecase/filter.dart';

class CreateRoomFilter extends Filter {
  final String displayName;
  const CreateRoomFilter({required this.displayName});

  @override
  List<Object?> get props => [displayName];
}

class JoinRoomFilter extends Filter {
  final String roomId;
  final String displayName;
  const JoinRoomFilter({required this.roomId, required this.displayName});

  @override
  List<Object?> get props => [roomId, displayName];
}

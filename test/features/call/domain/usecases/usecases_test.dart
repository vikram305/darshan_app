// ignore_for_file: lines_longer_than_80_chars
import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/repositories/call_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

@GenerateMocks([CallRepository])
void main() {}

// Separate entrypoint so @GenerateMocks only needs to appear once.
// All individual usecase groups call runUsecaseTests(MockCallRepository).
// See: usecases_test.dart — this file is the annotation anchor only.

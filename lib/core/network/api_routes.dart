import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiRoutes {
  ApiRoutes._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? "http://localhost:3000/api";
  static const String roomPath = "/call/room";
}

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/network/api_service.dart';
import 'features/call/call_injection.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ApiService(sl()));

  // Features
  initCallFeature(sl);
}


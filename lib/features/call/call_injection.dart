import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/call_remote_data_source.dart';
import 'data/datasources/socket_call_remote_datasource_impl.dart';
import 'data/datasources/media_data_source.dart';
import 'data/datasources/media_data_source_impl.dart';
import 'data/repositories/call_repository_impl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'domain/repositories/call_repository.dart';
import 'domain/usecases/create_room_usecase.dart';
import 'domain/usecases/join_room_usecase.dart';
import 'domain/usecases/leave_room_usecase.dart';
import 'domain/usecases/produce_media_usecase.dart';
import 'domain/usecases/consume_media_usecase.dart';
import 'domain/usecases/toggle_audio_usecase.dart';
import 'domain/usecases/toggle_camera_usecase.dart';
import 'domain/usecases/switch_camera_usecase.dart';
import 'domain/usecases/init_local_media_usecase.dart';
import 'presentation/bloc/call_fetcher_bloc.dart';
import 'presentation/cubit/call_ui_cubit.dart';

void initCallFeature(GetIt sl) {
  // BLoCs
  sl.registerFactory(() => CallFetcherBloc(
        createRoomUsecase: sl(),
        joinRoomUsecase: sl(),
      ));
  sl.registerFactory(() => CallUiCubit(
        initLocalMediaUsecase: sl(),
        switchCameraUsecase: sl(),
        consumeMediaUsecase: sl(),
        repository: sl(),
      ));


  // UseCases
  sl.registerLazySingleton(() => CreateRoomUsecase(sl()));
  sl.registerLazySingleton(() => JoinRoomUsecase(sl()));
  sl.registerLazySingleton(() => LeaveRoomUsecase(sl()));
  sl.registerLazySingleton(() => ProduceMediaUsecase(sl()));
  sl.registerLazySingleton(() => ConsumeMediaUsecase(sl()));
  sl.registerLazySingleton(() => ToggleAudioUsecase(sl()));
  sl.registerLazySingleton(() => ToggleCameraUsecase(sl()));
  sl.registerLazySingleton(() => SwitchCameraUsecase(sl()));
  sl.registerLazySingleton(() => InitLocalMediaUsecase(sl()));

  // Repository
  sl.registerLazySingleton<CallRepository>(() => CallRepositoryImpl(
        remoteDataSource: sl(),
        mediaDataSource: sl(),
        networkInfo: sl(),
      ));

  // DataSources
  sl.registerLazySingleton<io.Socket>(() {
    return io.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  });

  sl.registerLazySingleton<CallRemoteDataSource>(
      () => SocketCallRemoteDataSourceImpl(sl()));
      
  sl.registerLazySingleton<MediaDataSource>(
      () => MediaDataSourceImpl());

  // External
  if (!sl.isRegistered<InternetConnectionChecker>()) {
    sl.registerLazySingleton(() => InternetConnectionChecker());
  }
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  }
}

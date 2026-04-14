# Architecture Prompt — Flutter Clean Architecture

> Feed this file as context to any AI tool when working on this project.
> This is the compact version (~150 lines). Full details: `ARCHITECTURE_GUIDELINES.md`

## 🤖 AI SYSTEM INSTRUCTIONS (STRICT)
1. **Output ONLY Dart Code**: No conversational filler, no polite greetings, no step-by-step breakdowns. Only file paths and code blocks.
2. **Strict TDD Automation**: When you generate a file in the Domain, Data, or Presentation layers, you MUST automatically generate its corresponding unit test file immediately after. Do not wait for the user to ask for tests.
3. Use shared test constants from `test/features/<feature>/utils/<feature>_test_constants.dart`.

---

## Architecture: Clean Architecture + DDD + BLoC

Three layers, dependencies point **inward only**:
- **Presentation** → Domain → Data
- Domain has ZERO framework dependencies

## File Creation Order (New Feature)

For a feature called `profile`:

```
1. lib/features/profile/domain/entities/profile.dart           → Equatable, const constructor
2. lib/features/profile/domain/repositories/profile_repo.dart  → Abstract, returns Either<Failure, Success<T>>
3. lib/features/profile/domain/usecases/get_profile.dart       → Extends UseCase<Type, Params>
4. lib/features/profile/domain/utils/profile_mapper.dart       → Model → Entity (static methods)
5. lib/features/profile/data/models/profile_model.dart         → @JsonSerializable, fromJson/toJson
   → Run: dart run build_runner build --delete-conflicting-outputs
6. lib/features/profile/data/datasource/profile_remote_ds.dart → Abstract contract
7. lib/features/profile/data/datasource_impl/profile_remote_ds_impl.dart → Uses ApiService
8. lib/features/profile/data/repositories/profile_repo_impl.dart → Checks network, catches exceptions
9. lib/features/profile/presentation/constants/profile_strings.dart → All UI text
10. (Optional) lib/features/profile/presentation/constants/profile_routes.dart
11. lib/features/profile/presentation/cubit/profile_state.dart  → Extends BaseUiState<T>
12. lib/features/profile/presentation/cubit/profile_cubit.dart  → Extends BaseUiCubit<T>
13. lib/features/profile/presentation/fetcher/profile_fetcher.dart → Extends BaseFetcherBloc<T>
14. lib/features/profile/presentation/ui/profile_page.dart      → BlocBuilder for Cubit & Listener for Fetcher
14. lib/features/profile/profile_injection.dart                 → Feature DI registration
15. lib/features/profile/profile.dart                           → Barrel export (public UI/UseCases)
16. lib/injection_container.dart → Call initProfileFeature(locator)
17. test/features/profile/... → Mirror lib/ structure (TDD Strict)
```

## Rules Per Layer

### Entity (domain/entities/)
- Pure Dart, `extends Equatable`, `const` constructor
- No fromJson/toJson, no framework imports

### Repository Contract (domain/repositories/)
- Abstract class, returns `Future<Either<Failure, Success<T>>>`, never throws

### UseCase (domain/usecases/)
- `extends UseCase<ReturnType, ParamType>`, single `call()` method
- Params class: `extends Equatable`, `const` constructor
- If Params shared by 2+ usecases → extract to `usecases/params/` folder

### Mapper (domain/utils/)
- Static methods or const instance, converts Model → Entity
- Never Entity → Model

### Model (data/models/)
- `@JsonSerializable()`, `extends Equatable`
- Has `fromJson` factory + `toJson` method
- Requires code generation (build_runner)

### DataSource (data/datasource/ + datasource_impl/)
- Abstract contract separate from implementation
- Throws `ServerException` on error, never returns null
- Uses `ApiService` for HTTP calls

### Repository Implementation (data/repositories/)
- Checks `networkInfo.isConnected` before API call
- Catches `ServerException` → returns `Left(ServerFailure(...))`
- No internet → returns `Left(InternetFailure())`
- Uses Mapper to convert Model → Entity

### Presentation State (presentation/cubit/ & presentation/fetcher/)
- **API Fetching**: Extend `BaseFetcherBloc<T>`, implement `operation()` mapped purely to sealed classes.
- **UI Memory**: Extend `BaseUiCubit<T, State>`. Use `originalData` and `viewData` logic natively inherited to persist list states smoothly.
- **Handshake**: Screen sets `BlocListener` on Fetcher → `on Success` → calls `context.read<MyCubit>().initializeData(state.data)`.

### Constants (ZERO HARDCODING)
- `core/constants/app_strings.dart` → error msgs, labels, symbols, units
- `core/constants/app_constants.dart` → spacing, sizes, timeouts, numbers
- `core/constants/app_patterns.dart` → date formats, URL templates, regex
- `features/<name>/presentation/constants/<name>_strings.dart` → feature UI text
- Use template methods for interpolated strings: `static String temp(int t) => '$t\u00B0';`

### DI (injection_container.dart)
- Order: External → Core → Data → Domain → Presentation
- `registerFactory` → BLoCs (new instance per widget)
- `registerLazySingleton` → UseCases, Repos, DataSources
- `registerSingleton` → Helpers, ApiService, external libs

## Error Flow

```
DataSource throws ServerException
  → RepositoryImpl catches → returns Left(ServerFailure)
    → UseCase passes Either through
      → BaseFetcherBloc folds → emits FetcherFailure(message)
```

Failure types: `ServerFailure`, `InternetFailure`, `BadFilterFailure`

## Dual-Tier Lifecycle

```
1. FetchData(filter) → FetcherLoading → operation() → FetcherSuccess(data) / FetcherFailure
2. UI Listener hears FetcherSuccess → calls UiCubit.initializeData(data)
3. UiCubit populates `originalData` and `viewData` flawlessly persisting memory.
```

## Testing Patterns

- **Cubit Testing**: `blocTest<Cubit, State>()` checking `originalData`/`viewData` filtering rules.
- **Fetcher Testing**: `blocTest<Bloc, State>()` asserting pure Dart `sealed` class mapped success/failures.
- Repository: `runTestsOnline()` / `runTestsOffline()` helper groups
- Mocking: `@GenerateMocks([...])` + `build_runner`
- Test constants: `test/features/<name>/utils/` → shared entity instances
- Fixtures: `test/fixtures/*.json` loaded via `fixture_reader.dart`

## Key Dependencies

flutter_bloc, fpdart (Either), equatable, get_it, dio, json_serializable, mockito, bloc_test

## Network

- `ApiService` wraps Dio (get/post/delete/multipart)
- `ApiRoutes` → base URLs, endpoint paths
- `ApiKeys` → query parameter names
- API keys: use `--dart-define` or `.env`, never hardcode

## Theme

- Material 3 with `ColorScheme`, `GoogleFonts`
- Never hardcode colors in widgets → use `Theme.of(context).colorScheme.<token>`

## Helpers

- Static `Util` class (pure, testable) + Injectable `Helper` wrapper (mockable)
- Example: `DateUtil` (static) → `DateHelper` (injectable)

## Documentation Rules

- Use `///` natively for Dart documentation comments instead of standard `//`.
- **Classes/Entities**: Provide a concise summary of the business scope.
- **UseCases**: Document expected input params and any specific `Failure` types that could be returned.
- **Redundancy**: Avoid useless comments like `/// gets user` above a method named `getUser`. Document the *why* or edge-cases, not the obvious *what*.

---

## Reference Example — Complete Feature (Weather)

Below is the **exact code shape** for each layer. Match this pattern precisely.

### Entity
```dart
// lib/features/weather/domain/entities/wind.dart
import 'package:equatable/equatable.dart';

class Wind extends Equatable {
  final double speed;
  final String degree;
  const Wind({required this.speed, required this.degree});
  @override
  List<Object?> get props => [speed, degree];
}
```

### Repository Contract
```dart
// lib/features/weather/domain/repositories/weather_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';

abstract class WeatherRepository {
  Future<Either<Failure, Success<Weather>>> getCurrentWeather({required LocationParam location});
}
```

### UseCase
```dart
// lib/features/weather/domain/usecases/get_weather.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';

class GetWeather extends UseCase<Weather, LocationParam> {
  final WeatherRepository repository;
  GetWeather(this.repository);

  @override
  Future<Either<Failure, Success<Weather>>> call(LocationParam location) async {
    return await repository.getCurrentWeather(location: location);
  }
}

class LocationParam extends Equatable {
  final double latitude;
  final double longitude;
  const LocationParam({required this.latitude, required this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}
```

### Model
```dart
// lib/features/weather/data/models/wind_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'wind_model.g.dart';

@JsonSerializable()
class WindModel extends Equatable {
  final double speed;
  final int deg;
  const WindModel({required this.speed, required this.deg});
  factory WindModel.fromJson(Map<String, dynamic> json) => _$WindModelFromJson(json);
  Map<String, dynamic> toJson() => _$WindModelToJson(this);
  @override
  List<Object?> get props => [speed, deg];
}
```

### DataSource Contract + Impl
```dart
// datasource/weather_remote_datasource.dart
abstract class WeatherRemoteDataSource {
  Future<ApiResponseModel<WeatherDataModel>> getCurrentWeather(LocationParam locationParam);
}

// datasource_impl/weather_remote_datasource_impl.dart
class WeatherRemoteDataSourceImpl extends WeatherRemoteDataSource {
  final ApiService service;
  WeatherRemoteDataSourceImpl(this.service);

  @override
  Future<ApiResponseModel<WeatherDataModel>> getCurrentWeather(LocationParam locationParam) async {
    final response = await service.get(
      "${ApiRoutes.data}${ApiRoutes.version_2_5}${ApiRoutes.weather}",
      params: {latitude: locationParam.latitude, longitude: locationParam.longitude, appId: ApiRoutes.apiKey},
    );
    final apiResponse = ApiResponseModel<WeatherDataModel>.fromJson(
      response.data, (json) => WeatherDataModel.fromJson(json as Map<String, dynamic>),
    );
    if (apiResponse.success && apiResponse.data != null) return apiResponse;
    throw ServerException(apiResponse.message ?? AppStrings.noDataFound);
  }
}
```

### Repository Implementation
```dart
// data/repositories/weather_repository_impl.dart
class WeatherRepositoryImpl extends WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final DateHelper dateHelper;
  final InputHelper inputHelper;
  WeatherRepositoryImpl(this.remoteDataSource, this.networkInfo, this.dateHelper, this.inputHelper);

  @override
  Future<Either<Failure, Success<Weather>>> getCurrentWeather({required LocationParam location}) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await remoteDataSource.getCurrentWeather(location);
        return Right(Success(WeatherMapper.toWeather(res.data!, dateHelper, inputHelper), message: res.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(InternetFailure());
    }
  }
}
```

### Fetcher BLoC
```dart
// presentation/fetcher/weather_fetcher_bloc.dart
class WeatherFetcher extends BaseFetcherBloc<Weather> {
  final GetWeather getWeather;
  WeatherFetcher(this.getWeather);

  @override
  Future<Either<Failure, Success<Weather>>> operation({required Filter filter}) {
    if (filter is LocationFilter) {
      return getWeather.call(LocationParam(latitude: filter.latitude, longitude: filter.longitude));
    }
    return Future.value(Either.left(const BadFilterFailure("Invalid Filter Type")));
  }
}
```

### UI Cubit
```dart
// presentation/cubit/weather_state.dart
class WeatherState extends BaseUiState<Weather> {
  final bool isCelsius;
  const WeatherState({super.originalData, super.viewData, this.isCelsius = true});
  
  @override
  WeatherState copyWith({Weather? originalData, Weather? viewData, bool? isCelsius}) {
    return WeatherState(
      originalData: originalData ?? this.originalData,
      viewData: viewData ?? this.viewData,
      isCelsius: isCelsius ?? this.isCelsius,
    );
  }
}

// presentation/cubit/weather_cubit.dart
class WeatherCubit extends BaseUiCubit<Weather, WeatherState> {
  WeatherCubit() : super(const WeatherState());

  void toggleFormat() {
     emit(state.copyWith(isCelsius: !state.isCelsius));
  }
}
```

### Filter
```dart
// presentation/bloc/location_filter.dart
class LocationFilter extends Filter {
  final double latitude;
  final double longitude;
  const LocationFilter({required this.latitude, required this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}
```

### Feature Strings
```dart
// presentation/constants/weather_strings.dart
class WeatherStrings {
  WeatherStrings._();
  static const sectionNow = 'Now';
  static const wind = 'Wind';
  static String temperature(int temp) => '$temp\u00B0';
  static String highLow(int high, int low) => 'High: $high\u00B0 - Low: $low\u00B0';
  static const noWeatherDataFound = 'No weather data found.';
}
```

### DI Registration
```dart
// injection_container.dart
locator.registerFactory(() => WeatherBloc(locator()));                    // BLoC = Factory
locator.registerLazySingleton(() => GetWeather(locator()));               // UseCase
locator.registerLazySingleton<WeatherRepository>(                         // Repo (abstract type!)
    () => WeatherRepositoryImpl(locator(), locator(), locator(), locator()));
locator.registerLazySingleton<WeatherRemoteDataSource>(                   // DataSource (abstract type!)
    () => WeatherRemoteDataSourceImpl(locator()));
```

### BLoC Test
```dart
@GenerateMocks([GetWeather])
void main() {
  late MockGetWeather mockGetWeather;
  late WeatherBloc bloc;
  setUp(() {
    mockGetWeather = MockGetWeather();
    bloc = WeatherBloc(mockGetWeather);
    provideDummy<Either<Failure, Success<Weather>>>(Right(Success(tWeather)));
  });
  tearDown(() => bloc.close());

  blocTest<WeatherBloc, FetchDataState<Weather>>(
    'emits [loading, success] when data fetched successfully',
    build: () { when(mockGetWeather.call(any)).thenAnswer((_) async => Right(Success(tWeather))); return bloc; },
    act: (bloc) => bloc.add(FetchData(filter: tFilter)),
    expect: () => [
      const FetchDataState<Weather>(status: Status.loading),
      FetchDataState<Weather>(status: Status.success, data: tWeather, filter: tFilter),
    ],
  );
}
```

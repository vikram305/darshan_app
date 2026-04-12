# Flutter Clean Architecture — Reusable Guidelines

> A comprehensive, production-ready guideline for structuring Flutter projects using **Clean Architecture** with **Domain-Driven Design (DDD)**, **BLoC** state management, and **functional error handling**. Derived from a real-world project and designed to be copy-pasted into any new Flutter app.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Folder Structure Template](#2-folder-structure-template)
3. [Core Layer — Reusable Foundations](#3-core-layer--reusable-foundations)
   - 3.1 [BaseBloc (Generic Data-Fetching BLoC)](#31-basebloc-generic-data-fetching-bloc)
   - 3.2 [BLoC Events & States](#32-bloc-events--states)
   - 3.3 [Filter System](#33-filter-system)
   - 3.4 [UseCase Abstraction](#34-usecase-abstraction)
   - 3.5 [Error Handling (Failure & Exception)](#35-error-handling-failure--exception)
   - 3.6 [Network Layer (ApiService)](#36-network-layer-apiservice)
   - 3.7 [Platform Utilities (Network Info)](#37-platform-utilities-network-info)
   - 3.8 [Helpers & Utils Pattern](#38-helpers--utils-pattern)
   - 3.9 [Theme System](#39-theme-system)
   - 3.10 [Constants System (Zero Hardcoding)](#310-constants-system-zero-hardcoding)
4. [Feature Layer — Step-by-Step Guide](#4-feature-layer--step-by-step-guide)
   - 4.1 [Domain — Entities](#41-domain--entities)
   - 4.2 [Domain — Repository Contract](#42-domain--repository-contract)
   - 4.3 [Domain — UseCases](#43-domain--usecases)
   - 4.4 [Domain — Mappers](#44-domain--mappers)
   - 4.5 [Data — Models (JSON Serialization)](#45-data--models-json-serialization)
   - 4.6 [Data — DataSource Contract & Implementation](#46-data--datasource-contract--implementation)
   - 4.7 [Data — Repository Implementation](#47-data--repository-implementation)
   - 4.8 [Presentation — Feature BLoC](#48-presentation--feature-bloc)
   - 4.9 [Presentation — Filter](#49-presentation--filter)
   - 4.10 [Presentation — UI Page](#410-presentation--ui-page)
5. [Dependency Injection](#5-dependency-injection)
6. [App Entry Point (main.dart)](#6-app-entry-point-maindart)
7. [Testing Strategy](#7-testing-strategy)
   - 7.1 [Test Directory Structure](#71-test-directory-structure)
   - 7.2 [BLoC Testing (bloc_test)](#72-bloc-testing-bloc_test)
   - 7.3 [Repository Testing (mockito)](#73-repository-testing-mockito)
   - 7.4 [Test Constants & Fixtures](#74-test-constants--fixtures)
8. [Dependency Stack](#8-dependency-stack)
9. [Checklists](#9-checklists)
   - 9.1 [New Feature Checklist](#91-new-feature-checklist)
   - 9.2 [Code Review Checklist](#92-code-review-checklist)
10. [Data Flow Diagram](#10-data-flow-diagram)
11. [Production Recommendations](#11-production-recommendations)
   - 11.1 [API Key Security](#111-api-key-security)
   - 11.2 [Multi-Event BLoC (Beyond BaseBloc)](#112-multi-event-bloc-beyond-basebloc)
   - 11.3 [Compile-Time Filter Safety](#113-compile-time-filter-safety)
   - 11.4 [Mapper Optimization](#114-mapper-optimization)
   - 11.5 [Offline-First / Local Caching](#115-offline-first--local-caching)
   - 11.6 [Navigation & Routing](#116-navigation--routing)
   - 11.7 [Shared Params File Organization](#117-shared-params-file-organization)
   - 11.8 [PR Review Enforcement](#118-pr-review-enforcement)

---

## 1. Architecture Overview

This architecture follows **Clean Architecture** principles with three concentric layers:

```
┌─────────────────────────────────────────────┐
│               Presentation                  │  ← UI, BLoC, Filters
│  ┌────────────────────────────────────────┐  │
│  │              Domain                    │  │  ← Entities, UseCases, Repository Contracts
│  │  ┌──────────────────────────────────┐  │  │
│  │  │             Data                 │  │  │  ← Models, DataSources, Repository Impl
│  │  └──────────────────────────────────┘  │  │
│  └────────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

**Key Principles:**
- **Dependency Rule:** Inner layers never depend on outer layers. Domain has zero framework dependencies.
- **Abstraction Boundaries:** The Domain layer defines repository *contracts* (abstract classes); the Data layer provides the *implementations*.
- **Functional Error Handling:** All operations return `Either<Failure, T>` from `fpdart` — no raw exceptions leak beyond the Data layer.
- **Single Responsibility BLoC:** Each BLoC handles one data-fetching concern, powered by the reusable `BaseBloc<T>`.

---

## 2. Folder Structure Template

```
lib/
├── core/
│   ├── bloc/
│   │   ├── base_bloc.dart          # Generic data-fetching BLoC
│   │   ├── bloc_events.dart        # FetchDataEvent, FetchData
│   │   ├── bloc_states.dart        # FetchDataState<T>, Status enum
│   │   └── filter.dart             # Filter, NoFilter
│   ├── error/
│   │   ├── exception.dart          # ServerException, BadFilter
│   │   └── failure.dart            # Failure, ServerFailure, InternetFailure
│   ├── constants/
│   │   ├── app_strings.dart        # All user-facing text, error messages, labels
│   │   ├── app_constants.dart      # Magic numbers, dimensions, config values
│   │   └── app_patterns.dart       # Date formats, URL templates, regex patterns
│   ├── extension/
│   │   └── string_extension.dart   # Dart extension methods
│   ├── helper/
│   │   ├── date_helper.dart        # Injectable wrapper for DateUtil
│   │   ├── date_util.dart          # Static date formatting utilities
│   │   ├── input_helper.dart       # Injectable wrapper for InputUtil
│   │   └── input_util.dart         # Static input transformation utilities
│   ├── network/
│   │   ├── api_keys.dart           # Query parameter key constants
│   │   ├── api_routes.dart         # Base URL, endpoint path constants
│   │   ├── api_service.dart        # Dio wrapper (get, post, delete, multipart)
│   │   └── utils/
│   │       ├── certificate_reader.dart    # SSL pinning support
│   │       └── logging_interceptor.dart   # Debug-only request/response logger
│   ├── platform/
│   │   └── network_info.dart       # Internet connectivity checker
│   ├── presentation/
│   │   └── theme/
│   │       └── app_theme.dart      # Material 3 theme with ColorScheme
│   └── usecase/
│       └── usecase.dart            # UseCase<Type, Params>, NoParams
│
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasource/
│       │   │   └── <name>_remote_datasource.dart      # Abstract contract
│       │   ├── datasource_impl/
│       │   │   └── <name>_remote_datasource_impl.dart # Implementation
│       │   ├── models/
│       │   │   ├── <name>_model.dart                   # @JsonSerializable model
│       │   │   └── <name>_model.g.dart                 # Generated code
│       │   └── repositories/
│       │       └── <name>_repository_impl.dart         # Repository implementation
│       ├── domain/
│       │   ├── entities/
│       │   │   └── <name>.dart                         # Pure Dart entity (Equatable)
│       │   ├── repositories/
│       │   │   └── <name>_repository.dart              # Abstract repository contract
│       │   ├── usecases/
│       │   │   └── get_<name>.dart                     # UseCase + Params class
│       │   └── utils/
│       │       └── <name>_mapper.dart                  # Model → Entity mapper
│       └── presentation/
│           ├── bloc/
│           │   ├── <name>_bloc.dart                    # Feature BLoC extending BaseBloc
│           │   └── <name>_filter.dart                  # Feature-specific Filter
│           ├── constants/
│           │   └── <name>_strings.dart                  # Feature-specific UI strings
│           └── ui/
│               ├── <name>_page.dart                    # Page widget
│               └── widgets/
│                   └── <widget_name>.dart              # Reusable widgets
│
├── injection_container.dart          # GetIt DI setup
└── main.dart                         # App entry point

test/
├── core/                             # Mirrors lib/core/
├── features/                         # Mirrors lib/features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasource_impl/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   └── usecases/
│       ├── presentation/
│       │   └── bloc/
│       └── utils/                    # Shared test constants
└── fixtures/
    └── fixture_reader.dart           # JSON fixture loader
```

---

## 3. Core Layer — Reusable Foundations

### 3.1 BaseFetcherBloc (The Isolated Network Worker)

The core networking engine is separated strictly from UI layout memory. `BaseFetcherBloc` leverages Dart 3 sealed classes to prove data retrieval mathematically without caching state.

```dart
// core/fetcher/base_fetcher_bloc.dart
abstract class BaseFetcherBloc<T> extends Bloc<FetcherEvent, FetcherState<T>> {
  BaseFetcherBloc() : super(const FetcherInitial<T>()) {
    on<FetchData>((event, emit) async {
        emit(FetcherLoading<T>());

        final result = await operation(filter: event.filter ?? const NoFilter());
        if (isClosed) return;

        result.fold(
          (l) => emit(FetcherFailure<T>(l.message)),
          (r) => emit(FetcherSuccess<T>(r.data)),
        );
      },
    );
  }

  /// Subclasses only implement this single method.
  Future<Either<Failure, Success<T>>> operation({required Filter filter});
}
```

**States (`fetcher_state.dart`):**
```dart
sealed class FetcherState<T> {}
class FetcherInitial<T> extends FetcherState<T> {}
class FetcherLoading<T> extends FetcherState<T> {}
class FetcherSuccess<T> extends FetcherState<T> { final T data; const FetcherSuccess(this.data); }
class FetcherFailure<T> extends FetcherState<T> { final String message; const FetcherFailure(this.message); }
```

---

### 3.2 BaseUiCubit (The Memory Cache)

The UI holds state via `BaseUiCubit`, which ensures filters run dynamically across `originalData` locally to preserve memory.

```dart
// core/cubit/base_ui_state.dart
abstract class BaseUiState<T> extends Equatable {
  final T? originalData;
  final T? viewData;

  const BaseUiState({this.originalData, this.viewData});
  BaseUiState<T> copyWith({T? originalData, T? viewData});
  
  @override
  List<Object?> get props => [originalData, viewData];
}

// core/cubit/base_ui_cubit.dart
abstract class BaseUiCubit<T, State extends BaseUiState<T>> extends Cubit<State> {
  BaseUiCubit(State initialState) : super(initialState);

  void initializeData(T data) {
     emit(state.copyWith(originalData: data, viewData: data) as State);
  }
}
```

**Usage in UI (The Handshake):**
```dart
BlocListener<WeatherFetcher, FetcherState<Weather>>(
  listener: (context, state) {
    if (state is FetcherSuccess<Weather>) {
       context.read<WeatherCubit>().initializeData(state.data);
    }
  },
  child: BlocBuilder<WeatherCubit, WeatherState>(
     builder: (context, state) => WeatherView(data: state.viewData),
  ),
)
```

---

### 3.3 Filter System

Filters pass contextual parameters from UI events down to the `operation()` method.

```dart
// Core abstraction
abstract class Filter extends Equatable {
  const Filter();
}

class NoFilter extends Filter {
  const NoFilter();
  @override
  List<Object?> get props => [];
}

// Feature-specific filter (lives in presentation/bloc/)
class LocationFilter extends Filter {
  final double latitude;
  final double longitude;
  const LocationFilter({required this.latitude, required this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}
```

**Dispatching with a filter:**
```dart
context.read<WeatherBloc>().add(
  const FetchData(
    filter: LocationFilter(latitude: 23.03, longitude: 72.56),
  ),
);
```

---

### 3.4 UseCase Abstraction

Each UseCase represents a single action the app can perform.

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Success<Type>>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

**Concrete example:**
```dart
class GetWeather extends UseCase<Weather, LocationParam> {
  final WeatherRepository repository;
  GetWeather(this.repository);

  @override
  Future<Either<Failure, Weather>> call(LocationParam location) async {
    return await repository.getCurrentWeather(location: location);
  }
}

// Params class — always use Equatable for testability
class LocationParam extends Equatable {
  final double latitude;
  final double longitude;
  const LocationParam({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
```

---

### 3.5 Network Messages (Success & Failure)

An API often returns a standard wrapper like `{ "success": true, "message": "Saved!", "data": {...} }`. It is critical to properly propagate dynamic server messages (for both success and failures) up to the UI.

**1. Preserving Dynamic Success Messages (Option A - The Success Wrapper):**
Instead of returning just the raw entity (which drops the server message), wrap your domain responses in a `Success<T>` object:

```dart
// core/usecase/success.dart
class Success<T> extends Equatable {
  final T data;
  final String? message;
  
  const Success(this.data, {this.message});
  
  @override
  List<Object?> get props => [data, message];
}
```
Now, Repositories and UseCases should return `Future<Either<Failure, Success<T>>>`. The DataSource passes the server message into this wrapper so the UI receives it.

**2. Preserving Dynamic Error Messages:**
This happens automatically through a two-tier error model:

| Layer | Type | Purpose |
|-------|------|---------|
| Data | `Exception` | Thrown by DataSources catching `apiResponse.message` |
| Domain/Presentation | `Failure` (sealed via `Either`) | Consumed by Repository → UseCase → BLoC |

```dart
// Exceptions (Data layer throws these)
class ServerException implements Exception {
  final String message; // <-- The dynamic server message
  ServerException(this.message);
}

// Failures (Repository catches ServerException, returns Failure via Either.left)
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
  @override
  List<Object?> get props => [message];
}
```

**Pattern Pipeline:**
1. `DataSource` parses the JSON, sees `success: false`, and throws `ServerException(apiResponse.message)`
2. `RepositoryImpl` strictly catches it, returns `Left(ServerFailure(e.message))`
3. `UseCase` passes the `Either` through unchanged
4. `BaseBloc` folds the `Left` and emits a failure state holding `failure.message`
5. `UI` displays `state.errorMessage` in a Snackbar.

---

### 3.6 Network Layer (ApiService)

A `Dio`-based HTTP client with standardized configuration.

```dart
class ApiService {
  late final Dio _dio;

  ApiService(this._dio) {
    _initApiService();
  }

  _initApiService() {
    _dio.options = BaseOptions(
      baseUrl: ApiRoutes.baseUrl,
      responseType: ResponseType.json,
      contentType: 'application/json',
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    );
    addInterceptors();
  }

  addInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
    // Add auth interceptor, token refresh, etc. here
  }

  Future<Response> get(String endUrl, {Map<String, dynamic>? params, ...}) async { ... }
  Future<Response> post(String endUrl, {Map<String, dynamic>? data, ...}) async { ... }
  Future<Response> delete(String endUrl, {Map<String, dynamic>? data, ...}) async { ... }
  Future<Response> multipartPost(String endUrl, {required FormData data, ...}) async { ... }
}
```

**API Routes — centralize all endpoints:**
```dart
class ApiRoutes {
  static const baseUrl = "https://api.example.com";
  static const version = "/v1";
  static const users = "/users";
  // Compose: "${ApiRoutes.version}${ApiRoutes.users}"
}
```

**API Keys — centralize query parameter names:**
```dart
const latitude = "lat";
const longitude = "lon";
const appId = "appid";
```

---

### 3.7 Platform Utilities (Network Info)

```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl extends NetworkInfo {
  final InternetConnection internetConnection;
  NetworkInfoImpl(this.internetConnection);

  @override
  Future<bool> get isConnected => internetConnection.hasInternetAccess;
}
```

Used by repository implementations to check connectivity before API calls.

---

### 3.8 Helpers & Utils Pattern

**Pattern:** Static `Util` classes hold pure logic. Injectable `Helper` classes wrap them.

```
┌──────────────┐    wraps    ┌──────────────┐
│  DateHelper   │ ────────→  │   DateUtil    │  (static methods, private constructor)
│  (injectable) │            │   (pure)      │
└──────────────┘            └──────────────┘
```

**Why?**
- `DateUtil` is easy to unit test (static, pure functions)
- `DateHelper` is easy to **mock** in repository/BLoC tests via Mockito
- This decouples business logic from test infrastructure

```dart
// Pure static utility
class DateUtil {
  DateUtil._(); // Private constructor — cannot be instantiated

  static const timeFormat = "hh:mm a";

  static String getFormattedDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
  // ...
}

// Injectable wrapper
class DateHelper {
  String getFormattedDate(DateTime date, String format) {
    return DateUtil.getFormattedDate(date, format);
  }
  String get timeFormat => DateUtil.timeFormat;
  // ...
}
```

---

### 3.9 Theme System

Uses Material 3 with `ColorScheme` and Google Fonts.

```dart
class AppTheme {
  const AppTheme();

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surface: Color(0xff111318),
      // ... full scheme
    );
  }

  ThemeData dark() => theme(darkScheme());

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}
```

**Best practices:**
- Define `light()`, `dark()`, and contrast variants
- Keep all color values in `ColorScheme` — never hardcode colors in widgets
- Use `Theme.of(context).colorScheme.<token>` everywhere in UI

---

### 3.10 Constants System (Zero Hardcoding)

**Rule: Nothing is hardcoded directly.** Every string, number, pattern, and regex lives in a constants file.

#### Constant File Categories

| File | Location | What Goes Here |
|------|----------|----------------|
| `AppStrings` | `core/constants/app_strings.dart` | Error messages, general labels, symbols, units |
| `AppConstants` | `core/constants/app_constants.dart` | Magic numbers, dimensions, timeouts, layout values |
| `AppPatterns` | `core/constants/app_patterns.dart` | Date formats, URL templates, regex patterns |
| `<Feature>Strings` | `features/<name>/presentation/constants/` | Feature-specific UI text |

#### AppStrings — User-Facing Text

```dart
class AppStrings {
  AppStrings._();

  // ── General ──
  static const appTitle = 'My App';

  // ── Error Messages ──
  static const somethingWentWrong = 'Something went wrong';
  static const noDataFound = 'No data found';

  // ── Date Labels ──
  static const today = 'Today';
  static const yesterday = 'Yesterday';

  // ── Symbols & Units ──
  static const degreeSymbol = '\u00B0';
  static const percentSymbol = '%';
  static const kmPerHour = 'km/h';
  static const milliBar = 'mBar';
}
```

**Usage:**
```dart
// ❌ Bad
Text("Something went wrong");

// ✅ Good
Text(AppStrings.somethingWentWrong);
```

#### AppConstants — Numeric Values

```dart
class AppConstants {
  AppConstants._();

  // ── Network ──
  static const connectionTimeoutMinutes = 1;
  static const httpStatusOkMin = 200;
  static const httpStatusOkMax = 300;

  // ── Image Sizes ──
  static const weatherImageSize = 64.0;
  static const weatherImageSmall = 40.0;
  static const defaultIconSize = 32.0;

  // ── Spacing ──
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 10.0;
  static const spacingL = 12.0;
  static const spacingXL = 16.0;
  static const spacingXXL = 20.0;
  static const spacingXXXL = 24.0;

  // ── Font Sizes ──
  static const fontSizeSmall = 12.0;
  static const fontSizeMedium = 14.0;
  static const fontSizeLarge = 16.0;
}
```

**Usage:**
```dart
// ❌ Bad
const SizedBox(height: 20);
Icon(Icons.air, size: 32);

// ✅ Good
const SizedBox(height: AppConstants.spacingXXL);
Icon(Icons.air, size: AppConstants.defaultIconSize);
```

#### AppPatterns — Formats, URLs & Regex

```dart
class AppPatterns {
  AppPatterns._();

  // ── Date Formats ──
  static const dateFormat = 'MMMM dd,y hh:mm a';
  static const timeFormat = 'hh:mm a';
  static const hourFormat = 'h a';
  static const dayFormat = 'd/M';

  // ── URL Templates ──
  static String weatherIconUrl(String iconCode) =>
      '$_iconBaseUrl$_iconPath/$iconCode$_iconScale$_iconExtension';

  static const _iconBaseUrl = 'https://openweathermap.org';
  static const _iconPath = '/img/wn';
  static const _iconScale = '@2x';
  static const _iconExtension = '.png';

  // ── Regex ──
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  static final strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
  static final urlRegex = RegExp(r'https?://[^\s/$.?#].[^\s]*', caseSensitive: false);
}
```

**Usage:**
```dart
// ❌ Bad
DateFormat("hh:mm a").format(date);
if (RegExp(r'^[a-zA-Z0-9._%+-]+@...').hasMatch(email)) { ... }

// ✅ Good
DateFormat(AppPatterns.timeFormat).format(date);
if (AppPatterns.emailRegex.hasMatch(email)) { ... }
```

#### Feature-Specific Strings

Live inside the feature's presentation layer:

```dart
// lib/features/weather/presentation/constants/weather_strings.dart
class WeatherStrings {
  WeatherStrings._();

  static const sectionNow = 'Now';
  static const sectionCurrentConditions = 'Current Conditions';
  static const sectionForecast = 'Forecast';
  static const wind = 'Wind';
  static const humidity = 'Humidity';
  static const pressure = 'Pressure';
  static const sunriseAndSunset = 'Sunrise & Sunset';

  // ── Templates ──
  static String temperature(int temp) => '$temp\u00B0';
  static String highLow(int high, int low) => 'High: $high\u00B0 - Low: $low\u00B0';
  static String feelsLike(int temp) => 'Feels like $temp\u00B0';
  static String fromDirection(String dir) => 'From $dir';

  static const noWeatherDataFound = 'No weather data found.';
}
```

**Usage:**
```dart
// ❌ Bad
Text("${condition.temperature}\u00B0");
Text("High: ${max}\u00B0 - Low: ${min}\u00B0");

// ✅ Good
Text(WeatherStrings.temperature(condition.temperature));
Text(WeatherStrings.highLow(max, min));
```

#### Constants Rules

1. **Private constructor** — `ClassName._()` prevents instantiation
2. **All `static`** — accessed via `ClassName.constant`, no instance needed
3. **Use template methods** for strings with interpolation (e.g., `temperature(int temp)`)
4. **Feature strings stay in the feature** — don't pollute `AppStrings` with feature-specific text
5. **Core strings are shared** — error messages, units, symbols used across features
6. **Regex patterns are `final`** — compiled once, reused everywhere
7. **Prepares for i18n** — when you need localization, you only change the constants files

---

## 4. Feature Layer — Step-by-Step Guide

### 4.1 Domain — Entities

Pure Dart classes with no framework dependencies. Use `Equatable` for value equality.

```dart
class Weather extends Equatable {
  final CoOrdinate coOrdinate;
  final WeatherDetail weatherDetail;
  final Condition condition;
  final Wind wind;
  final SunDetail sunDetail;
  final String city;

  const Weather({
    required this.coOrdinate,
    required this.weatherDetail,
    required this.condition,
    required this.wind,
    required this.sunDetail,
    required this.city,
  });

  @override
  List<Object?> get props => [coOrdinate, weatherDetail, condition, wind, sunDetail, city];
}
```

**Rules:**
- Always `const` constructors when possible
- Always extend `Equatable`
- No `fromJson` / `toJson` — that belongs in the Data layer models

---

### 4.2 Domain — Repository Contract

```dart
abstract class WeatherRepository {
  Future<Either<Failure, Success<Weather>>> getCurrentWeather({required LocationParam location});
  Future<Either<Failure, Success<List<ForecastWeather>>>> getWeatherForecast({required LocationParam location});
}
```

**Rules:**
- Always return `Either<Failure, T>` — never throw
- Reference only Domain entities and core types

---

### 4.3 Domain — UseCases

One UseCase = one action. Extends `UseCase<ReturnType, ParamType>`.

```dart
class GetWeather extends UseCase<Weather, LocationParam> {
  final WeatherRepository repository;
  GetWeather(this.repository);

  @override
  Future<Either<Failure, Weather>> call(LocationParam location) async {
    return await repository.getCurrentWeather(location: location);
  }
}
```

---

### 4.4 Domain — Mappers

Convert data layer models into domain entities. Lives in `domain/utils/`.

```dart
class WeatherMapper {
  Weather toWeather(
    WeatherDataModel model,
    DateHelper dateHelper,
    InputHelper inputHelper,
  ) {
    return Weather(
      coOrdinate: CoOrdinate(latitude: model.coord.lat, longitude: model.coord.lon),
      condition: Condition(
        temperature: model.main.temp.round(),
        // ...
      ),
      // ...
    );
  }
}
```

**Why Mappers?**
- Decouples API response structure from domain model
- Lets you change API without touching domain
- Keeps formatting/transformation logic in one place

---

### 4.5 Data — Models & Common API Response

To handle our standardized API format (`{ success, message, data }`), create a generic wrapper in `core/network/api_response_model.dart`.

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'api_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseModelFromJson(json, fromJsonT);

  @override
  List<Object?> get props => [success, message, data];
}
```

Then for specific feature data models, use `json_serializable` as normal:

```dart
@JsonSerializable()
class WeatherDataModel extends Equatable {
  final CoordModel coord;
  final List<WeatherModel> weather;
  final MainModel main;
  // ...

  const WeatherDataModel({required this.coord, required this.weather, required this.main});

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataModelFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'coord': coord.toJson(),
      'weather': weather.map((x) => x.toJson()).toList(),
      // ...
    };
  }

  @override
  List<Object?> get props => [coord, weather, main];
}
```

**Generate code:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### 4.6 Data — DataSource Contract & Implementation

**Contract (abstract):**
```dart
abstract class WeatherRemoteDataSource {
  /// Throws [ServerException] for all error codes.
  Future<ApiResponseModel<WeatherDataModel>> getCurrentWeather(LocationParam locationParam);
}
```

**Implementation:**
The DataSource is where the `ApiResponseModel` wrapper is unwrapped. Once unwrapped, it simply returns the nested DataModel so the downstream Mappers remain unmodified.

```dart
class WeatherRemoteDataSourceImpl extends WeatherRemoteDataSource {
  final ApiService service;
  WeatherRemoteDataSourceImpl(this.service);

  @override
  Future<ApiResponseModel<WeatherDataModel>> getCurrentWeather(LocationParam locationParam) async {
    final response = await service.get(
      "${ApiRoutes.data}${ApiRoutes.version_2_5}${ApiRoutes.weather}",
      params: {
        'lat': locationParam.latitude,
        'lon': locationParam.longitude,
        'appid': ApiRoutes.apiKey,
        'units': 'metric',
      },
    );
    
    // 1. Unwrap the standard { success, message, data } response
    final apiResponse = ApiResponseModel<WeatherDataModel>.fromJson(
      response.data,
      (json) => WeatherDataModel.fromJson(json as Map<String, dynamic>),
    );

    // 2. Validate success and return the ENTIRE wrapper
    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse;
    } else {
      throw ServerException(apiResponse.message ?? "No data found");
    }
  }
}
```

---

### 4.7 Data — Repository Implementation

The repository bridges Data and Domain. It:
1. Checks connectivity
2. Calls the datasource
3. Maps models → entities
4. Catches exceptions → returns `Either<Failure, T>`

```dart
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
        var res = await remoteDataSource.getCurrentWeather(location);
        return Right(Success(WeatherMapper().toWeather(res.data!, dateHelper, inputHelper), message: res.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(InternetFailure());
    }
  }
}
```

---

### 4.8 Presentation — Feature BLoC

Simply extend `BaseBloc<T>` and implement `operation()`.

```dart
class WeatherBloc extends BaseBloc<Weather> {
  final GetWeather getWeather;
  WeatherBloc(this.getWeather);

  @override
  Future<Either<Failure, Success<Weather>>> operation({required Filter filter}) {
    if (filter is LocationFilter) {
      return getWeather.call(
        LocationParam(latitude: filter.latitude, longitude: filter.longitude),
      );
    }
    return Future.value(Either.left(const BadFilterFailure()));
  }
}
```

That's it. No boilerplate loading/success/failure handling. The `BaseBloc` does it all.

---

### 4.9 Presentation — Filter

```dart
class LocationFilter extends Filter {
  final double latitude;
  final double longitude;
  const LocationFilter({required this.latitude, required this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}
```

---

### 4.10 Presentation — UI Page

```dart
class WeatherPage extends StatefulWidget { ... }

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherBloc>().add(const FetchData(
        filter: LocationFilter(latitude: 23.03, longitude: 72.56),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WeatherBloc, FetchDataState<Weather>>(
        listener: (context, state) { /* Side effects: snackbars, navigation */ },
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.data == null) {
            return const Text("No data found.");
          }
          return WeatherView(weather: state.data!);
        },
      ),
    );
  }
}
```

---

## 5. Dependency Injection

Using `get_it` for service location. Register dependencies **bottom-up** (external → core → data → domain → presentation).

```dart
final locator = GetIt.instance;

Future<void> init() async {
  // ── External ──
  locator.registerSingleton(InternetConnection());

  // ── Core ──
  locator.registerSingleton(DateHelper());
  locator.registerSingleton(InputHelper());
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(locator()));
  locator.registerSingleton(ApiService(Dio()));

  // ── Feature: Weather ──

  // BLoC (Factory — new instance each time)
  locator.registerFactory(() => WeatherBloc(locator()));
  locator.registerFactory(() => ForecastWeatherBloc(locator()));

  // UseCase (LazySingleton)
  locator.registerLazySingleton(() => GetWeather(locator()));
  locator.registerLazySingleton(() => GetWeatherForecast(locator()));

  // Repository (LazySingleton, register with abstract type)
  locator.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(locator(), locator(), locator(), locator()),
  );

  // DataSource (LazySingleton, register with abstract type)
  locator.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(locator()),
  );
}
```

**Registration rules:**

| Type | When to use |
|------|-------------|
| `registerFactory` | BLoCs — fresh instance per widget |
| `registerLazySingleton` | UseCases, Repositories, DataSources |
| `registerSingleton` | External libs, Helpers |

---

## 6. App Entry Point (main.dart)

```dart
void main() async {
  await di.init();
  await locator.allReady(); // Wait for async singletons
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: AppTheme().dark(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => locator<WeatherBloc>()),
          BlocProvider(create: (_) => locator<ForecastWeatherBloc>()),
        ],
        child: const WeatherPage(),
      ),
    );
  }
}
```

---

## 7. Testing Strategy

### 7.1 Test Directory Structure

Mirrors `lib/` exactly:
```
test/
├── core/
│   ├── error/
│   ├── helper/          # date_helper_test, input_helper_test
│   ├── network/         # api_service_test
│   └── platform/        # network_info_test
├── features/
│   └── weather/
│       ├── data/
│       │   ├── datasource_impl/   # datasource_impl_test
│       │   ├── models/            # model_test (fromJson, toJson)
│       │   └── repositories/      # repository_impl_test
│       ├── domain/
│       │   └── usecases/          # usecase_test
│       ├── presentation/
│       │   └── bloc/              # bloc_test
│       └── utils/                 # Shared test constants
└── fixtures/
    ├── fixture_reader.dart
    └── *.json                     # API response fixtures
```

---

### 7.2 FetcherBloc Testing (bloc_test)

```dart
@GenerateMocks([GetWeather, Failure])
void main() {
  late MockGetWeather mockGetWeather;
  late WeatherFetcher bloc;
  late LocationFilter tFilter;

  setUp(() {
    mockGetWeather = MockGetWeather();
    bloc = WeatherFetcher(mockGetWeather);
    tFilter = const LocationFilter(latitude: 23.03, longitude: 72.56);
  });

  tearDown(() => bloc.close());

  blocTest<WeatherFetcher, FetcherState<Weather>>(
    'emits [loading, success] when data is fetched successfully',
    build: () {
      when(mockGetWeather.call(any)).thenAnswer((_) async => Right(Success(tWeather)));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchData(filter: tFilter)),
    expect: () => [
      FetcherLoading<Weather>(),
      FetcherSuccess<Weather>(tWeather),
    ],
  );

  blocTest<WeatherFetcher, FetcherState<Weather>>(
    'emits [loading, failure] when data fetch fails',
    build: () {
      when(mockGetWeather.call(any)).thenAnswer((_) async => const Left(ServerFailure('Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchData(filter: tFilter)),
    expect: () => [
      FetcherLoading<Weather>(),
      const FetcherFailure<Weather>('Error'),
    ],
  );
}
```

---

### 7.3 UiCubit Testing (bloc_test)

```dart
void main() {
  late WeatherCubit cubit;

  setUp(() {
    cubit = WeatherCubit();
  });

  tearDown(() => cubit.close());

  blocTest<WeatherCubit, WeatherState>(
    'populates originalData and viewData when initializeData is called',
    build: () => cubit,
    act: (cubit) => cubit.initializeData(tWeather),
    expect: () => [
      WeatherState(originalData: tWeather, viewData: tWeather),
    ],
  );
  
  blocTest<WeatherCubit, WeatherState>(
    'toggles temperature format locally retaining data values',
    build: () => cubit..initializeData(tWeather),
    act: (cubit) => cubit.toggleFormat(),
    expect: () => [
      WeatherState(originalData: tWeather, viewData: tWeather, isCelsius: !cubit.state.isCelsius),
    ],
  );
}
```

---

### 7.3 Repository Testing (mockito)

```dart
@GenerateMocks([WeatherRemoteDataSource, NetworkInfo, DateHelper, InputHelper])
void main() {
  // Setup & test helpers:
  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  runTestsOnline(() {
    test('returns Weather when remote call succeeds', () async {
      when(mockDataSource.getCurrentWeather(any)).thenAnswer((_) async => tModel);
      final result = await repository.getCurrentWeather(location: tParam);
      expect(result.fold((l) => l, (r) => r), equals(tWeather));
    });

    test('returns ServerFailure when remote call throws', () async {
      when(mockDataSource.getCurrentWeather(any))
          .thenThrow(ServerException("error"));
      final result = await repository.getCurrentWeather(location: tParam);
      expect(result.fold((l) => l, (r) => r), isA<ServerFailure>());
    });
  });

  runTestsOffline(() {
    test('returns InternetFailure when offline', () async {
      final result = await repository.getCurrentWeather(location: tParam);
      expect(result.fold((l) => l, (r) => r), isA<InternetFailure>());
      verifyZeroInteractions(mockDataSource);
    });
  });
}
```

---

### 7.4 Test Constants & Fixtures

**Shared test constants** (`test/features/<feature>/utils/`):
```dart
// weather_entity_constants.dart
const weather = Weather(
  coOrdinate: CoOrdinate(longitude: 72.56, latitude: 23.03),
  weatherDetail: WeatherDetail(main: "Smoke", description: "smoke", icon: "50d"),
  condition: Condition(temperature: 34, feelLikeTemperature: 38, ...),
  wind: Wind(speed: 5.66, degree: "South"),
  sunDetail: SunDetail(sunrise: "05:54 AM", sunset: "07:20 PM"),
  city: "Ahmedabad",
);
```

**Fixture reader** (`test/fixtures/`):
```dart
String fixture(String name) => File("test/fixtures/$name").readAsStringSync();
```

**Generate mocks:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. Dependency Stack

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | BLoC state management |
| `bloc_test` | ^10.0.0 | BLoC testing utilities |
| `fpdart` | ^1.1.0 | Functional programming (`Either`) |
| `equatable` | ^2.0.5 | Value equality for entities, states, events |
| `get_it` | ^8.2.0 | Service locator / dependency injection |
| `dio` | ^5.4.3 | HTTP client |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `json_serializable` | ^6.8.0 | Code generation for JSON |
| `build_runner` | ^2.4.9 | Code generation runner |
| `mockito` | ^5.4.4 | Mocking for tests |
| `internet_connection_checker_plus` | ^2.3.0 | Network connectivity check |
| `google_fonts` | ^6.2.1 | Custom typography |
| `cached_network_image` | ^3.3.1 | Image caching |
| `intl` | ^0.20.2 | Date/number formatting |

---

## 9. Checklists

### 9.1 New Feature Checklist

When adding a new feature (e.g., `profile`), create files in this order:

- [ ] `lib/features/profile/domain/entities/profile.dart` — Entity
- [ ] `lib/features/profile/domain/repositories/profile_repository.dart` — Contract
- [ ] `lib/features/profile/domain/usecases/get_profile.dart` — UseCase + Params
- [ ] `lib/features/profile/domain/utils/profile_mapper.dart` — Mapper
- [ ] `lib/features/profile/data/models/profile_model.dart` — JSON model
- [ ] Run `dart run build_runner build` — Generate `.g.dart`
- [ ] `lib/features/profile/data/datasource/profile_remote_datasource.dart` — Contract
- [ ] `lib/features/profile/data/datasource_impl/profile_remote_datasource_impl.dart` — Impl
- [ ] `lib/features/profile/data/repositories/profile_repository_impl.dart` — Impl
- [ ] `lib/features/profile/presentation/constants/profile_strings.dart` — Feature-specific UI strings
- [ ] `lib/features/profile/presentation/bloc/profile_filter.dart` — Filter (if needed)
- [ ] `lib/features/profile/presentation/bloc/profile_bloc.dart` — BLoC
- [ ] `lib/features/profile/presentation/ui/profile_page.dart` — Page
- [ ] `lib/injection_container.dart` — Register all new classes
- [ ] `test/features/profile/...` — Mirror structure with tests

---

### 9.2 Code Review Checklist

- [ ] **Entities** use `const` constructors and `Equatable`
- [ ] **Repository contract** returns `Either<Failure, T>`, never throws
- [ ] **Repository impl** checks `networkInfo.isConnected` before remote calls
- [ ] **Repository impl** catches `ServerException` → returns `ServerFailure`
- [ ] **DataSource** throws `ServerException` on error, never returns null
- [ ] **Models** use `@JsonSerializable()`, have `fromJson` + `toJson`
- [ ] **Mapper** converts model → entity (never entity → model)
- [ ] **BLoC** extends `BaseBloc<T>` and only implements `operation()`
- [ ] **BLoC** validates filter type with `is` check
- [ ] **UseCase** extends `UseCase<Type, Params>`, calls repository
- [ ] **DI** registers BLoC as `Factory`, everything else as `LazySingleton`
- [ ] **Tests** exist for: BLoC, Repository, UseCase, Models, DataSource
- [ ] **Zero hardcoding** — no raw strings, numbers, or patterns in source files
- [ ] **UI strings** use `AppStrings` or `<Feature>Strings` constants
- [ ] **Spacing & sizes** use `AppConstants` values, not magic numbers
- [ ] **Date formats** use `AppPatterns` constants, not inline format strings
- [ ] **Regex patterns** live in `AppPatterns`, not duplicated across files
- [ ] **Error messages** reference `AppStrings` constants

---

## 10. Data Flow Diagram

```
┌────────┐   FetchData     ┌──────────┐   operation()    ┌──────────┐
│   UI   │ ──── event ────→ │ BaseBloc │ ───────────────→ │  UseCase │
│ (Page) │                  │ (Weather │                  │ (GetWea- │
│        │ ←── state ────── │   Bloc)  │ ←── Either ──── │  ther)   │
└────────┘   FetchDataState └──────────┘                  └──────────┘
                                                               │
                                                        calls repository
                                                               │
                                                               ▼
┌────────────────────┐         ┌────────────────────┐    ┌──────────┐
│ DataSource (Impl)  │ ── → ── │ Repository (Impl)  │ ── │ Reposito-│
│  ↓ ApiService.get  │  Model  │  ↓ Maps Model→Enti │    │ ry (Con- │
│  ↓ Returns Model   │         │  ↓ Returns Either   │    │ tract)   │
└────────────────────┘         └────────────────────┘    └──────────┘
         │                              │
    Throws                        Catches
  ServerException              → ServerFailure
                               → InternetFailure
```

---

## 11. Production Recommendations

The base architecture described above is solid for any project. The following recommendations elevate it to **production-grade** for larger, team-based, or long-lived applications.

---

### 11.1 API Key Security

**Problem:** Hardcoding API keys in source files (e.g., `api_routes.dart`) exposes them in version control.

**Solution:** Use Dart compile-time environment variables.

```dart
// api_routes.dart
class ApiRoutes {
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api.example.com');
  static const apiKey = String.fromEnvironment('API_KEY');
}
```

**Run with:**
```bash
flutter run --dart-define=API_KEY=your_secret_key --dart-define=BASE_URL=https://api.openweathermap.org
```

**Alternative:** Use `flutter_dotenv` or `envied` packages for `.env` file support.

**Rules:**
- Never commit API keys to source control
- Add `.env` to `.gitignore`
- Document required environment variables in `README.md`
- Use separate keys for dev/staging/prod environments

---

### 11.2 Multi-Event BLoC (Beyond FetcherBloc)

**Problem:** `BaseFetcherBloc<T>` only handles `FetchData` API events. If a feature needs complex multi-action UI events entirely detached from Cubit behavior.

**Solution:** Create a standard standalone `Bloc` for complex features.

```dart
/// Use BaseFetcherBloc<T> when:
/// - Fetches/updates data via pure Domain UseCases.
/// - Requires basic API success/failure mapping.
///
/// Use standard Bloc<Event, State> when:
/// - Complex UI form/wizard state machines.
/// - Emitting sequences rather than pure endpoints.

// Example: standard Bloc for a CRUD feature
abstract class ProfileEvent extends Equatable {}
class LoadProfile extends ProfileEvent { ... }
class UpdateProfile extends ProfileEvent { ... }
class DeleteProfile extends ProfileEvent { ... }

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoad);
    on<UpdateProfile>(_onUpdate);
    on<DeleteProfile>(_onDelete);
  }
}
```

**Decision guide:**

| Scenario | Use |
|----------|-----|
| Read-only data display | `BaseBloc<T>` |
| List with pull-to-refresh | `BaseBloc<List<T>>` |
| Form submission (single action) | `BaseBloc<T>` |
| CRUD operations | Standard `Bloc<Event, State>` |
| Complex UI with multiple data streams | Standard `Bloc<Event, State>` |

---

**Trade-off:** This enforces runtime/compile type checks. For flexibility, standard type-casting fetches are acceptable.

---

### 11.4 Mapper Optimization

**Problem:** Creating `WeatherMapper()` or `ForecastWeatherMapper()` on every repository call allocates unnecessary objects.

**Solution:** Make mappers `const` or use static methods.

```dart
// Option A: const instance
class WeatherMapper {
  const WeatherMapper(); // const constructor

  Weather toWeather(WeatherDataModel model, ...) { ... }
}

// In repository:
static const _mapper = WeatherMapper();
return Right(_mapper.toWeather(result, dateHelper, inputHelper));

// Option B: static methods (no instance at all)
class WeatherMapper {
  WeatherMapper._(); // private constructor

  static Weather toWeather(WeatherDataModel model, ...) { ... }
}

// In repository:
return Right(WeatherMapper.toWeather(result, dateHelper, inputHelper));
```

**Recommendation:** Use Option B (static methods) for simple mapping; Option A (const instance) if the mapper needs to be injectable/mockable.

---

### 11.5 Offline-First / Local Caching

**Problem:** The current architecture always hits the network. If the network is down, the user sees an error.

**Solution:** Add a `LocalDataSource` alongside `RemoteDataSource` for each feature.

```
features/
  weather/
    data/
      datasource/
        weather_remote_datasource.dart   # API calls
        weather_local_datasource.dart    # Local cache (Hive, SharedPrefs, SQLite)
      datasource_impl/
        weather_remote_datasource_impl.dart
        weather_local_datasource_impl.dart
```

**Repository strategy:**
```dart
class WeatherRepositoryImpl extends WeatherRepository {
  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource local;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, Weather>> getCurrentWeather({required LocationParam location}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remote.getCurrentWeather(location);
        await local.cacheWeather(result);   // Save to cache
        return Right(mapper.toWeather(result));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await local.getLastWeather();
        return Right(mapper.toWeather(cached));  // Return cached
      } catch (_) {
        return const Left(InternetFailure());
      }
    }
  }
}
```

**Caching packages:**

| Package | Best For |
|---------|----------|
| `hive` / `hive_flutter` | Key-value storage, fast, no SQL |
| `shared_preferences` | Simple key-value (small data) |
| `sqflite` / `drift` | Relational data, complex queries |
| `isar` | High-performance NoSQL |

---

### 11.6 Navigation & Routing

**Problem:** Hardcoding `home:` in `MaterialApp` doesn't scale beyond a single page.

**Solution:** Use a declarative routing package for multi-page apps.

**Recommended:** `go_router` (official Flutter team)

```dart
// core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WeatherPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/city/:id',
      builder: (context, state) => CityDetailPage(id: state.pathParameters['id']!),
    ),
  ],
);

// main.dart
MaterialApp.router(
  routerConfig: appRouter,
  theme: AppTheme().dark(),
);
```

**Route constants:**
```dart
// core/constants/app_routes.dart
class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const settings = '/settings';
  static String cityDetail(String id) => '/city/$id';
}
```

**When to add routing:**
- App has more than 2 pages
- You need deep linking
- You need route guards (auth checks)
- You need URL-based navigation (web)

---

### 11.7 Shared Params File Organization

**Problem:** `LocationParam` lives inside `get_weather.dart` but is shared by `GetWeather` and `GetWeatherForecast`.

**Solution:** When a Params class is used by multiple UseCases, extract it into its own file.

```
domain/
  usecases/
    params/
      location_param.dart    # Shared by multiple usecases
    get_weather.dart
    get_weather_forecast.dart
```

**Rule of thumb:**
- **Used by 1 UseCase** → keep it in the same file
- **Used by 2+ UseCases** → extract to `usecases/params/` folder
- **Used across features** → move to `core/usecase/params/`

---

### 11.8 PR Review Enforcement

**Problem:** The linter cannot enforce patterns like "use constants instead of hardcoded strings." A new team member might not know the constants system exists.

**Solution:** Use a combination of documentation, PR templates, and custom lint rules.

**1. PR Checklist Template** (`.github/PULL_REQUEST_TEMPLATE.md`):
```markdown
## PR Checklist

- [ ] No hardcoded strings — used `AppStrings` / `<Feature>Strings`
- [ ] No magic numbers — used `AppConstants`
- [ ] No inline date formats — used `AppPatterns`
- [ ] No inline regex — used `AppPatterns`
- [ ] New feature has a `<feature>_strings.dart` constants file
- [ ] All new classes registered in `injection_container.dart`
- [ ] Tests added/updated for all changed layers
- [ ] BLoC extends `BaseBloc<T>` (or justified why not)
- [ ] Repository returns `Either<Failure, T>`, never throws
```

**2. Custom Lint Rules** (using `custom_lint` + `riverpod_lint` style):
```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - no_hardcoded_strings: true  # Custom rule
```

**3. Onboarding Comment in `main.dart`:**
```dart
/// ⚠️ ARCHITECTURE NOTES
/// - All strings → AppStrings / <Feature>Strings (see core/constants/)
/// - All numbers → AppConstants (see core/constants/)
/// - All patterns/regex → AppPatterns (see core/constants/)
/// - See ARCHITECTURE_GUIDELINES.md for full details
```

**4. README Section:**
Add a "Contributing" section in README.md that links to `ARCHITECTURE_GUIDELINES.md` and highlights the zero-hardcoding rule.

---

### Summary: When to Apply Each Recommendation

| Recommendation | Apply When |
|---------------|------------|
| API Key Security | **Always** — any project with secrets |
| Multi-Event BLoC | Feature needs CRUD or multiple actions |
| Compile-Time Filters | Team finds runtime filter bugs |
| Mapper Optimization | High-frequency API calls or large lists |
| Local Caching | App must work offline or needs speed |
| Navigation/Routing | App has 2+ pages |
| Shared Params | Param class used by 2+ UseCases |
| PR Enforcement | **Always** — any team larger than 1 |

---

## Quick Reference: Creating a New Project

```bash
# 1. Create Flutter project
flutter create my_app

# 2. Add dependencies
cd my_app
flutter pub add flutter_bloc fpdart equatable get_it dio json_annotation intl google_fonts cached_network_image internet_connection_checker_plus
flutter pub add --dev json_serializable build_runner mockito bloc_test flutter_lints

# 3. Copy core/ directory from this template
# 4. Follow the New Feature Checklist (Section 9.1) for your first feature
# 5. Set up injection_container.dart
# 6. Configure main.dart
# 7. Review Section 11 (Production Recommendations) and apply what fits
```

---

> **This document is designed to be copied into any new Flutter project's repository root as `ARCHITECTURE_GUIDELINES.md`. Keep it updated as patterns evolve.**

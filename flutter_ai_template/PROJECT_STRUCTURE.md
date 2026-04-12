# Weather App — Project Structure & Onboarding Guide

This document provides a detailed overview of the project structure, architecture patterns, and conventions for the Weather App. It is intended to help new developers quickly understand the codebase and contribute effectively.

> 📘 For the full reusable architecture guidelines (with code examples for every layer), see [ARCHITECTURE_GUIDELINES.md](./ARCHITECTURE_GUIDELINES.md).

---

## 1. Directory Structure

```
lib/
  core/
    bloc/                  # Base BLoC classes, events, states, filters
      base_bloc.dart         # Generic data-fetching BLoC (extends Bloc)
      bloc_events.dart       # FetchDataEvent, FetchData (with refresh & filter)
      bloc_states.dart       # FetchDataState<T>, Status enum
      filter.dart            # Filter (abstract), NoFilter
    constants/             # ⭐ Zero-hardcoding — all values centralized here
      app_strings.dart       # User-facing text, error messages, labels, symbols, units
      app_constants.dart     # Numeric values: spacing, sizes, timeouts, grid config
      app_patterns.dart      # Date formats, URL templates, regex patterns
    error/                 # Error handling
      exception.dart         # ServerException, BadFilter
      failure.dart           # Failure, ServerFailure, InternetFailure, BadFilterFailure
    extension/             # Dart/Flutter extensions
      string_extension.dart  # capitalizeWords()
    helper/                # Injectable wrappers around static utilities
      date_helper.dart       # DateHelper → wraps DateUtil (mockable)
      date_util.dart         # Static date formatting utilities (pure)
      input_helper.dart      # InputHelper → wraps InputUtil (mockable)
      input_util.dart        # Static input transformation utilities (pure)
    network/               # Network layer
      api_keys.dart          # Query parameter key constants (lat, lon, appid)
      api_routes.dart        # Base URL, endpoint path constants
      api_service.dart       # Dio wrapper: get, post, delete, multipartPost
      utils/
        certificate_reader.dart    # SSL certificate pinning support
        logging_interceptor.dart   # Debug-only request/response logger
    platform/              # Platform-specific code
      network_info.dart      # NetworkInfo (abstract) + NetworkInfoImpl
    presentation/          # Shared presentation logic
      theme/
        app_theme.dart       # Material 3 theme with light/dark ColorSchemes
    usecase/               # Common abstractions
      usecase.dart           # UseCase<Type, Params>, NoParams

  features/
    weather/
      data/                # External data handling
        datasource/
          weather_remote_datasource.dart       # Abstract datasource contract
        datasource_impl/
          weather_remote_datasource_impl.dart  # API implementation via ApiService
        models/
          coord_model.dart (+.g.dart)          # @JsonSerializable models
          forecast_data_model.dart (+.g.dart)
          forecast_model.dart (+.g.dart)
          main_model.dart (+.g.dart)
          sys_model.dart (+.g.dart)
          weather_data_model.dart (+.g.dart)
          weather_model.dart (+.g.dart)
          wind_model.dart (+.g.dart)
        repositories/
          weather_repository_impl.dart         # Repository implementation

      domain/              # Pure business logic (zero framework dependencies)
        entities/
          co_ordinate.dart       # CoOrdinate entity
          condition.dart         # Condition entity (temp, humidity, pressure)
          forecast_weather.dart  # ForecastWeather entity
          sun_detail.dart        # SunDetail entity (sunrise/sunset)
          weather.dart           # Weather entity (composed)
          weather_detail.dart    # WeatherDetail entity (main, description, icon)
          wind.dart              # Wind entity
        repositories/
          weather_repository.dart   # Abstract repository contract
        usecases/
          get_weather.dart         # GetWeather UseCase + LocationParam
          get_weather_forecast.dart # GetWeatherForecast UseCase
        utils/
          forecast_weather_mapper.dart  # ForecastModel → ForecastWeather
          weather_mapper.dart          # WeatherDataModel → Weather

      presentation/        # UI and state management
        bloc/
          forecast_weather_bloc.dart  # Extends BaseBloc<List<ForecastWeather>>
          location_filter.dart       # LocationFilter extends Filter
          weather_bloc.dart          # Extends BaseBloc<Weather>
        constants/
          weather_strings.dart       # ⭐ Feature-specific UI strings & templates
        ui/
          weather_page.dart          # Main page with BlocConsumers
          widgets/
            condition_item.dart      # Reusable condition card widget
            section_conditions.dart  # Wind, Humidity, Pressure, Sunrise & Sunset
            section_forecast.dart    # Horizontal forecast list
            section_main_weather.dart # Temperature + weather description header
            section_title.dart       # Section title label
            weather_image.dart       # CachedNetworkImage wrapper

  injection_container.dart   # GetIt dependency injection setup
  main.dart                  # App entry point

test/
  core/
    error/
    helper/                # date_helper_test, input_helper_test
    network/               # api_service_test
    platform/              # network_info_test
  features/
    weather/
      data/
        datasource_impl/   # weather_remote_datasource_impl_test
        models/            # Individual model tests (fromJson/toJson)
        repositories/      # weather_repository_impl_test
      domain/
        usecases/          # get_weather_test, get_weather_forecast_test
      presentation/
        bloc/              # weather_bloc_test, forecast_weather_bloc_test
      utils/               # Shared test constants (entities + models)
  fixtures/
    fixture_reader.dart    # JSON fixture loader utility
  widget_test.dart         # Widget test example
```

---

## 2. Architecture Overview

The project follows **Clean Architecture** with **Domain-Driven Design (DDD)**:

```
┌─────────────────────────────────────────────────┐
│               Presentation                      │  UI, BLoC, Filters, Feature Strings
│  ┌───────────────────────────────────────────┐   │
│  │              Domain                       │   │  Entities, UseCases, Repo Contracts, Mappers
│  │  ┌─────────────────────────────────────┐  │   │
│  │  │             Data                    │  │   │  Models, DataSources, Repo Implementations
│  │  └─────────────────────────────────────┘  │   │
│  └───────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
         ↑ Dependencies point inward only ↑
```

**Data Flow:** `UI → BLoC → UseCase → Repository (contract) → RepositoryImpl → DataSource → API`

---

## 3. State Management

### Pattern: Dual-Tier (Fetcher BLoC + UI Cubit)

| Component | Location | Role |
|-----------|----------|------|
| `BaseFetcherBloc<T>` | `core/fetcher/base_fetcher_bloc.dart` | Stateless network lifecycle: loading → success/failure. Dart 3 Sealed classes. |
| `FetcherEvent` | `core/fetcher/fetcher_event.dart` | Uniform API triggering. Carries `Filter`. |
| `BaseUiCubit<T, S>` | `core/cubit/base_ui_cubit.dart` | Holds complex UI logic. Subscribes to Fetcher. |
| `BaseUiState<T>` | `core/cubit/base_ui_state.dart` | Forces `originalData` and `viewData` for clean UI filtering. |
| `Filter` / `NoFilter` | `core/usecase/filter.dart` | Abstract filter parameters standard for usecases. |

**Feature Components**:
- **Networking**: `WeatherFetcher` → `BaseFetcherBloc<Weather>`
- **UI Memory**: `WeatherCubit` → `BaseUiCubit<Weather, WeatherState>` producing `WeatherState` with custom fields.

---

## 4. Constants System (Zero Hardcoding)

**Rule: Nothing is hardcoded directly.** Every string, number, pattern, and regex lives in a constants file.

| File | Location | Contents |
|------|----------|----------|
| `AppStrings` | `core/constants/app_strings.dart` | Error messages, labels, symbols (`°`, `%`), units (`km/h`, `mBar`) |
| `AppConstants` | `core/constants/app_constants.dart` | Spacing, icon sizes, grid config, font sizes, timeouts |
| `AppPatterns` | `core/constants/app_patterns.dart` | Date formats, URL templates, regex (email, phone, password, URL) |
| `WeatherStrings` | `features/weather/presentation/constants/` | Section titles, temperature templates, condition labels |

**Examples:**
```dart
// ❌ Bad
Text("Something went wrong");
SizedBox(height: 20);
DateFormat("hh:mm a").format(date);

// ✅ Good
Text(AppStrings.somethingWentWrong);
SizedBox(height: AppConstants.spacingXXL);
DateFormat(AppPatterns.timeFormat).format(date);
```

---

## 5. Error Handling

Two-tier model with **functional error handling** via `fpdart`:

| Layer | Type | When |
|-------|------|------|
| Data | `ServerException` / `BadFilter` | Thrown by DataSources |
| Domain+ | `ServerFailure` / `InternetFailure` / `BadFilterFailure` | Returned via `Either.left()` |

**Flow:** DataSource throws `ServerException` → Repository catches → returns `Left(ServerFailure(...))` → UseCase passes through → BaseBloc folds into `Status.failure`

---

## 6. Dependency Injection

- **Package:** `get_it` (service locator pattern)
- **File:** `lib/injection_container.dart`
- **Registration order:** External → Core → Data → Domain → Presentation

| Registration Type | Used For |
|-------------------|----------|
| `registerFactory` | BLoCs (fresh instance per widget) |
| `registerLazySingleton` | UseCases, Repositories, DataSources |
| `registerSingleton` | External libs, Helpers, ApiService |

---

## 7. Helper / Util Pattern

Static `Util` classes hold pure logic. Injectable `Helper` classes wrap them for mockability:

```
DateHelper (injectable, mockable) → delegates to → DateUtil (static, pure, testable)
InputHelper (injectable, mockable) → delegates to → InputUtil (static, pure, testable)
```

---

## 8. Network Layer

| File | Purpose |
|------|---------|
| `ApiService` | Dio wrapper with `get`, `post`, `delete`, `multipartPost` |
| `ApiRoutes` | Base URL, API version, endpoint paths |
| `ApiKeys` | Query parameter key names (`lat`, `lon`, `appid`) |
| `LoggingInterceptor` | Debug-only request/response logger |
| `CertificateReader` | SSL certificate pinning support |

---

## 9. Testing Approach

- **Structure:** Mirrors `lib/` exactly
- **Mocking:** `mockito` + `@GenerateMocks` with `build_runner`
- **BLoC tests:** `bloc_test` package with `blocTest<>()`, `seed()`, `expect()`
- **Test constants:** Shared entity/model constants in `test/features/weather/utils/`
- **Fixtures:** JSON response files loaded via `fixture_reader.dart`

**Test coverage:**
- ✅ BLoC tests (loading, success, failure, refresh, wrong filter)
- ✅ Repository tests (online/offline, success/exception)
- ✅ UseCase tests
- ✅ Model tests (fromJson/toJson)
- ✅ DataSource tests
- ✅ Helper/Platform tests

---

## 10. How to Extend the Project

1. **Add a New Feature:**
   - Create `lib/features/<name>/` with `data/`, `domain/`, `presentation/` subfolders
   - Domain: entities → repository contract → usecases → mappers
   - Data: models → datasource contract & impl → repository impl
   - Presentation: `<name>_strings.dart` → filter → bloc → UI page
   - Register all dependencies in `injection_container.dart`

2. **Add UI Strings:**
   - Feature-specific → `features/<name>/presentation/constants/<name>_strings.dart`
   - Shared / app-wide → `core/constants/app_strings.dart`
   - Never hardcode strings in widgets

3. **Add Tests:**
   - Mirror the feature structure under `test/features/<name>/`
   - Create shared test constants in `test/features/<name>/utils/`

---

## 11. Dependency Stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` / `bloc_test` | BLoC state management + testing |
| `fpdart` | Functional programming (`Either<Failure, T>`) |
| `equatable` | Value equality for entities, states, events |
| `get_it` | Service locator / dependency injection |
| `dio` | HTTP client |
| `json_annotation` / `json_serializable` | JSON serialization with code generation |
| `build_runner` | Code generation runner |
| `mockito` | Mocking for tests |
| `internet_connection_checker_plus` | Network connectivity check |
| `google_fonts` | Custom typography (Nunito) |
| `cached_network_image` | Image caching |
| `intl` | Date/number formatting |

---

## 12. References

- [ARCHITECTURE_GUIDELINES.md](./ARCHITECTURE_GUIDELINES.md) — Full reusable guidelines with code for every layer
- [BLoC Pattern](https://bloclibrary.dev/#/)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)
- [fpdart — Functional Programming](https://pub.dev/packages/fpdart)

---

For any questions, refer to the [ARCHITECTURE_GUIDELINES.md](./ARCHITECTURE_GUIDELINES.md) or ask a senior developer.

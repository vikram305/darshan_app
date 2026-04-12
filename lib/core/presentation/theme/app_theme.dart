import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  const AppTheme();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3d5f90),
      surfaceTint: Color(0xff3d5f90),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd5e3ff),
      onPrimaryContainer: Color(0xff234776),
      secondary: Color(0xff555f71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd9e3f8),
      onSecondaryContainer: Color(0xff3d4758),
      tertiary: Color(0xff6e5676),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff7d8ff),
      onTertiaryContainer: Color(0xff553f5d),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff43474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3035),
      inversePrimary: Color(0xffa6c8ff),
      primaryFixed: Color(0xffd5e3ff),
      onPrimaryFixed: Color(0xff001c3b),
      primaryFixedDim: Color(0xffa6c8ff),
      onPrimaryFixedVariant: Color(0xff234776),
      secondaryFixed: Color(0xffd9e3f8),
      onSecondaryFixed: Color(0xff121c2b),
      secondaryFixedDim: Color(0xffbdc7dc),
      onSecondaryFixedVariant: Color(0xff3d4758),
      tertiaryFixed: Color(0xfff7d8ff),
      onTertiaryFixed: Color(0xff27132f),
      tertiaryFixedDim: Color(0xffdabde2),
      onTertiaryFixedVariant: Color(0xff553f5d),
      surfaceDim: Color(0xffd9dae0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe1e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa6c8ff),
      surfaceTint: Color(0xffa6c8ff),
      onPrimary: Color(0xff02315f),
      primaryContainer: Color(0xff234776),
      onPrimaryContainer: Color(0xffd5e3ff),
      secondary: Color(0xffbdc7dc),
      onSecondary: Color(0xff273141),
      secondaryContainer: Color(0xff3d4758),
      onSecondaryContainer: Color(0xffd9e3f8),
      tertiary: Color(0xffdabde2),
      onTertiary: Color(0xff3d2846),
      tertiaryContainer: Color(0xff553f5d),
      onTertiaryContainer: Color(0xfff7d8ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe1e2e9),
      onSurfaceVariant: Color(0xffc4c6cf),
      outline: Color(0xff8d9199),
      outlineVariant: Color(0xff43474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e9),
      inversePrimary: Color(0xff3d5f90),
      primaryFixed: Color(0xffd5e3ff),
      onPrimaryFixed: Color(0xff001c3b),
      primaryFixedDim: Color(0xffa6c8ff),
      onPrimaryFixedVariant: Color(0xff234776),
      secondaryFixed: Color(0xffd9e3f8),
      onSecondaryFixed: Color(0xff121c2b),
      secondaryFixedDim: Color(0xffbdc7dc),
      onSecondaryFixedVariant: Color(0xff3d4758),
      tertiaryFixed: Color(0xfff7d8ff),
      onTertiaryFixed: Color(0xff27132f),
      tertiaryFixedDim: Color(0xffdabde2),
      onTertiaryFixedVariant: Color(0xff553f5d),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
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
}

import 'package:flutter/material.dart';

// ============================================================
// LEARNROOT THEME COLORS
// ============================================================

@immutable
class LearnRootThemeColors
    extends ThemeExtension<LearnRootThemeColors> {
  final Color background;
  final Color sidebar;
  final Color card;
  final Color cardSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color progressTrack;
  final Color progressBackground;
  final Color inputBackground;

  const LearnRootThemeColors({
    required this.background,
    required this.sidebar,
    required this.card,
    required this.cardSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.progressTrack,
    required this.progressBackground,
    required this.inputBackground,
  });

  // ==========================================================
  // DARK THEME
  // ==========================================================

  static const LearnRootThemeColors dark =
      LearnRootThemeColors(
    background: Color(0xFF030C1D),
    sidebar: Color(0xFF060E1F),
    card: Color(0xFF151D3B),
    cardSecondary: Color(0xFF1B2445),
    textPrimary: Color(0xFFE5E0E7),
    textSecondary: Color(0xFF99A1BD),
    border: Color(0x14FFFFFF),
    progressTrack: Color(0x26FFFFFF),
    progressBackground: Color(0xFF303754),
    inputBackground: Color(0xFF151D3B),
  );

  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  static const LearnRootThemeColors light =
      LearnRootThemeColors(
    // Very light lavender background
    background: Color(0xFFF7F5FC),

    // Slightly different sidebar
    sidebar: Color(0xFFFDFCFF),

    // Light lavender card
    card: Color(0xFFF3EEFF),

    // Slightly deeper lavender for secondary areas
    cardSecondary: Color(0xFFECE5FA),

    // Dark text for excellent readability
    textPrimary: Color(0xFF1B1D2A),
    textSecondary: Color(0xFF5F6678),

    // Soft lavender/grey border
    border: Color(0x1A593AB9),

    // Progress track
    progressTrack: Color(0xFFDCD6EB),

    // Progress background
    progressBackground: Color(0xFFD9D0F2),

    // Input background
    inputBackground: Color(0xFFF3EEFF),
  );

  // ==========================================================
  // COPY WITH
  // ==========================================================

  @override
  LearnRootThemeColors copyWith({
    Color? background,
    Color? sidebar,
    Color? card,
    Color? cardSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? progressTrack,
    Color? progressBackground,
    Color? inputBackground,
  }) {
    return LearnRootThemeColors(
      background:
          background ?? this.background,
      sidebar:
          sidebar ?? this.sidebar,
      card:
          card ?? this.card,
      cardSecondary:
          cardSecondary ?? this.cardSecondary,
      textPrimary:
          textPrimary ?? this.textPrimary,
      textSecondary:
          textSecondary ?? this.textSecondary,
      border:
          border ?? this.border,
      progressTrack:
          progressTrack ?? this.progressTrack,
      progressBackground:
          progressBackground ?? this.progressBackground,
      inputBackground:
          inputBackground ?? this.inputBackground,
    );
  }

  // ==========================================================
  // LERP
  // ==========================================================

  @override
  LearnRootThemeColors lerp(
    covariant LearnRootThemeColors? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }

    return LearnRootThemeColors(
      background:
          Color.lerp(
            background,
            other.background,
            t,
          )!,
      sidebar:
          Color.lerp(
            sidebar,
            other.sidebar,
            t,
          )!,
      card:
          Color.lerp(
            card,
            other.card,
            t,
          )!,
      cardSecondary:
          Color.lerp(
            cardSecondary,
            other.cardSecondary,
            t,
          )!,
      textPrimary:
          Color.lerp(
            textPrimary,
            other.textPrimary,
            t,
          )!,
      textSecondary:
          Color.lerp(
            textSecondary,
            other.textSecondary,
            t,
          )!,
      border:
          Color.lerp(
            border,
            other.border,
            t,
          )!,
      progressTrack:
          Color.lerp(
            progressTrack,
            other.progressTrack,
            t,
          )!,
      progressBackground:
          Color.lerp(
            progressBackground,
            other.progressBackground,
            t,
          )!,
      inputBackground:
          Color.lerp(
            inputBackground,
            other.inputBackground,
            t,
          )!,
    );
  }
}

// ============================================================
// COMMON LEARNROOT COLORS
// ============================================================

class LearnRootColors {
  // ==========================================================
  // PRIMARY COLORS
  // ==========================================================

  static const Color primary =
      Color(0xFF593AB9);

  static const Color success =
      Color(0xFF35D07F);

  static const Color warning =
      Color(0xFFF4A62A);

  // ==========================================================
  // DARK MODE COLORS
  // ==========================================================

  static const Color darkBackground =
      Color(0xFF030C1D);

  static const Color darkSidebar =
      Color(0xFF060E1F);

  static const Color darkCard =
      Color(0xFF151D3B);

  static const Color darkCardSecondary =
      Color(0xFF1B2445);

  static const Color darkTextPrimary =
      Color(0xFFE5E0E7);

  static const Color darkTextSecondary =
      Color(0xFF99A1BD);

  static const Color darkBorder =
      Color(0x14FFFFFF);

  static const Color darkProgressTrack =
      Color(0x26FFFFFF);

  // ==========================================================
  // LIGHT MODE COLORS
  // ==========================================================

  static const Color lightBackground =
      Color(0xFFF7F5FC);

  static const Color lightSidebar =
      Color(0xFFFDFCFF);

  static const Color lightCard =
      Color(0xFFF3EEFF);

  static const Color lightCardSecondary =
      Color(0xFFECE5FA);

  static const Color lightTextPrimary =
      Color(0xFF1B1D2A);

  static const Color lightTextSecondary =
      Color(0xFF5F6678);

  static const Color lightBorder =
      Color(0x1A593AB9);

  static const Color lightProgressTrack =
      Color(0xFFDCD6EB);

  // ==========================================================
  // EXISTING CODE COMPATIBILITY
  // ==========================================================
  //
  // These remain const so existing const widgets
  // do not immediately break.
  //

  static const Color background =
      darkBackground;

  static const Color sidebar =
      darkSidebar;

  static const Color card =
      darkCard;

  static const Color textPrimary =
      darkTextPrimary;

  static const Color textSecondary =
      darkTextSecondary;
}

// ============================================================
// LEARNROOT THEME
// ============================================================

class LearnRootTheme {
  // ==========================================================
  // DARK THEME
  // ==========================================================

  static ThemeData darkTheme =
      ThemeData(
    brightness:
        Brightness.dark,

    scaffoldBackgroundColor:
        LearnRootThemeColors.dark.background,

    primaryColor:
        LearnRootColors.primary,

    colorScheme:
        const ColorScheme.dark(
      primary:
          LearnRootColors.primary,
      surface:
          Color(0xFF151D3B),
    ),

    extensions:
        const <ThemeExtension<dynamic>>[
      LearnRootThemeColors.dark,
    ],

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          Color(0xFF030C1D),
      foregroundColor:
          Color(0xFFE5E0E7),
      elevation: 0,
    ),

    inputDecorationTheme:
        const InputDecorationTheme(
      filled: true,
      fillColor:
          Color(0xFF151D3B),
      border:
          InputBorder.none,
    ),

    textTheme:
        const TextTheme(
      bodyLarge:
          TextStyle(
        color:
            Color(0xFFE5E0E7),
      ),
      bodyMedium:
          TextStyle(
        color:
            Color(0xFF99A1BD),
      ),
    ),
  );

  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  static ThemeData lightTheme =
      ThemeData(
    brightness:
        Brightness.light,

    scaffoldBackgroundColor:
        LearnRootThemeColors.light.background,

    primaryColor:
        LearnRootColors.primary,

    colorScheme:
        const ColorScheme.light(
      primary:
          LearnRootColors.primary,
      surface:
          Color(0xFFF3EEFF),
    ),

    extensions:
        const <ThemeExtension<dynamic>>[
      LearnRootThemeColors.light,
    ],

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          Color(0xFFF7F5FC),
      foregroundColor:
          Color(0xFF1B1D2A),
      elevation: 0,
    ),

    inputDecorationTheme:
        const InputDecorationTheme(
      filled: true,
      fillColor:
          Color(0xFFF3EEFF),
      border:
          InputBorder.none,
    ),

    textTheme:
        const TextTheme(
      bodyLarge:
          TextStyle(
        color:
            Color(0xFF1B1D2A),
      ),
      bodyMedium:
          TextStyle(
        color:
            Color(0xFF5F6678),
      ),
    ),
  );
}

class AppTheme {
  static const Color primaryPurple = Color(0xFF593AB9);
  static const Color gradientPurpleEnd = Color(0xFF7B61D1);

  static const Color darkBackground = Color(0xFF030C1D);
  static const Color darkCard = Color(0xFF151D3B);
  static const Color darkSecondary = Color(0xFF0E1532);
  static const Color darkMainText = Color(0xFFE5E0E7);
  static const Color darkSecondaryText = Color(0xFF99A1BD);

  static const Color lightBackground = Color(0xFFF8F7FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF1EFF8);
  static const Color lightMainText = Color(0xFF25233A);
  static const Color lightSecondaryText = Color(0xFF6F7185);
  static const Color lightBorder = Color(0xFFE8E6F0);

  static const Color prerequisiteBorder = Color(0xFF66A66B);
  static const Color prerequisiteBackground = Color(0xFFE8F5E9);
  static const Color prerequisiteText = Color(0xFF356B3B);

  static const Color postRequisiteBorder = Color(0xFFE6A34A);
  static const Color postRequisiteBackground = Color(0xFFFFF2E1);
  static const Color postRequisiteText = Color(0xFF8A5A16);

  static const Color currentTopic = Color(0xFF6C63A8);

  static const Color warningOrange = Color(0xFFF4A62A);
  static const Color successGreen = Color(0xFF35D07F);

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F7FC),
      Color(0xFFF0EBFA),
      Color(0xFFE5DCF7),
    ],
  );
}
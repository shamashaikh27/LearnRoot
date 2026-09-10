import 'package:flutter/material.dart';

// ============================================================
// LEARNROOT COLORS
// ============================================================

class LearnRootColors {
  static const Color primary = AppTheme.primaryPurple;

  static const Color success = AppTheme.successGreen;

  static const Color warning = AppTheme.warningOrange;

  static const Color background =
      AppTheme.lightBackground;

  static const Color darkBackground =
      AppTheme.darkBackground;

  static const Color card =
      AppTheme.lightCard;

  static const Color darkCard =
      AppTheme.darkCard;

  static const Color textPrimary =
      AppTheme.lightMainText;

  static const Color textSecondary =
      AppTheme.lightSecondaryText;

  static const Color darkTextPrimary =
      AppTheme.darkMainText;

  static const Color darkTextSecondary =
      AppTheme.darkSecondaryText;

  static const Color border =
      AppTheme.lightBorder;
}

// ============================================================
// LEARNROOT THEME COLORS
// ============================================================

class LearnRootThemeColors
    extends ThemeExtension<LearnRootThemeColors> {
  final Color background;
  final Color sidebar;
  final Color card;
  final Color cardSecondary;
  final Color inputBackground;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color progressBackground;
  final Color progressTrack;

  const LearnRootThemeColors({
    required this.background,
    required this.sidebar,
    required this.card,
    required this.cardSecondary,
    required this.inputBackground,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.progressBackground,
    required this.progressTrack,
  });

  // ==========================================================
  // DARK THEME COLORS
  // ==========================================================

  static const LearnRootThemeColors dark =
      LearnRootThemeColors(
    background: AppTheme.darkBackground,

    sidebar: AppTheme.darkSecondary,

    card: AppTheme.darkCard,

    cardSecondary: AppTheme.darkSecondary,

    inputBackground: AppTheme.darkSecondary,

    border: Color(0xFF293252),

    textPrimary: AppTheme.darkMainText,

    textSecondary: AppTheme.darkSecondaryText,

    progressBackground: Color(0xFF293252),

    progressTrack: Color(0xFF293252),
  );

  // ==========================================================
  // LIGHT THEME COLORS
  // ==========================================================

  static const LearnRootThemeColors light =
      LearnRootThemeColors(
    background: AppTheme.lightBackground,

    sidebar: AppTheme.lightSecondary,

    card: AppTheme.lightCard,

    cardSecondary: AppTheme.lightSecondary,

    inputBackground: AppTheme.lightCard,

    border: AppTheme.lightBorder,

    textPrimary: AppTheme.lightMainText,

    textSecondary: AppTheme.lightSecondaryText,

    progressBackground: Color(0xFFE3DFF0),

    progressTrack: Color(0xFFE3DFF0),
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
    Color? inputBackground,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? progressBackground,
    Color? progressTrack,
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

      inputBackground:
          inputBackground ??
              this.inputBackground,

      border:
          border ?? this.border,

      textPrimary:
          textPrimary ??
              this.textPrimary,

      textSecondary:
          textSecondary ??
              this.textSecondary,

      progressBackground:
          progressBackground ??
              this.progressBackground,

      progressTrack:
          progressTrack ??
              this.progressTrack,
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
      background: Color.lerp(
            background,
            other.background,
            t,
          ) ??
          background,

      sidebar: Color.lerp(
            sidebar,
            other.sidebar,
            t,
          ) ??
          sidebar,

      card: Color.lerp(
            card,
            other.card,
            t,
          ) ??
          card,

      cardSecondary: Color.lerp(
            cardSecondary,
            other.cardSecondary,
            t,
          ) ??
          cardSecondary,

      inputBackground: Color.lerp(
            inputBackground,
            other.inputBackground,
            t,
          ) ??
          inputBackground,

      border: Color.lerp(
            border,
            other.border,
            t,
          ) ??
          border,

      textPrimary: Color.lerp(
            textPrimary,
            other.textPrimary,
            t,
          ) ??
          textPrimary,

      textSecondary: Color.lerp(
            textSecondary,
            other.textSecondary,
            t,
          ) ??
          textSecondary,

      progressBackground: Color.lerp(
            progressBackground,
            other.progressBackground,
            t,
          ) ??
          progressBackground,

      progressTrack: Color.lerp(
            progressTrack,
            other.progressTrack,
            t,
          ) ??
          progressTrack,
    );
  }
}

// ============================================================
// APP THEME
// ============================================================

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color primaryPurple =
      Color(0xFF593AB9);

  static const Color gradientPurpleEnd =
      Color(0xFF7B61D1);

  // ============================================================
  // DARK THEME
  // ============================================================

  static const Color darkBackground =
      Color(0xFF030C1D);

  static const Color darkCard =
      Color(0xFF151D3B);

  static const Color darkSecondary =
      Color(0xFF0E1532);

  static const Color darkMainText =
      Color(0xFFE5E0E7);

  static const Color darkSecondaryText =
      Color(0xFF99A1BD);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static const Color lightBackground =
      Color(0xFFF8F7FC);

  static const Color lightCard =
      Color(0xFFFFFFFF);

  static const Color lightSecondary =
      Color(0xFFF1EFF8);

  static const Color lightMainText =
      Color(0xFF25233A);

  static const Color lightSecondaryText =
      Color(0xFF6F7185);

  static const Color lightBorder =
      Color(0xFFE8E6F0);

  // ============================================================
  // LIGHT BACKGROUND GRADIENT
  // ============================================================

  static const LinearGradient
      lightBackgroundGradient =
      LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F7FC),
      Color(0xFFF0EBFA),
      Color(0xFFE5DCF7),
    ],
  );

  // ============================================================
  // DARK BACKGROUND
  // ============================================================

  static const Color darkBackgroundGradientTop =
      Color(0xFF030C1D);

  static const Color darkBackgroundGradientBottom =
      Color(0xFF030C1D);

  // ============================================================
  // GRAPH NODE COLORS
  // ============================================================

  static const Color prerequisiteBackground =
      Color(0xFFE8F5E9);

  static const Color prerequisiteBorder =
      Color(0xFF66A66B);

  static const Color prerequisiteText =
      Color(0xFF356B3B);

  static const Color currentTopic =
      Color(0xFF6C63A8);

  static const Color postRequisiteBackground =
      Color(0xFFFFF2E1);

  static const Color postRequisiteBorder =
      Color(0xFFE6A34A);

  static const Color postRequisiteText =
      Color(0xFF8A5A16);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color successGreen =
      Color(0xFF35D07F);

  static const Color warningOrange =
      Color(0xFFF4A62A);

  // ============================================================
  // PRIMARY GRADIENT
  // ============================================================

  static const LinearGradient primaryGradient =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryPurple,
      gradientPurpleEnd,
    ],
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor:
        darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPurple,
      surface: darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkMainText,
    ),

    extensions: const [
      LearnRootThemeColors.dark,
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkMainText,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor:
          Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor: darkSecondary,

      hintStyle: const TextStyle(
        color: darkSecondaryText,
        fontSize: 14,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryPurple,
          width: 1.5,
        ),
      ),
    ),

    dividerTheme:
        DividerThemeData(
      color: Colors.white.withValues(
        alpha: 0.08,
      ),
      thickness: 1,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: darkMainText,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: darkSecondaryText,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: darkSecondaryText,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor:
        lightBackground,

    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: primaryPurple,
      surface: lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightMainText,
    ),

    extensions: const [
      LearnRootThemeColors.light,
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightMainText,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor:
          Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor: lightCard,

      hintStyle: const TextStyle(
        color: lightSecondaryText,
        fontSize: 14,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: lightBorder,
          width: 1,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryPurple,
          width: 1.5,
        ),
      ),
    ),

    dividerTheme:
        const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: lightMainText,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: lightSecondaryText,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: lightSecondaryText,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
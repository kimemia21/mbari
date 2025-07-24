import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/core/theme/AppColors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - Pop and vibrant
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textAccent,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.textAccent,

        secondary: AppColors.secondary,
        onSecondary: AppColors.textInverse,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.textInverse,

        tertiary: AppColors.accent,
        onTertiary: AppColors.textInverse,
        tertiaryContainer: AppColors.accentDark,
        onTertiaryContainer: AppColors.textAccent,

        error: AppColors.error,
        onError: AppColors.textAccent,

        background: AppColors.background,
        onBackground: AppColors.textPrimary,

        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,

        outline: AppColors.border,
        shadow: AppColors.shadowDark,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.textInverse,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // App Bar - Glassmorphism style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundGlass.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 26,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Cards - Modern with subtle glow
      cardTheme: CardTheme(
        color: AppColors.backgroundCard,
        elevation: 12,
        shadowColor: AppColors.shadowColored,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Buttons - Bold and vibrant
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          elevation: 8,
          shadowColor: AppColors.purpleGlow.withOpacity(0.5),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            AppColors.primaryLight.withOpacity(0.2),
          ),
        ),
      ),

      // Text Buttons - Accent colors
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            AppColors.accent.withOpacity(0.1),
          ),
        ),
      ),

      // Outlined Buttons - Neon border effect
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.accent, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            AppColors.accent.withOpacity(0.1),
          ),
        ),
      ),

      // Input Fields - Glassmorphism style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground.withOpacity(0.8),
        hintStyle: TextStyle(
          color: AppColors.inputHint,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.inputBorder.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.inputBorderFocused,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2.5,
          ),
        ),
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // Typography - Modern and bold
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 64, 
          fontWeight: FontWeight.w900, 
          letterSpacing: -1.0,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 52, 
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 40, 
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 36, 
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 32, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 28, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 24, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 18, 
          fontWeight: FontWeight.w600, 
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: AppColors.textSecondary, 
          fontSize: 16, 
          fontWeight: FontWeight.w500, 
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 18, 
          fontWeight: FontWeight.w400, 
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary, 
          fontSize: 16, 
          fontWeight: FontWeight.w400, 
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: AppColors.textTertiary, 
          fontSize: 14, 
          fontWeight: FontWeight.w400, 
          letterSpacing: 0.4,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary, 
          fontSize: 16, 
          fontWeight: FontWeight.w600, 
          letterSpacing: 1.0,
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondary, 
          fontSize: 14, 
          fontWeight: FontWeight.w500, 
          letterSpacing: 1.25,
        ),
        labelSmall: TextStyle(
          color: AppColors.textTertiary, 
          fontSize: 12, 
          fontWeight: FontWeight.w500, 
          letterSpacing: 1.5,
        ),
      ),

      // Bottom Navigation - Glassmorphism with glow
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarBackground.withOpacity(0.9),
        selectedItemColor: AppColors.navBarSelected,
        unselectedItemColor: AppColors.navBarUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 30),
        unselectedIconTheme: IconThemeData(size: 26),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColors.divider.withOpacity(0.6),
        thickness: 1,
        space: 20,
        indent: 24,
        endIndent: 24,
      ),

      // Icons
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: 26,
      ),

      // FAB - Gradient style
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textAccent,
        elevation: 12,
        focusElevation: 16,
        hoverElevation: 16,
        highlightElevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialogs - Glassmorphism
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface.withOpacity(0.95),
        elevation: 16,
        shadowColor: AppColors.shadowColored,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      // Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.95),
        elevation: 16,
        modalElevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
      ),

      // Snackbars - Pop style
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        actionTextColor: AppColors.accent,
      ),

      // Chips - Neon style
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant.withOpacity(0.8),
        deleteIconColor: AppColors.textTertiary,
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        selectedColor: AppColors.primaryLight.withOpacity(0.4),
        secondaryLabelStyle: TextStyle(color: AppColors.primary),
        secondarySelectedColor: AppColors.primary,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.surfaceVariant,
        circularTrackColor: AppColors.surfaceVariant,
      ),

      // Switches - Neon glow
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.6);
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // Checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: AppColors.border, width: 2),
      ),

      // Radio Buttons
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),

      // Interaction effects
      splashColor: AppColors.primaryLight.withOpacity(0.3),
      highlightColor: AppColors.primary.withOpacity(0.1),
    );
  }

  // --- Custom Decorations - Pop and Modern ---

  // Glassmorphism decoration
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassEffect(Colors.white, 0.1),
          AppColors.glassEffect(Colors.white, 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.glassEffect(Colors.white, 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  // Neon glow decoration
  static BoxDecoration neonGlowDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 0,
          offset: Offset(0, 0),
        ),
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 40,
          spreadRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  // Primary gradient decoration
  static BoxDecoration get primaryGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.purpleGlow.withOpacity(0.4),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  // Hero gradient decoration
  static BoxDecoration get heroGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.heroGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColored,
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  // Neon gradient decoration
  static BoxDecoration get neonGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.neonGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonGlow.withOpacity(0.4),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  // Sunset gradient decoration
  static BoxDecoration get sunsetGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.sunsetGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.pinkGlow.withOpacity(0.4),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  // Card with glow decoration
// --- Gen Z Pop Decorations - Modern & Vibrant ---

  // Holographic glass effect decoration
  static BoxDecoration get holographicGlassDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassEffect(AppColors.primary, 0.15),
          AppColors.glassEffect(AppColors.secondary, 0.1),
          AppColors.glassEffect(AppColors.accent, 0.05),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.glassEffect(Colors.white, 0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.2),
          blurRadius: 25,
          spreadRadius: -5,
          offset: Offset(0, 15),
        ),
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.1),
          blurRadius: 40,
          spreadRadius: -10,
          offset: Offset(0, 25),
        ),
      ],
    );
  }

  // Cyberpunk neon glow decoration
  static BoxDecoration cyberpunkGlowDecoration(Color neonColor) {
    return BoxDecoration(
      color: AppColors.backgroundCard.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: neonColor.withOpacity(0.8),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: neonColor.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 0,
          offset: Offset(0, 0),
        ),
        BoxShadow(
          color: neonColor.withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 5,
          offset: Offset(0, 0),
        ),
        BoxShadow(
          color: neonColor.withOpacity(0.1),
          blurRadius: 60,
          spreadRadius: 10,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  // Rainbow gradient card decoration
  static BoxDecoration get rainbowGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.rainbowGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 30,
          offset: Offset(0, 15),
        ),
      ],
    );
  }

  // Retro wave gradient decoration
  static BoxDecoration get retroWaveDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.retroWaveGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonPink.withOpacity(0.4),
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  // Aurora borealis effect decoration
  static BoxDecoration get auroraDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.auroraGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: AppColors.auroraGreen.withOpacity(0.3),
          blurRadius: 20,
          offset: Offset(-5, -5),
        ),
        BoxShadow(
          color: AppColors.auroraPurple.withOpacity(0.3),
          blurRadius: 20,
          offset: Offset(5, 5),
        ),
      ],
    );
  }

  // Vaporwave aesthetic decoration
  static BoxDecoration get vaporwaveDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.vaporwaveGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.neonCyan.withOpacity(0.6),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonPink.withOpacity(0.25),
          blurRadius: 20,
          offset: Offset(-8, -8),
        ),
        BoxShadow(
          color: AppColors.neonCyan.withOpacity(0.25),
          blurRadius: 20,
          offset: Offset(8, 8),
        ),
      ],
    );
  }

  // Elevated card with multiple glow layers
  static BoxDecoration get multiGlowCardDecoration {
    return BoxDecoration(
      color: AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.1),
          blurRadius: 25,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.accent.withOpacity(0.05),
          blurRadius: 35,
          offset: Offset(0, 15),
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 40,
          offset: Offset(0, 20),
        ),
      ],
    );
  }

  // Frosted glass with color tint
  static BoxDecoration frostedGlassDecoration(Color tintColor) {
    return BoxDecoration(
      color: tintColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.glassEffect(Colors.white, 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark.withOpacity(0.1),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  // Pulsing animation decoration
  static BoxDecoration get pulsingDecoration {
    return BoxDecoration(
      gradient: RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0.4),
          AppColors.primary.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(100),
    );
  }

  // Neumorphism-inspired decoration
  static BoxDecoration get neumorphismDecoration {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.backgroundLight.withOpacity(0.1),
          blurRadius: 15,
          offset: Offset(-8, -8),
        ),
        BoxShadow(
          color: AppColors.shadowDark.withOpacity(0.3),
          blurRadius: 15,
          offset: Offset(8, 8),
        ),
      ],
    );
  }

  // Gradient border decoration
  static BoxDecoration gradientBorderDecoration(List<Color> borderColors) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: borderColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Inner content decoration (to be used inside gradient border)
  static BoxDecoration get innerContentDecoration {
    return BoxDecoration(
      color: AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(16),
    );
  }

  // Floating element decoration
  static BoxDecoration get floatingElementDecoration {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.shadowDark.withOpacity(0.05),
          blurRadius: 40,
          offset: Offset(0, 16),
        ),
      ],
    );
  }

  // Custom spacing constants for Gen Z layouts
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Animation durations for smooth transitions
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration extraSlowAnimation = Duration(milliseconds: 800);

  // Custom curves for Gen Z feel
  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve snapCurve = Curves.easeOutExpo;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/core/theme/AppColors.dart'; // Ensure this import path is correct

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Main dark theme for a premium fintech feel
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Define the core Color Scheme using AppColors
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textPrimary, // Text/icons on primary background
        primaryContainer: AppColors.primaryDark, // A darker shade of primary
        onPrimaryContainer: AppColors.textPrimary,

        secondary: AppColors.secondary,
        onSecondary: AppColors.textInverse, // Text/icons on secondary background (likely dark text)
        secondaryContainer: AppColors.secondaryDark, // A darker shade of secondary
        onSecondaryContainer: AppColors.textInverse,

        tertiary: AppColors.info, // Can be used for informational accents
        onTertiary: AppColors.textPrimary,
        tertiaryContainer: AppColors.backgroundLight, // Used for 'burner' type cards
        onTertiaryContainer: AppColors.textPrimary,

        error: AppColors.error,
        onError: AppColors.textPrimary, // Text/icons on error background

        background: AppColors.background, // Scaffold background
        onBackground: AppColors.textPrimary, // Text/icons on background

        surface: AppColors.surface, // Main card/dialog background
        onSurface: AppColors.textPrimary, // Text/icons on surface
        surfaceVariant: AppColors.surfaceVariant, // Input fields, subtle areas
        onSurfaceVariant: AppColors.textSecondary, // Text/icons on surface variant

        outline: AppColors.divider, // For borders
        shadow: AppColors.background.withOpacity(0.4), // A soft shadow color that blends
        inverseSurface: AppColors.textPrimary, // For when you need a light surface on dark
        onInverseSurface: AppColors.textInverse, // Text on inverse surface
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.background,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background, // Match scaffold for seamless look
        elevation: 0,
        scrolledUnderElevation: 0, // No elevation change on scroll
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarIconBrightness: Brightness.light, // Icons are light on dark background
          statusBarBrightness: Brightness.dark, // For iOS status bar style
        ),
      ),

      // Card Theme - Apply consistent premium look
      cardTheme: CardTheme(
        color: AppColors.backgroundCard, // Use backgroundCard for overall card styling
        elevation: 8, // More pronounced elevation for cards
        shadowColor: AppColors.background.withOpacity(0.4), // Softer, integrated shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded corners for modern feel
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Default margin can be zero, padding will be handled by individual widgets
      ),

      // Elevated Button Theme - Bold and inviting
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          elevation: 6, // Good elevation for buttons
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), // More generous padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Consistent rounded corners
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Stronger text for primary action
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme - Subtle and secondary
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight, // Use light primary for subtle calls to action
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme - Clean and accessible
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary, // Text color on dark background
          side: BorderSide(color: AppColors.border, width: 1.5), // Slightly thicker border
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Consistent rounded corners
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Theme - Clean and intuitive forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintStyle: TextStyle(
          color: AppColors.inputHint,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // More padding
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Softer corners for inputs
          borderSide: BorderSide(
            color: AppColors.inputBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.inputBorderFocused, // Primary color on focus
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        // Suffix and Prefix icons
        prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // Text Theme - Comprehensive and harmonious typography
      // Ensure all text styles use the new AppColors text colors
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontSize: 57, fontWeight: FontWeight.w900, letterSpacing: -0.25),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontSize: 45, fontWeight: FontWeight.w800),
        displaySmall: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        labelMedium: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.5),
        labelSmall: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
      ),

      // Bottom Navigation Bar Theme - Integrated and premium
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarBackground, // Match the new background for smooth transition
        selectedItemColor: AppColors.navBarSelected,
        unselectedItemColor: AppColors.navBarUnselected,
        type: BottomNavigationBarType.fixed, // Ensure consistent layout
        elevation: 12, // Slight elevation for depth
        selectedLabelStyle: TextStyle(
          fontSize: 13, // Slightly larger selected label
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 28), // Slightly larger icons for selected
        unselectedIconTheme: IconThemeData(size: 24),
      ),

      // Divider Theme - Subtle separation
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 0.8, // Thinner divider
        space: 16, // More space around dividers
        indent: 20, // Match typical screen padding
        endIndent: 20,
      ),

      // Icon Theme - Consistent icon styling
      iconTheme: IconThemeData(
        color: AppColors.textPrimary, // Default icon color for general icons
        size: 24,
      ),
      // Action icons (e.g., in AppBar, buttons) can derive from primary color
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (BuildContext context) => Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        closeButtonIconBuilder: (BuildContext context) => Icon(Icons.close_rounded, color: AppColors.textPrimary),
        // drawerIconBuilder: (BuildContext context) => Icon(Icons.menu_rounded, color: AppColors.textPrimary),
        // endDrawerIconBuilder: (BuildContext context) => Icon(Icons.menu_rounded, color: AppColors.textPrimary),
      ),


      // Floating Action Button Theme - Prominent call to action
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // Match other rounded elements
        ),
      ),

      // Dialog Theme - Elegant pop-ups
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface, // Use surface for dialogs
        elevation: 10, // Higher elevation for prominence
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Consistent rounding
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),

      // Bottom Sheet Theme - Smooth and accessible
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), // Larger radius for a premium feel
            topRight: Radius.circular(25),
          ),
        ),
      ),

      // Snackbar Theme - Discreet notifications
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.backgroundLight, // Slightly lighter background
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Consistent rounding
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // Chip Theme - Modern tagging and filtering
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        deleteIconColor: AppColors.textTertiary,
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Pill shape for chips
        ),
        selectedColor: AppColors.primaryLight.withOpacity(0.3), // Lighter selected state
        secondaryLabelStyle: TextStyle(color: AppColors.primary),
        secondarySelectedColor: AppColors.primary, // Primary color for selected chips
      ),

      // Progress Indicator Theme - Smooth loading states
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant, // Use surface variant for track
        circularTrackColor: AppColors.surfaceVariant,
      ),

      // Switch Theme - Modern toggles
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textSecondary; // Unselected thumb color
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary.withOpacity(0.5);
            }
            return AppColors.surfaceVariant; // Unselected track color
          },
        ),
      ),

      // Checkbox Theme - Clean selection indicators
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return AppColors.surfaceVariant;
          },
        ),
        checkColor: MaterialStateProperty.all(AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // Slightly rounded square
        ),
        side: BorderSide(color: AppColors.border, width: 1.5), // Custom border
      ),

      // Radio Theme - Modern radio buttons
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textSecondary;
          },
        ),
      ),
      // Splash Color and Highlight Color for InkWell/InkResponse
      splashColor: AppColors.primaryLight.withOpacity(0.2), // Gentle ripple effect
      highlightColor: Colors.transparent, // No harsh highlight on tap
    );
  }

  // Custom gradient decorations (kept, but ensure usage matches AppColors.primaryGradient, etc.)
  static BoxDecoration get primaryGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16), // Adjusted for consistency
    );
  }

  static BoxDecoration get accentGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }

  static BoxDecoration get successGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.successGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }

  // Custom shadow helper (kept as is, but consider if `cardShadow` should be a List<BoxShadow> or a single shadow)
  // Currently, `cardShadow` in `AppColors` is a single Color, while this returns a List<BoxShadow>.
  // It's better to define the full shadow in AppTheme directly if it's always the same.
  // Or, if AppColors.cardShadow is meant to be the _color_ of the shadow, this is fine.
  static List<BoxShadow> get generalSoftShadow {
    return [
      BoxShadow(
        color: AppColors.background.withOpacity(0.3), // Use a background-derived shadow for softness
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // Custom border radius helpers (good to keep for consistency)
  static BorderRadius get borderRadius8 => BorderRadius.circular(8);
  static BorderRadius get borderRadius12 => BorderRadius.circular(12);
  static BorderRadius get borderRadius16 => BorderRadius.circular(16);
  static BorderRadius get borderRadius20 => BorderRadius.circular(20);
  static BorderRadius get borderRadius25 => BorderRadius.circular(25); // For larger cards
}
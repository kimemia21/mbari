import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // --- Core Palette ---

  // Primary Accent - A professional, trustworthy fintech blue
  static const Color primary = Color(0xFF0066CC); // A strong, professional blue
  static const Color primaryDark = Color(0xFF0052A3); // Slightly darker for depth
  static const Color primaryLight = Color(0xFF3385FF); // Lighter for accents/hover states

  // Secondary Accent - A complementary, slightly warmer tone for contrast and energy
  static const Color secondary = Color(0xFFFC7057); // A lively coral/terracotta for highlights
  static const Color secondaryDark = Color(0xFFE8644E);
  static const Color secondaryLight = Color(0xFFFD8C78);

  // Backgrounds - Sophisticated, deep neutrals that aren't too stark
  static const Color background = Color(0xFF1B1D2C); // Deep charcoal-navy, softer than pure black
  static const Color backgroundLight = Color(0xFF2C2F40); // For subtle variations and elevated elements
  static const Color backgroundCard = Color(0xFF252838); // Slightly distinct for card surfaces

  // Surface Colors - Elegant, slightly lighter than background, for interactive elements
  static const Color surface = Color(0xFF2F3245); // Main surface for cards, dialogs
  static const Color surfaceVariant = Color(0xFF3C4057); // For input fields, subtle divisions

  // --- Text & Iconography ---

  // Text Colors - High contrast and readability on dark backgrounds
  static const Color textPrimary = Color(0xFFEFEFF1); // Off-white for main text, softer than pure white
  static const Color textSecondary = Color(0xFFBCC2CE); // Muted gray for secondary info
  static const Color textTertiary = Color(0xFF909AAD); // For hints, captions, less critical info
  static const Color textInverse = Color(0xFF1B1D2C); // For text on bright primary/secondary elements

  // --- Functional Colors ---

  // Success - Confident and clear green
  static const Color success = Color(0xFF34C759); // Standard success green
  static const Color successLight = Color(0xFF5CBF76);

  // Warning - Clear, visible yellow/amber
  static const Color warning = Color(0xFFFFCC00); // Accessible warning yellow

  // Error - Strong and unmistakable red
  static const Color error = Color(0xFFFF3B30); // Standard error red

  // Info - Calm and informative blue
  static const Color info = Color(0xFF007AFF); // Standard info blue

  // --- Specific Component Colors ---

  // Buttons & Interactive States
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = surfaceVariant;
  static const Color buttonText = textPrimary;
  static const Color buttonDisabled = Color(0xFF4A4E6B);
  static const Color buttonDisabledText = textTertiary;

  // Navigation (Bottom Nav, App Bar)
  static const Color navBarBackground = backgroundLight; // Slightly lighter than overall background
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = textSecondary;
  static const Color navBarIndicator = primaryLight; // For active tab indicator

  // Dividers & Borders - Subtle and integrated
  static const Color divider = Color(0xFF3E435E); // A soft, dark line
  static const Color border = Color(0xFF4A4E6B);
  static const Color borderFocused = primary; // Highlight focus with primary color

  // Input Fields
  static const Color inputBackground = surfaceVariant;
  static const Color inputBorder = border;
  static const Color inputBorderFocused = primary;
  static const Color inputText = textPrimary;
  static const Color inputHint = textTertiary;

  // --- Gradients ---
  static const List<Color> primaryGradient = [
    primary,
    primaryLight,
  ];

  static const List<Color> accentGradient = [
    secondary,
    secondaryLight,
  ];

  static const List<Color> successGradient = [
    success,
    successLight,
  ];

  // --- Data Visualization & Status ---
  static const Color chartColor1 = primary;
  static const Color chartColor2 = secondary;
  static const Color chartColor3 = success;
  static const Color chartColor4 = info;
  static const Color chartColor5 = Color(0xFFFF9800); // Kept as soft orange
  static const Color chartColor6 = Color(0xFF73C2C7); // Kept as refreshing teal

  static Color getFinancialColor(double value) {
    if (value > 0) return success;
    if (value < 0) return error;
    return textTertiary; // Neutral for zero
  }

  static Color getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
      case 'deposit':
      case 'credit':
        return success;
      case 'expense':
      case 'withdrawal':
      case 'debit':
        return error;
      case 'transfer':
        return info; // Use info blue for transfers
      case 'pending':
        return warning;
      default:
        return textTertiary;
    }
  }

  // --- Utility Methods (kept as is) ---
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color lighten(Color color, [double amount = 0.07]) { // Adjusted default amount for subtlety
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.07]) { // Adjusted default amount for subtlety
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color soften(Color color, [double amount = 0.1]) { // Adjusted default amount
    final hsl = HSLColor.fromColor(color);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  static Color warm(Color color, [double amount = 0.03]) { // Adjusted default amount
    final hsl = HSLColor.fromColor(color);
    final hue = (hsl.hue + (amount * 360)).clamp(0.0, 360.0);
    return hsl.withHue(hue).toColor();
  }

  static Color cool(Color color, [double amount = 0.03]) { // Adjusted default amount
    final hsl = HSLColor.fromColor(color);
    final hue = (hsl.hue - (amount * 360)).clamp(0.0, 360.0);
    return hsl.withHue(hue).toColor();
  }
}

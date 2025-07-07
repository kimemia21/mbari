import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF6366F1); // Main purple-blue from buttons
  static const Color primaryBlueDark = Color(0xFF4F46E5);
  static const Color primaryBlueLight = Color(0xFF818CF8);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFF1A1A1A); // Main dark background
  static const Color backgroundSecondary = Color(0xFF2A2A2A); // Card backgrounds
  static const Color backgroundTertiary = Color(0xFF3A3A3A); // Input fields, elevated surfaces

  // Surface Colors
  static const Color surfacePrimary = Color(0xFF2D2D2D); // Card surfaces
  static const Color surfaceSecondary = Color(0xFF363636); // Elevated surfaces
  static const Color surfaceInput = Color(0xFF404040); // Input field backgrounds

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Main text (white)
  static const Color textSecondary = Color(0xFFB0B0B0); // Secondary text (light gray)
  static const Color textTertiary = Color(0xFF808080); // Tertiary text (darker gray)
  static const Color textHint = Color(0xFF606060); // Hint text, placeholders

  // Accent Colors
  static const Color accentGreen = Color(0xFF10B981); // Success, positive amounts
  static const Color accentRed = Color(0xFFEF4444); // Error, negative amounts, debt
  static const Color accentYellow = Color(0xFFF59E0B); // Warning, pending
  static const Color accentOrange = Color(0xFFF97316); // Late payments, overdue

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Card Colors
  static const Color cardBackground = Color(0xFF2D2D2D);
  static const Color cardBorder = Color(0xFF404040);
  static const Color cardShadow = Color(0x1A000000);

  // Interactive Colors
  static const Color buttonPrimary = Color(0xFF6366F1);
  static const Color buttonSecondary = Color(0xFF374151);
  static const Color buttonDisabled = Color(0xFF4B5563);
  static const Color buttonHover = Color(0xFF5B5BF7);

  // Navigation Colors
  static const Color navBarBackground = Color(0xFF1F1F1F);
  static const Color navBarSelected = Color(0xFF6366F1);
  static const Color navBarUnselected = Color(0xFF9CA3AF);

  // Divider and Border Colors
  static const Color divider = Color(0xFF404040);
  static const Color border = Color(0xFF4B5563);
  static const Color borderLight = Color(0xFF6B7280);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF22C55E),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFF97316),
  ];

  // Shimmer Colors for Loading States
  static const Color shimmerBase = Color(0xFF2D2D2D);
  static const Color shimmerHighlight = Color(0xFF3D3D3D);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Special Colors from your design
  static const Color contributionCard = Color(0xFF6366F1); // Monthly/Emergency fund cards
  static const Color debtCard = Color(0xFFEF4444); // Debt amount card
  static const Color balanceCard = Color(0xFF10B981); // Account balance positive
  static const Color profileCircle = Color(0xFF6366F1); // Profile avatar background

  // Input Field Colors
  static const Color inputBackground = Color(0xFF404040);
  static const Color inputBorder = Color(0xFF525252);
  static const Color inputBorderFocused = Color(0xFF6366F1);
  static const Color inputText = Color(0xFFFFFFFF);
  static const Color inputHint = Color(0xFF9CA3AF);

  // Method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Method to get lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Method to get darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
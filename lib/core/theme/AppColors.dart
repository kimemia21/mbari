import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors - Softer professional tones
  static const Color primaryBlue = Color(0xFF4F46E5); // Muted professional blue
  static const Color primaryBlueDark = Color(0xFF3730A3);
  static const Color primaryBlueLight = Color(0xFF7C3AED);

  // Background Colors - Softer and easier on the eyes
  static const Color backgroundPrimary = Color(0xFFF5F5F5); // Soft gray background
  static const Color backgroundSecondary = Color(0xFFF9F9F9); // Off-white for cards
  static const Color backgroundTertiary = Color(0xFFF1F1F1); // Subtle gray for elevated surfaces

  // Surface Colors - Gentle and comfortable
  static const Color surfacePrimary = Color(0xFFF9F9F9); // Soft white card surfaces
  static const Color surfaceSecondary = Color(0xFFF1F1F1); // Muted elevated surfaces
  static const Color surfaceInput = Color(0xFFEFEFEF); // Soft input field backgrounds

  // Text Colors - Gentler contrast for comfort
  static const Color textPrimary = Color(0xFF374151); // Softer dark gray for main text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray for tertiary text
  static const Color textHint = Color(0xFFD1D5DB); // Subtle gray for hints

  // Accent Colors - Softer and more pleasant
  static const Color accentGreen = Color(0xFF10B981); // Muted success green
  static const Color accentRed = Color(0xFFE11D48); // Softer red for losses
  static const Color accentYellow = Color(0xFFF59E0B); // Warm amber for warnings
  static const Color accentOrange = Color(0xFFED8936); // Gentle orange for attention

  // Status Colors - Comfortable and clear
  static const Color success = Color(0xFF059669); // Softer green for success
  static const Color warning = Color(0xFFD97706); // Warm amber for warnings
  static const Color error = Color(0xFFDC2626); // Muted red for errors
  static const Color info = Color(0xFF0284C7); // Gentle blue for info

  // Card Colors - Soft and inviting
  static const Color cardBackground = Color(0xFFF9F9F9);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x06000000); // Very subtle shadow

  // Interactive Colors - Gentle and welcoming
  static const Color buttonPrimary = Color(0xFF4F46E5);
  static const Color buttonSecondary = Color(0xFFF3F4F6);
  static const Color buttonDisabled = Color(0xFFD1D5DB);
  static const Color buttonHover = Color(0xFF3730A3);

  // Navigation Colors - Soft and comfortable
  static const Color navBarBackground = Color(0xFFF9F9F9);
  static const Color navBarSelected = Color(0xFF4F46E5);
  static const Color navBarUnselected = Color(0xFF9CA3AF);

  // Divider and Border Colors - Gentle separation
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Gradient Colors - Soft and sophisticated
  static const List<Color> primaryGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFED8936),
  ];

  // Shimmer Colors for Loading States
  static const Color shimmerBase = Color(0xFFF1F1F1);
  static const Color shimmerHighlight = Color(0xFFF9F9F9);

  // Overlay Colors - Gentle and non-intrusive
  static const Color overlay = Color(0x30000000);
  static const Color overlayLight = Color(0x15000000);

  // Special Colors for meeting/investment app
  static const Color portfolioCard = Color(0xFF4F46E5); // Portfolio value card
  static const Color profitCard = Color(0xFF10B981); // Profit/gains card
  static const Color lossCard = Color(0xFFE11D48); // Loss/debt card
  static const Color balanceCard = Color(0xFF10B981); // Account balance positive
  static const Color profileCircle = Color(0xFF7C3AED); // Profile avatar background

  // Meeting-specific colors
  static const Color meetingActive = Color(0xFF10B981); // Active meeting indicator
  static const Color meetingScheduled = Color(0xFF4F46E5); // Scheduled meeting
  static const Color meetingCancelled = Color(0xFFE11D48); // Cancelled meeting
  static const Color meetingRoom = Color(0xFFF1F1F1); // Meeting room background

  // Investment-specific colors
  static const Color investmentGrowth = Color(0xFF10B981); // Portfolio growth
  static const Color investmentDecline = Color(0xFFE11D48); // Portfolio decline
  static const Color investmentStable = Color(0xFF9CA3AF); // Stable/neutral
  static const Color investmentAlert = Color(0xFFED8936); // Investment alerts

  // Input Field Colors - Soft and comfortable
  static const Color inputBackground = Color(0xFFF1F1F1);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputBorderFocused = Color(0xFF4F46E5);
  static const Color inputText = Color(0xFF374151);
  static const Color inputHint = Color(0xFF9CA3AF);

  // Chart Colors - Gentle and distinct
  static const List<Color> chartColors = [
    Color(0xFF4F46E5), // Soft blue
    Color(0xFF10B981), // Soft green
    Color(0xFFED8936), // Warm orange
    Color(0xFF7C3AED), // Gentle purple
    Color(0xFFE11D48), // Soft red
    Color(0xFF0891B2), // Muted cyan
    Color(0xFFBE185D), // Soft pink
    Color(0xFF65A30D), // Gentle lime
  ];

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

  // Method to get softer version of a color (lower saturation)
  static Color soften(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }
}
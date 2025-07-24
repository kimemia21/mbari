import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // --- Core Palette - Gen Z Pop Vibes ---

  // Primary - Electric Violet (Bold and confident)
  static const Color primary = Color(0xFF6C5CE7); // Vibrant purple
  static const Color primaryDark = Color(0xFF5A4FCF); // Deeper purple
  static const Color primaryLight = Color(0xFF8B7ED8); // Lighter purple

  // Secondary - Cyber Pink (Energy and personality)
  static const Color secondary = Color(0xFFFF6B9D); // Hot pink
  static const Color secondaryDark = Color(0xFFE55A8A); // Deeper pink
  static const Color secondaryLight = Color(0xFFFF8FB3); // Lighter pink

  // Accent - Electric Cyan (Tech-forward)
  static const Color accent = Color(0xFF00D2FF); // Bright cyan
  static const Color accentDark = Color(0xFF00B8E6); // Deeper cyan
  static const Color accentLight = Color(0xFF33DDFF); // Lighter cyan

  // Tertiary - Lime Green (Fresh and youthful)
  static const Color tertiary = Color(0xFF00E676); // Electric lime
  static const Color tertiaryDark = Color(0xFF00C965); // Deeper lime
  static const Color tertiaryLight = Color(0xFF33EA8B); // Lighter lime

  // --- Backgrounds - Dark mode with depth ---
  static const Color background = Color(0xFF0A0A0); // Deep space black
  static const Color backgroundLight = Color(0xFF151520); // Slightly lighter
  static const Color backgroundCard = Color(0xFF1A1A2E); // Card surfaces
  static const Color backgroundGlass = Color(0xFF1E1E2E); // Glassmorphism base

  // Surface Colors - Layered depth
  static const Color surface = Color(0xFF1E1E2E); // Main surface
  static const Color surfaceVariant = Color(0xFF252538); // Input fields
  static const Color surfaceElevated = Color(0xFF2A2A3E); // Elevated elements

  // --- Text & Iconography ---
  static const Color textPrimary = Color(0xFFF8F9FA); // Pure white text
  static const Color textSecondary = Color(0xFFB8BCC8); // Muted gray
  static const Color textTertiary = Color(0xFF6C7B8A); // Subtle gray
  static const Color textInverse = Color(0xFF0A0A0F); // Dark text for light backgrounds
  static const Color textAccent = Color(0xFFFFFFFF); // Pure white for high contrast

  // --- Functional Colors - Bold and clear ---
  static const Color success = Color(0xFF00E676); // Same as tertiary lime
  static const Color successLight = Color(0xFF4AE896);
  
  static const Color warning = Color(0xFFFFC947); // Bright yellow
  static const Color warningLight = Color(0xFFFFD666);
  
  static const Color error = Color(0xFFFF4757); // Vibrant red
  static const Color errorLight = Color(0xFF6B7A);
  
  static const Color info = Color(0xFF00D2FF); // Same as accent cyan
  static const Color infoLight = Color(0xFF33DDFF);

  // --- Interactive Elements ---
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonAccent = accent;
  static const Color buttonText = textAccent;
  static const Color buttonDisabled = Color(0xFF2A2A3E);
  static const Color buttonDisabledText = textTertiary;

  // Navigation
  static const Color navBarBackground = backgroundLight;
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = textSecondary;
  static const Color navBarIndicator = accent;

  // Borders and Dividers
  static const Color divider = Color(0xFF2A2A3E);
  static const Color border = Color(0xFF3A3A4E);
  static const Color borderFocused = primary;

  // Input Fields
  static const Color inputBackground = surfaceVariant;
  static const Color inputBorder = border;
  static const Color inputBorderFocused = primary;
  static const Color inputText = textPrimary;
  static const Color inputHint = textTertiary;

  // --- Neon Colors for Cyberpunk Effects ---
  static const Color neonPink = Color(0xFFFF0080); // Electric hot pink
  static const Color neonCyan = Color(0xFF00FFFF); // Electric cyan
  static const Color neonGreen = Color(0xFF00FF41); // Electric green
  static const Color neonYellow = Color(0xFFFFFF00); // Electric yellow
  static const Color neonOrange = Color(0xFFFF8000); // Electric orange
  static const Color neonPurple = Color(0xFF8000FF); // Electric purple

  // --- Aurora Colors ---
  static const Color auroraGreen = Color(0xFF00FF88); // Aurora green
  static const Color auroraPurple = Color(0xFF8844FF); // Aurora purple
  static const Color auroraBlue = Color(0xFF4488FF); // Aurora blue
  static const Color auroraPink = Color(0xFFFF44AA); // Aurora pink

  // --- Gradients - Pop and vibrant ---
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7), // Electric violet
    Color(0xFF8B7ED8), // Lighter purple
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B9D), // Cyber pink
    Color(0xFFFF8FB3), // Lighter pink
  ];

  static const List<Color> accentGradient = [
    Color(0xFF00D2FF), // Electric cyan
    Color(0xFF33DDFF), // Lighter cyan
  ];

  static const List<Color> heroGradient = [
    Color(0xFF6C5CE7), // Electric violet
    Color(0xFFFF6B9D), // Cyber pink
    Color(0xFF00D2FF), // Electric cyan
  ];

  static const List<Color> neonGradient = [
    Color(0xFF00E676), // Lime green
    Color(0xFF00D2FF), // Electric cyan
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B9D), // Cyber pink
    Color(0xFFFFC947), // Bright yellow
  ];

  static const List<Color> glassGradient = [
    Color(0x80FFFFFF), // Semi-transparent white
    Color(0x20FFFFFF), // Very transparent white
  ];

  // --- New Gradient Collections for Theme ---
  static const List<Color> rainbowGradient = [
    Color(0xFFFF0080), // Neon pink
    Color(0xFFFF8000), // Neon orange
    Color(0xFFFFFF00), // Neon yellow
    Color(0xFF00FF41), // Neon green
    Color(0xFF00FFFF), // Neon cyan
    Color(0xFF4488FF), // Aurora blue
    Color(0xFF8000FF), // Neon purple
  ];

  static const List<Color> retroWaveGradient = [
    Color(0xFF8000FF), // Neon purple
    Color(0xFFFF0080), // Neon pink
    Color(0xFF00FFFF), // Neon cyan
  ];

  static const List<Color> auroraGradient = [
    auroraGreen,
    auroraPurple,
    auroraBlue,
    auroraPink,
  ];

  static const List<Color> vaporwaveGradient = [
    Color(0xFFFF0080), // Neon pink
    Color(0xFF8000FF), // Neon purple
    Color(0xFF00FFFF), // Neon cyan
  ];

  // --- Data Visualization & Charts ---
  static const Color chartColor1 = primary;      // Electric violet
  static const Color chartColor2 = secondary;    // Cyber pink
  static const Color chartColor3 = accent;       // Electric cyan
  static const Color chartColor4 = tertiary;     // Lime green
  static const Color chartColor5 = warning;      // Bright yellow
  static const Color chartColor6 = Color(0xFFE17055); // Coral orange

  // --- Special Effects Colors ---
  static const Color neonGlow = Color(0xFF00E676); // Lime glow
  static const Color cyberGlow = Color(0xFF00D2FF); // Cyan glow
  static const Color purpleGlow = Color(0xFF6C5CE7); // Purple glow
  static const Color pinkGlow = Color(0xFFFF6B9D); // Pink glow

  // Shadow colors for depth
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  static const Color shadowColored = Color(0x266C5CE7); // Purple-tinted shadow

  // --- Utility Methods ---
  static Color getFinancialColor(double value) {
    if (value > 0) return success;
    if (value < 0) return error;
    return textTertiary;
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
        return accent;
      case 'pending':
        return warning;
      default:
        return textTertiary;
    }
  }

  static Color getRandomNeonColor() {
    final colors = [neonPink, neonCyan, neonGreen, neonYellow, neonOrange, neonPurple];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  static Color getRandomAuroraColor() {
    final colors = [auroraGreen, auroraPurple, auroraBlue, auroraPink];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  // Enhanced utility methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color saturate(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  static Color desaturate(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  // Neon glow effect
  static Color neonGlowEffect(Color color, [double intensity = 0.3]) {
    return color.withOpacity(intensity);
  }

  // Glassmorphism helper
  static Color glassEffect(Color color, [double opacity = 0.1]) {
    return color.withOpacity(opacity);
  }

  // Get contrasting text color for any background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textInverse : textAccent;
  }

  // Generate harmonious color based on primary
  static Color getHarmoniousColor(Color baseColor, [double hueShift = 30.0]) {
    final hsl = HSLColor.fromColor(baseColor);
    final newHue = (hsl.hue + hueShift) % 360;
    return hsl.withHue(newHue).toColor();
  }

  // Create color with specific opacity for glassmorphism
  static Color createGlassColor(Color baseColor, [double opacity = 0.1]) {
    return baseColor.withOpacity(opacity);
  }

  // Mix two colors
  static Color mixColors(Color color1, Color color2, [double ratio = 0.5]) {
    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    final a = (color1.alpha * (1 - ratio) + color2.alpha * ratio).round();
    
    return Color.fromARGB(a, r, g, b);
  }
}
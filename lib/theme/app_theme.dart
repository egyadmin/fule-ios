import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Blue Theme (Original)
  static const Color primaryColor = Color(0xFF1E88E5);      // Blue
  static const Color primaryDark = Color(0xFF1565C0);       // Dark Blue
  static const Color primaryLight = Color(0xFF64B5F6);      // Light Blue
  static const Color accentColor = Color(0xFFFF6D00);       // Orange accent
  static const Color successColor = Color(0xFF4CAF50);      // Green
  static const Color warningColor = Color(0xFFFFC107);      // Yellow
  static const Color errorColor = Color(0xFFE53935);        // Red
  static const Color infoColor = Color(0xFF2196F3);         // Info Blue
  
  // Fuel Type Colors
  static const Color petrol80Color = Color(0xFF8BC34A);
  static const Color petrol92Color = Color(0xFF4CAF50);
  static const Color petrol95Color = Color(0xFF009688);
  static const Color dieselColor = Color(0xFFFF9800);
  
  // Header Color - Blue Theme
  static const Color headerColor = Color(0xFF1E88E5);       // Blue Header
  static const Color headerTextColor = Colors.white;        // White text on blue
  
  // Notification Badge Color
  static const Color badgeColor = Color(0xFFE53935);        // Red badge
  
  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Input Field Colors
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = Color(0xFF1E88E5);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF1E88E5);
  static const Color buttonText = Colors.white;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light Theme - Professional Blue Style
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      
      // App Bar Theme - Blue Header
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: headerColor,
        foregroundColor: headerTextColor,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: headerTextColor,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Card Theme - Modern
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button Theme - Blue Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPrimary,
          foregroundColor: buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.cairo(color: textSecondary),
        hintStyle: GoogleFonts.cairo(color: textHint),
      ),
      
      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.cairo(
          color: textPrimary,
          fontSize: 14,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: inputBorder,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Text Theme with Cairo Font
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.cairo(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.cairo(color: textPrimary, fontSize: 14),
        bodySmall: GoogleFonts.cairo(color: textSecondary, fontSize: 12),
        labelLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.cairo(color: textSecondary),
        labelSmall: GoogleFonts.cairo(color: textSecondary),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: darkBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accentColor,
        error: errorColor,
        surface: Color(0xFF1E1E1E),
        onPrimary: Colors.white,
      ),
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    );
  }
}

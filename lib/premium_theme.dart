import 'package:flutter/material.dart';

class PremiumTheme {
  PremiumTheme._();

  // ============================================================
  // GOLD COLORS
  // ============================================================

  static const Color gold = Color(0xFFFFD54F);
  static const Color brightGold = Color(0xFFFFC107);
  static const Color lightGold = Color(0xFFFFE082);
  static const Color darkGold = Color(0xFFB8860B);

  // ============================================================
  // PURPLE COLORS
  // ============================================================

  static const Color purple = Color(0xFF7B1FA2);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color darkPurple = Color(0xFF21002F);
  static const Color purpleBlack = Color(0xFF100719);

  // ============================================================
  // BACKGROUND COLORS
  // ============================================================

  static const Color background = Color(0xFF09060F);
  static const Color surface = Color(0xFF160C22);
  static const Color surface2 = Color(0xFF21102F);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color mutedText = Colors.white54;

  // ============================================================
  // NORMAL READABLE FONT
  // ============================================================
  //
  // No special King font.
  // Uses Flutter's normal readable font.
  //

  static const TextStyle titleText = TextStyle(
    color: gold,
    fontSize: 21,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingText = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyText = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle secondaryBodyText = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // ============================================================
  // GOLD GRADIENT
  // ============================================================

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lightGold,
      brightGold,
      gold,
    ],
  );

  // ============================================================
  // PURPLE GRADIENT
  // ============================================================

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepPurple,
      purple,
      darkPurple,
    ],
  );

  // ============================================================
  // PREMIUM BACKGROUND GRADIENT
  // ============================================================

  static const LinearGradient premiumBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      background,
      deepPurple,
      purpleBlack,
      background,
    ],
  );

  // ============================================================
  // PREMIUM CARD
  // ============================================================

  static BoxDecoration premiumCard({
    double radius = 18,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surface2,
          surface,
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: gold.withValues(alpha: 0.45),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ============================================================
  // GOLD CARD
  // ============================================================

  static BoxDecoration goldCard({
    double radius = 18,
  }) {
    return BoxDecoration(
      gradient: goldGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: gold.withValues(alpha: 0.25),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM BUTTON
  // ============================================================

  static ButtonStyle premiumButton({
    Color? backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? gold,
      foregroundColor: Colors.black,
      elevation: 5,
      shadowColor: gold.withValues(alpha: 0.35),
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // OUTLINED PREMIUM BUTTON
  // ============================================================

  static ButtonStyle outlinedButton() {
    return OutlinedButton.styleFrom(
      foregroundColor: gold,
      minimumSize: const Size(0, 50),
      side: const BorderSide(
        color: gold,
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // ICON STYLE
  // ============================================================

  static const IconThemeData iconTheme = IconThemeData(
    color: gold,
    size: 24,
  );

  // ============================================================
  // PREMIUM ICON CONTAINER
  // ============================================================

  static Widget iconBox(
    IconData icon, {
    double size = 48,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: purpleGradient,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: gold.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor ?? gold,
        size: size * 0.48,
      ),
    );
  }

  // ============================================================
  // PREMIUM DIVIDER
  // ============================================================

  static Widget divider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            gold.withValues(alpha: 0.65),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMPLETE FLUTTER THEME
  // ============================================================

  static ThemeData theme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: gold,
      secondary: purple,
      surface: surface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: scheme,

      // Normal readable Flutter font.
      fontFamily: null,

      scaffoldBackgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: gold,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: gold,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // ========================================================
      // ICONS
      // ========================================================

      iconTheme: const IconThemeData(
        color: gold,
        size: 24,
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withValues(alpha: 0.40),
            width: 1,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 5,
          shadowColor: gold,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // FILLED BUTTON
      // ========================================================

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlinedButton(),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        prefixIconColor: gold,
        suffixIconColor: gold,

        labelStyle: const TextStyle(
          color: lightGold,
          fontSize: 14,
        ),

        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: gold.withValues(alpha: 0.30),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: gold.withValues(alpha: 0.30),
          ),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          borderSide: BorderSide(
            color: gold,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,

        indicatorColor: purple,

        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: gold,
                size: 25,
              );
            }

            return const IconThemeData(
              color: Colors.white70,
              size: 23,
            );
          },
        ),

        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              );
            }

            return const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            );
          },
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme: DividerThemeData(
        color: gold.withValues(alpha: 0.25),
        thickness: 1,
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: gold.withValues(alpha: 0.45),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        actionTextColor: gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return gold;
            }
            return Colors.transparent;
          },
        ),
        checkColor: WidgetStateProperty.all(
          Colors.black,
        ),
      ),

      // ========================================================
      // SWITCH
      // ========================================================

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return gold;
            }
            return Colors.white54;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return purple;
            }
            return Colors.white24;
          },
        ),
      ),
    );
  }
}

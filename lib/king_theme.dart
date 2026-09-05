import 'package:flutter/material.dart';

class KingTheme {
  KingTheme._();

  // ============================================================
  // ROYAL COLORS
  // ============================================================

  static const Color royalBlack =
      Color(0xFF09060F);

  static const Color royalBlack2 =
      Color(0xFF130B1F);

  static const Color deepPurple =
      Color(0xFF4A148C);

  static const Color royalPurple =
      Color(0xFF7B1FA2);

  static const Color royalGold =
      Color(0xFFFFD54F);

  static const Color brightGold =
      Color(0xFFFFC107);

  static const Color softGold =
      Color(0xFFFFE082);

  static const Color royalWhite =
      Color(0xFFFFFDF7);

  // ============================================================
  // MAIN THEME
  // ============================================================

  static ThemeData theme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: royalPurple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: royalGold,
      secondary: royalPurple,
      surface: royalBlack2,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: royalWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          royalBlack,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: royalBlack,
        foregroundColor: royalWhite,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: royalGold,
        ),
        actionsIconTheme: IconThemeData(
          color: royalGold,
        ),
        titleTextStyle: TextStyle(
          color: royalGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // ========================================================
      // ICONS
      // ========================================================

      iconTheme: const IconThemeData(
        color: royalGold,
        size: 24,
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        color: royalBlack2,
        elevation: 4,
        shadowColor:
            Colors.black54,
        surfaceTintColor:
            Colors.transparent,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0x66FFD54F),
            width: 1,
          ),
        ),
      ),

      // ========================================================
      // BUTTONS
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              royalGold,
          foregroundColor:
              Colors.black,
          elevation: 4,
          shadowColor:
              royalGold,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      filledButtonTheme:
          FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:
              royalGold,
          foregroundColor:
              Colors.black,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              royalGold,
          side:
              const BorderSide(
            color: royalGold,
            width: 1.2,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              royalGold,
        ),
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            royalBlack2,
        prefixIconColor:
            royalGold,
        suffixIconColor:
            royalGold,
        labelStyle:
            const TextStyle(
          color: softGold,
        ),
        hintStyle:
            const TextStyle(
          color: Colors.white54,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0x55FFD54F),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0x55FFD54F),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color: royalGold,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================

      navigationBarTheme:
          NavigationBarThemeData(
        backgroundColor:
            royalBlack2,
        surfaceTintColor:
            Colors.transparent,
        indicatorColor:
            royalPurple,
        elevation: 8,

        iconTheme:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const IconThemeData(
                color: royalGold,
                size: 25,
              );
            }

            return const IconThemeData(
              color: Colors.white70,
              size: 23,
            );
          },
        ),

        labelTextStyle:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const TextStyle(
                color: royalGold,
                fontWeight:
                    FontWeight.bold,
              );
            }

            return const TextStyle(
              color: Colors.white70,
            );
          },
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme:
          const DividerThemeData(
        color:
            Color(0x44FFD54F),
        thickness: 1,
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: royalGold,
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme:
          DialogThemeData(
        backgroundColor:
            royalBlack2,
        surfaceTintColor:
            Colors.transparent,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(22),
          side:
              const BorderSide(
            color:
                Color(0x66FFD54F),
          ),
        ),
        titleTextStyle:
            const TextStyle(
          color: royalGold,
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor:
            royalBlack2,
        surfaceTintColor:
            Colors.transparent,
        modalBackgroundColor:
            royalBlack2,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme:
          SnackBarThemeData(
        backgroundColor:
            royalBlack2,
        contentTextStyle:
            const TextStyle(
          color: royalWhite,
        ),
        actionTextColor:
            royalGold,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // ROYAL GRADIENT
  // ============================================================

  static const LinearGradient
      royalGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      royalBlack,
      deepPurple,
      royalBlack2,
    ],
  );

  // ============================================================
  // GOLD GRADIENT
  // ============================================================

  static const LinearGradient
      goldGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      softGold,
      brightGold,
      royalGold,
    ],
  );
}

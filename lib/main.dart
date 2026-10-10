import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'state/game_provider.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const CasusOyunuApp());
}

class CasusOyunuApp extends StatelessWidget {
  const CasusOyunuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Casus Oyunu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A1A24),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF232332),
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFFFFD600),
            error: Color(0xFFFF3366),
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1A1A24),
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
            titleTextStyle: GoogleFonts.bungee(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
        ),
        home: const SetupScreen(),
      ),
    );
  }
}
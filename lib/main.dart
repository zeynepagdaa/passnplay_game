import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const SetupScreen(),
      ),
    );
  }
}
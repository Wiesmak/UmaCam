import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:umacam/pages/pages.dart';

class UmaCamApp extends StatelessWidget {
  const UmaCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'UmaCam',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true,
          ),
          home: const UmaCamCameraPage(),
        );
      },
    );
  }
}
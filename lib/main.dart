import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:umacam/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(const UmaCamApp());
}
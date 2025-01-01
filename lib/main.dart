import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'firebase_options.dart';
import 'homePage.dart';
const apiKey = "AIzaSyBuoaXOxAt4tCR5hCQyMRlDW1lEvrpy7os";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexoraAI',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF075E54),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(),
    );
  }
}











class TextWithImage extends StatelessWidget {
  const TextWithImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Coming soon... ✋",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

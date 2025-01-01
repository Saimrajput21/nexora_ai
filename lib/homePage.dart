import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexora_ai/textonly.dart';

import 'gradientbackground.dart';
import 'main.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GradientBackground(),
        DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'NexoraAI',
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      Colors.cyanAccent,
                      Colors.blueAccent,
                      Colors.purpleAccent,
                      Colors.tealAccent,
                    ],
                  ),
                ],
                repeatForever: true,
              ),
              centerTitle: true,
              bottom: const TabBar(
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.text_fields), text: "Text"),
                  Tab(icon: Icon(Icons.image), text: "Image"),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                TextOnly(),
                TextWithImage(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
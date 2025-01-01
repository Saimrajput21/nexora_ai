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
        primaryColor: const Color(0xFF075E54), // WhatsApp primary color
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(),
    );
  }
}

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

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2C5364),
            Color(0xFF0F2027),
            Color(0xFF203A43),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;
  final File? image;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.role,
    required this.text,
    this.image,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(timestamp);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
            colors: [Color(0xFF25D366), Color(0xFF128C7E)],
          )
              : const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFEDEDED)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (role == 'User')
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            if (role == 'Gemini')
              SelectableText(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(image!, height: 150, fit: BoxFit.cover),
              ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAddImage;
  final bool isLoading;

  const InputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAddImage,
    required this.isLoading,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isEmojiPickerVisible = false;
  late stt.SpeechToText _speech; // Speech recognition
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize speech-to-text
  }

  // Toggle Emoji Picker
  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  // Start listening for speech
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          widget.controller.text = result.recognizedWords;
        });
      });
    }
  }

  // Stop listening for speech
  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Voice Animation (Shows only when listening)
        if (_isListening)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: SpinKitRipple(
                color: Colors.tealAccent,
                size: 50.0,
              ),
            ),
          ),
        // Emoji Picker
        if (_isEmojiPickerVisible)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: EmojiPicker(
              config:const Config(
                height: 256,
                checkPlatformCompatibility: true,
                viewOrderConfig: ViewOrderConfig(
                  top: EmojiPickerItem.categoryBar,
                  middle: EmojiPickerItem.emojiView,
                  bottom: EmojiPickerItem.searchBar,
                ),
              ),
              onEmojiSelected: (category, emoji) {
                setState(() {
                  widget.controller.text += emoji.emoji;
                });
              },
            ),
          ),

        // Input Box
        Card(
          elevation: 5.0,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                // Emoji Picker Button
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.white70),
                  onPressed: _toggleEmojiPicker,
                ),
                // Mic Button for Speech-to-Text
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.white70,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => widget.onSend(),
                  ),
                ),
                // Send Button
                IconButton(
                  icon: widget.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : const Icon(Icons.send, color: Colors.white70),
                  onPressed: widget.onSend,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NotesManager {
  final List<Map<String, dynamic>> _notes = [];

  void addNote(String note, DateTime timestamp) {
    _notes.add({"note": note, "timestamp": timestamp});
  }

  List<String> getNotes() {
    return _notes.map((note) => note["note"] as String).toList();
  }

  String searchNotes(String query) {
    for (var note in _notes) {
      if (note["note"].toLowerCase().contains(query.toLowerCase())) {
        return note["note"];
      }
    }
    return "Sorry, no relevant notes found.";
  }
}

class TextOnly extends StatefulWidget {
  const TextOnly({super.key});

  @override
  State<TextOnly> createState() => _TextOnlyState();
}

class _TextOnlyState extends State<TextOnly> {
  final NotesManager _notesManager = NotesManager();
  bool loading = false;
  List<Map<String, dynamic>> chat = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final gemini = GoogleGemini(apiKey: apiKey);

  void sendTextMessage(String text) {
    if (text
        .trim()
        .isEmpty) return;
    DateTime currentTime = DateTime.now();

    // Check if user wants to add a note
    if (text.toLowerCase().startsWith("note:")) {
      String note = text.substring(5).trim();
      _notesManager.addNote(note, currentTime);
      setState(() {
        chat.add({"role": "User", "text": text, "timestamp": currentTime});
        chat.add({
          "role": "Gemini",
          "text": "Your note has been saved!",
          "timestamp": DateTime.now(),
        });
      });
      _textController.clear();
      _scrollToEnd();
      return;
    }

    // Check if user wants to retrieve notes
    if (text.toLowerCase().startsWith("search:")) {
      String query = text.substring(7).trim();
      String result = _notesManager.searchNotes(query);
      setState(() {
        chat.add({"role": "User", "text": text, "timestamp": currentTime});
        chat.add(
            {"role": "Gemini", "text": result, "timestamp": DateTime.now()});
      });
      _textController.clear();
      _scrollToEnd();
      return;
    }

    // Regular message handling
    setState(() {
      loading = true;
      chat.add({"role": "User", "text": text, "timestamp": currentTime});
      _textController.clear();
    });
    FocusScope.of(context).unfocus();

    // Scroll to the bottom immediately after adding user's message
    _scrollToEnd();

    gemini.generateFromText(text).then((response) {
      setState(() {
        chat.add({
          "role": "Gemini",
          "text": response.text,
          "timestamp": DateTime.now(),
        });
        loading = false;
      });
      _scrollToEnd(); // Scroll to the bottom after AI response
    }).catchError((error) {
      setState(() {
        chat.add({
          "role": "Gemini",
          "text": "Error: $error",
          "timestamp": DateTime.now(),
        });
        loading = false;
      });
      _scrollToEnd(); // Scroll to the bottom after an error message
    });
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: chat.length,
            itemBuilder: (context, index) {
              return ChatBubble(
                role: chat[index]['role'],
                text: chat[index]['text'],
                isUser: chat[index]['role'] == 'User',
                timestamp: chat[index]['timestamp'],
              );
            },
          ),
        ),
        InputField(
          controller: _textController,
          onSend: () => sendTextMessage(_textController.text),
          isLoading: loading,
        ),
      ],
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

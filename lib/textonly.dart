
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

import 'classes/chatbubble.dart';
import 'inputField.dart';
import 'main.dart';
import 'noteManger.dart';

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
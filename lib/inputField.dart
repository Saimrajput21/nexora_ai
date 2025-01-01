import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_to_text.dart'as stt;
import 'dart:io';
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
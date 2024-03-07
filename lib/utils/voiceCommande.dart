import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(VoiceCommandApp());
}

class VoiceCommandApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceCommand(),
    );
  }
}

class VoiceCommand extends StatefulWidget {
  @override
  _VoiceCommandState createState() => _VoiceCommandState();
}

class _VoiceCommandState extends State<VoiceCommand> {
  @override
  void initState() {
    super.initState();
    _initializeAlan();
  }

  @override
  void dispose() {
    AlanVoice.onCommand.remove(_handleCommand);
    super.dispose();
  }

  void _initializeAlan() async {
    await _requestMicrophonePermission();

    AlanVoice.addButton("c77bf737e45a8600dfa57d6594e3f9422e956eca572e1d8b807a3e2338fdd0dc/stage");

    AlanVoice.onCommand.add((command) {
      debugPrint("got new command ${command.toString()}");
      _handleCommand(command?.data);
    });

    _playCommand();
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      print("Microphone permission granted");
    } else if (status.isDenied) {
      print("Microphone permission denied");
      // You can display a message to the user explaining why the permission is necessary
    } else if (status.isPermanentlyDenied) {
      print("Microphone permission permanently denied");
      // You can redirect the user to the app settings to manually enable the permission
    }
  }

  void _playCommand() {
    var command = jsonEncode({"action": "openHomePage"});
    AlanVoice.playText("Hello from Alan!");
    AlanVoice.playCommand(command);
  }

  void _handleCommand(Map<String, dynamic>? command) {
    if (command == null) return;
    final String? commandName = command["command"];

    switch (commandName) {
      case "back":
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;
      default:
        print("Unrecognized command: $commandName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voice Command App"),
      ),
      body: Center(
        child: Text("Your app content goes here"),
      ),
    );
  }
}

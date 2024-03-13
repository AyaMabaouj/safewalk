import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:safewalk/utils/ocr_text_detection.dart';
import '../utils/codeScanner.dart';

class TextRecognitionApp extends StatefulWidget {
  @override
  _TextRecognitionAppState createState() => _TextRecognitionAppState();
}

class _TextRecognitionAppState extends State<TextRecognitionApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FlutterTts flutterTts = FlutterTts();
  String _platformVersion = 'Unknown'; // Define _platformVersion here

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to the tab controller to speak when changing tabs
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        // Speak when OCR tab is selected
        _speak('This is text OCR detection', langdetect.detect("text"));
      } else if (_tabController.index == 1) {
        // Speak when QRCode/Barcode tab is selected
        _speak('This is QRCode/Barcode Scanner', langdetect.detect("text"));
      }
    });

    initPlatformState();
    langdetect.initLangDetect(); // Initialize language detection
  }

  @override
  void dispose() {
    _tabController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text, String detectedLanguage) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterMobileVision.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 108, 149, 245)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Recognition'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'OCR'),
              Tab(text: 'QRCode/Barcode'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _getOcrScreen(context),
            _getCodeScreen(context),
          ],
        ),
      ),
    );
  }

  ///
  /// QRCODE Screen
  ///
  Widget _getCodeScreen(BuildContext context) {
    return CodeScanner();
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
  speakText("Click on the Read button at the bottom to capture the text.");
    return OcrScreen(); 
  }

  void speakText(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
    await flutterTts.setSpeechRate(0.5);

  }
}

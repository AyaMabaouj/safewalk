import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:safewalk/utils/ocr_text_detail.dart';

class OcrTextWidget extends StatelessWidget {
  final OcrText text;
  FlutterTts flutterTts = FlutterTts();
  String _platformVersion = 'Unknown';

  OcrTextWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.star),
      title: Text(text.value),
      subtitle: Text(text.language),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OcrTextDetail(text),
          ),
        );
      },
    );
  }
}

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  Size? _previewOcr;
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK; // Default to back camera
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = true;
  bool _waitTapOcr = true;
    bool _showTextOcr = true;

  List<OcrText> _textsOcr = [];
  FlutterTts flutterTts = FlutterTts();
  String _platformVersion = 'Unknown'; // Initialize _platformVersion here

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _previewOcr = Size(2400, 1080); // Set the default preview size
    langdetect.initLangDetect();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await FlutterMobileVision.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  ///
  /// OCR Method
  ///
  Future<Null> _read() async {
    List<OcrText> texts = [];

    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        waitTap: _waitTapOcr,
        showText:_showTextOcr,
        camera: _cameraOcr,
        preview: _previewOcr ?? Size(2400, 1080), // Set the desired preview size here
      );

      // Detect language for each recognized text and speak accordingly
      for (OcrText text in texts) {
        String detectedLanguage = await langdetect.detect(text.value);
        _speak(text.value, detectedLanguage);
      }
    } on Exception {
      texts.add(OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }

Widget _getOcrScreen(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Manage Text Detection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SwitchListTile(
        title: const Text('Auto focus:'),
        value: _autoFocusOcr,
        onChanged: (value) => setState(() => _autoFocusOcr = value),
      ),
      SwitchListTile(
        title: const Text('Torch:'),
        value: _torchOcr,
        onChanged: (value) => setState(() => _torchOcr = value),
      ),
      SwitchListTile(
        title: const Text('Return all texts:'),
        value: _multipleOcr,
        onChanged: (value) => setState(() => _multipleOcr = value),
      ),
      SwitchListTile(
        title: const Text('Capture when tap screen:'),
        value: _waitTapOcr,
        onChanged: (value) => setState(() => _waitTapOcr = value),
      ),
      SwitchListTile(
        title: const Text('Show text:'),
        value: _showTextOcr,
        onChanged: (value) => setState(() => _showTextOcr = value),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.only(
            top: 12.0,
            bottom: 12.0,
          ),
          children: _textsOcr.map((text) => OcrTextWidget(text)).toList(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Row(
          children: [
        Expanded(
  child: Container(
    width: double.infinity,
    height: 70.0, // Définir la hauteur souhaitée
    child: ElevatedButton.icon(
      onPressed: () {
        _read();
        _speak("Tap on the screen to capture the text", "en");
      },
      icon: Icon(
        Icons.play_arrow,
        size: 40,
        color: Colors.white,
      ),
      label: Text(
        'READ!',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
    ),
  ),
),

          ],
        ),
      ),
    ],
  );
}




  ///
  /// Speak method
  Future<void> _speak(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return _getOcrScreen(context);
  }
}

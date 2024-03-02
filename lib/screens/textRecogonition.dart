import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/barcode_detail.dart';
import '../utils/face_detail.dart';
import '../utils/ocr_text_detail.dart';

class TextRecognitionApp extends StatefulWidget {
  @override
  _TextRecognitionAppState createState() => _TextRecognitionAppState();
}

class _TextRecognitionAppState extends State<TextRecognitionApp> {
  String _platformVersion = 'Unknown';
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    // Stop the Text-to-Speech engine when the activity is disposed
    flutterTts.stop();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterMobileVision.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  int? _cameraBarcode = FlutterMobileVision.CAMERA_BACK;
  int? _onlyFormatBarcode = Barcode.ALL_FORMATS;
  bool _autoFocusBarcode = true;
  bool _torchBarcode = false;
  bool _multipleBarcode = false;
  bool _waitTapBarcode = true;
  bool _showTextBarcode = false;
  Size? _previewBarcode;
  List<Barcode> _barcodes = [];

  int? _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = true;
  bool _waitTapOcr = true;
  bool _showTextOcr = true;
  Size? _previewOcr;
  List<OcrText> _textsOcr = [];

  int? _cameraFace = FlutterMobileVision.CAMERA_FRONT;
  bool _autoFocusFace = true;
  bool _torchFace = false;
  bool _multipleFace = true;
  bool _showTextFace = true;
  Size? _previewFace;
  List<Face> _faces = [];

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    initPlatformState();
    langdetect.initLangDetect(); // Initialize language detection

    FlutterMobileVision.start().then((previewSizes) => setState(() {
          if (previewSizes[_cameraBarcode] == null) {
            return;
          }
          _previewBarcode = previewSizes[_cameraBarcode]!.first;
          _previewOcr = previewSizes[_cameraOcr]!.first;
          _previewFace = previewSizes[_cameraFace]!.first;
        }));
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 108, 149, 245)),
        useMaterial3: true,

      ),
          debugShowCheckedModeBanner: false,

      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.black54,
              tabs: [Tab(text: 'Barcode'), Tab(text: 'OCR'), Tab(text: 'Face')],
            ),
            title: Text('Text Recoginition'),

             leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ),
          body: TabBarView(children: [
            _getBarcodeScreen(context),
            _getOcrScreen(context),
            _getFaceScreen(context),
          ]),
        ),
      ),
    );
  }

  ///
  /// Scan formats
  ///
  List<DropdownMenuItem<int>> _getFormats() {
    List<DropdownMenuItem<int>> formatItems = [];

    Barcode.mapFormat.forEach((key, value) {
      formatItems.add(
        DropdownMenuItem(
          child: Text(value),
          value: key,
        ),
      );
    });

    return formatItems;
  }

  ///
  /// Camera list
  ///
  List<DropdownMenuItem<int>> _getCameras() {
    List<DropdownMenuItem<int>> cameraItems = [];

    cameraItems.add(DropdownMenuItem(
      child: Text('BACK'),
      value: FlutterMobileVision.CAMERA_BACK,
    ));

    cameraItems.add(DropdownMenuItem(
      child: Text('FRONT'),
      value: FlutterMobileVision.CAMERA_FRONT,
    ));

    return cameraItems;
  }

  ///
  /// Preview sizes list
  ///
  List<DropdownMenuItem<Size>> _getPreviewSizes(int facing) {
    List<DropdownMenuItem<Size>> previewItems = [];

    List<Size>? sizes = FlutterMobileVision.getPreviewSizes(facing);

    if (sizes != null) {
      sizes.forEach((size) {
        previewItems.add(
          DropdownMenuItem(
            child: Text(size.toString()),
            value: size,
          ),
        );
      });
    } else {
      previewItems.add(
        DropdownMenuItem(
          child: Text('Empty'),
          value: null,
        ),
      );
    }

    return previewItems;
  }

  ///
  /// Barcode Screen
  ///
  Widget _getBarcodeScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewBarcode = null;
          setState(() => _cameraBarcode = value);
        },
        value: _cameraBarcode,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraBarcode ?? 0),
        onChanged: (value) {
          setState(() => _previewBarcode = value);
        },
        value: _previewBarcode,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Scan format only:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getFormats(),
        onChanged: (value) => setState(
          () => _onlyFormatBarcode = value,
        ),
        value: _onlyFormatBarcode,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusBarcode,
      onChanged: (value) => setState(() => _autoFocusBarcode = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchBarcode,
      onChanged: (value) => setState(() => _torchBarcode = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Multiple Scan:'),
      value: _multipleBarcode,
      onChanged: (value) => setState(() {
        _multipleBarcode = value;
        if (value) _waitTapBarcode = true;
      }),
    ));

    items.add(SwitchListTile(
      title: const Text('Wait a tap to capture:'),
      value: _waitTapBarcode,
      onChanged: (value) => setState(() {
        _waitTapBarcode = value;
        if (!value) _multipleBarcode = false;
      }),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextBarcode,
      onChanged: (value) => setState(() => _showTextBarcode = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _scan,
          child: Text('SCAN!',style: TextStyle(color: Colors.white),),
           style: ElevatedButton.styleFrom(
    backgroundColor:  Color.fromARGB(255, 108, 149, 245) // Set button color to blue
  ),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _barcodes
            .map(
              (barcode) => BarcodeWidget(barcode),
            )
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// Barcode Method
  ///
  Future<Null> _scan() async {
    List<Barcode> barcodes = [];
    Size _scanpreviewOcr = _previewOcr ?? FlutterMobileVision.PREVIEW;
    try {
      barcodes = await FlutterMobileVision.scan(
        flash: _torchBarcode,
        autoFocus: _autoFocusBarcode,
        formats: _onlyFormatBarcode ?? Barcode.ALL_FORMATS,
        multiple: _multipleBarcode,
        waitTap: _waitTapBarcode,
        //OPTIONAL: close camera after tap, even if there are no detection.
        //Camera would usually stay on, until there is a valid detection
        forceCloseCameraOnTap: true,
        //OPTIONAL: path to save image to. leave empty if you do not want to save the image
        imagePath: '', //'path/to/file.jpg'
        showText: _showTextBarcode,
        preview: _previewBarcode ?? FlutterMobileVision.PREVIEW,
        scanArea: Size(_scanpreviewOcr.width - 20, _scanpreviewOcr.height - 20),
        camera: _cameraBarcode ?? FlutterMobileVision.CAMERA_BACK,
        fps: 15.0,
      );
    } on Exception {
      barcodes.add(Barcode('Failed to get barcode.'));
    }

    if (!mounted) return;

    setState(() => _barcodes = barcodes);
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewOcr = null;
          setState(() => _cameraOcr = value);
        },
        value: _cameraOcr,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraOcr ?? 0),
        onChanged: (value) {
          setState(() => _previewOcr = value);
        },
        value: _previewOcr,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusOcr,
      onChanged: (value) => setState(() => _autoFocusOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchOcr,
      onChanged: (value) => setState(() => _torchOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Return all texts:'),
      value: _multipleOcr,
      onChanged: (value) => setState(() => _multipleOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Capture when tap screen:'),
      value: _waitTapOcr,
      onChanged: (value) => setState(() => _waitTapOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextOcr,
      onChanged: (value) => setState(() => _showTextOcr = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _read,
          child: Text('READ!',style: TextStyle(color: Colors.white),),
           style: ElevatedButton.styleFrom(
    backgroundColor:  Color.fromARGB(255, 108, 149, 245) // Set button color to blue
  ),),
        ),
    
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _textsOcr
            .map(
              (text) => OcrTextWidget(text),
            )
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
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
        showText: _showTextOcr,
        camera: _cameraOcr ?? FlutterMobileVision.CAMERA_BACK,
        preview: _previewOcr ?? FlutterMobileVision.PREVIEW,
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

  ///
  /// Face Screen
  ///
  Widget _getFaceScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewFace = null;
          setState(() => _cameraFace = value);
        },
        value: _cameraFace,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraFace ?? 0),
        onChanged: (value) {
          setState(() => _previewFace = value);
        },
        value: _previewFace,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusFace,
      onChanged: (value) => setState(() => _autoFocusFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchFace,
      onChanged: (value) => setState(() => _torchFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextFace,
      onChanged: (value) => setState(() => _showTextFace = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _detect,
          child: Text('DETECT!',style: TextStyle(color: Colors.white),),
           style: ElevatedButton.styleFrom(
    backgroundColor:  Color.fromARGB(255, 108, 149, 245) // Set button color to blue
  ),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _faces
            .map(
              (face) => FaceDetail(face),
            )
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// Face Method
  ///
  Future<Null> _detect() async {
    List<Face> faces = [];

    try {
      faces = await FlutterMobileVision.face(
        flash: _torchFace,
        autoFocus: _autoFocusFace,
        multiple: _multipleFace,
        showText: _showTextFace,
        camera: _cameraFace ?? FlutterMobileVision.CAMERA_FRONT,
        preview: _previewFace ?? FlutterMobileVision.PREVIEW,
      );
    } on Exception {
      faces.add(Face(-1));
    }

    if (!mounted) return;

    setState(() => _faces = faces);
  }

  ///
  /// Speak method
Future<void> _speak(String text, String language) async {
  await flutterTts.setLanguage(language);
  await flutterTts.setPitch(1);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.speak(text);
}
}

class BarcodeWidget extends StatelessWidget {
  final Barcode barcode;

  BarcodeWidget(this.barcode);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.star),
      title: Text(barcode.displayValue),
      subtitle: Text('${barcode.format} [${barcode.valueFormat}]'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeDetail(barcode),
          ),
        );
      },
    );
  }
}

class OcrTextWidget extends StatelessWidget {
  final OcrText text;

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

class FaceWidget extends StatelessWidget {
  final Face face;

  FaceWidget(this.face);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.face),
      title: Text(face.id.toString()),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceDetail(face),
        ),
      ),
    );
  }
}

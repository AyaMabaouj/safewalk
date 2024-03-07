import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:safewalk/utils/detect_screen.dart';

import 'models.dart';

class objectDetect extends StatefulWidget {
  const objectDetect({Key? key}) : super(key: key);

  @override
  State<objectDetect> createState() => _objectDetectState();
}

class _objectDetectState extends State<objectDetect> {
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  loadModel() async {
    final res = await Tflite.loadModel(
      model: "assets/mobilenet_v1.tflite",
      labels: "assets/mobilenet_v1.txt",
    );
    print("$res");
  }

  onSelect() {
    loadModel();
    final route = MaterialPageRoute(builder: (context) {
      return DetectScreen(cameras: cameras, model: mobilenet);
    });
    Navigator.of(context).push(route);
  }

  setupCameras() async {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SafeHome'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text(mobilenet),
          onPressed: onSelect,
        ),
      ),
    );
  }
}

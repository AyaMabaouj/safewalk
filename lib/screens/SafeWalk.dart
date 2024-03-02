import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/utils/bndbox.dart';
import 'package:safewalk/utils/camera.dart';

void main() {
  runApp(SafeWalk());
}

class SafeWalk extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('SafeWalk'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeWalkBody(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SafeWalkBody extends StatefulWidget {
  @override
  _SafeWalkBodyState createState() => _SafeWalkBodyState();
}

class _SafeWalkBodyState extends State<SafeWalkBody> {
  late List<CameraDescription> cameras;
  String model = 'ssd'; // Default model (you can change this based on user selection)
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Load the initial model
        loadModel(model);
      } else {
        // Handle scenario where no cameras are available
      }
    } on CameraException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.description}');
      // Handle camera initialization error
    } finally {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  Future<void> loadModel(String selectedOption) async {
    try {
        // Load the SSD MobileNet model for person or car detection
        await Tflite.loadModel(
          model: "assets/ssd_mobilenet.tflite",
          labels: "assets/ssd_mobilenet.txt",
        );
    } catch (e) {
      print('Error loading model: $e');
      // Handle model loading error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isCameraInitialized ? _buildCameraView() : _buildLoadingIndicator(),
    );
  }

  Widget _buildCameraView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 400,
            height: 500,
            alignment: Alignment.center,
            child: Stack(
              children: [
                _buildCameraWidget(),
                if (_recognitions != null && _recognitions!.isNotEmpty)
                  BndBox(
                    _recognitions!,
                    _imageHeight,
                    _imageWidth,
                    500,
                    400,
                    model,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraWidget() {
    return Camera(cameras, model, setRecognitions);
  }

  Widget _buildLoadingIndicator() {
    return CircularProgressIndicator();
  }

  @override
  void dispose() {
    // Unload the model when the widget is disposed
    Tflite.close();
    super.dispose();
  }
}

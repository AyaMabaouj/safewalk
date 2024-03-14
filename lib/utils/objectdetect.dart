import 'dart:async';
import 'dart:collection';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ObjectDetection extends StatefulWidget {
  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  List<dynamic> _currentRecognition = [];
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  late FlutterTts tts;
  late int lastSpeakTime;
  Queue<CameraImage> _imageQueue = Queue();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCameraControllerFuture = _initializeCamera();
    _loadModel();
    tts = FlutterTts();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
      );
    } catch (e) {
      print('Error loading model: $e');
      // Show error to user
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0], // Use the first available camera
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
      // Show error to user
    }
  }

  void _startProcessing() {
    if (!_isProcessing && _imageQueue.isNotEmpty) {
      _isProcessing = true;
      CameraImage img = _imageQueue.removeFirst();
      _runModelOnFrame(img).then((_) {
        _isProcessing = false;
        _startProcessing();
      });
    }
  }

  Future<void> _runModelOnFrame(CameraImage img) async {
    try {
      List? recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) => plane.bytes).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        numResults: 3,
      );
      setState(() {
        _currentRecognition = recognitions ?? [];
      });
      _speakRecognitions(recognitions);
    } catch (e) {
      print('Error running model on frame: $e');
    }
  }

  Future<void> speakText(String text) async {
    await tts.speak(text);
  }

  void _speakRecognitions(List<dynamic>? recognitions) {
    if (recognitions != null) {
      recognitions.forEach((re) async {
        String label = "${re["detectedClass"]}";
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - lastSpeakTime > 1000) {
          speakText(label);
          lastSpeakTime = currentTime;
        }
      });
    }
  }

  void _startStreaming() {
    if (_cameraController.value.isInitialized) {
      _cameraController.startImageStream((CameraImage img) {
        _imageQueue.add(img);
        _startProcessing();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: FutureBuilder<void>(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_cameraController.value.isInitialized) {
              _startStreaming(); // Start streaming after camera is initialized
              return _buildBody();
            } else {
              return Center(
                child: Text('Failed to initialize camera'),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildCameraPreview(),
        _buildRecognitionOverlay(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: CameraPreview(_cameraController),
    );
  }

  Widget _buildRecognitionOverlay() {
    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _currentRecognition.isNotEmpty
            ? ListView.builder(
                itemCount: _currentRecognition.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _currentRecognition[index]['label'] ?? 'Unknown',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Confidence: ${(_currentRecognition[index]['confidence'] * 100).toStringAsFixed(2)}%',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No objects detected',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    tts.stop();
    super.dispose();
  }
}

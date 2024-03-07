import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class RealTimeObjectDetection extends StatefulWidget {
  @override
  _RealTimeObjectDetectionState createState() => _RealTimeObjectDetectionState();
}

class _RealTimeObjectDetectionState extends State<RealTimeObjectDetection> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isModelLoaded = false;
  List<dynamic> _recognitions = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      print('No cameras available');
      return;
    }
    _cameraController = CameraController(
      _cameras[0], // You might need to adjust the index
      ResolutionPreset.medium,
    );
    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {});
        _startStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
      );
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _startStream() async {
    try {
      await _cameraController.startImageStream((CameraImage img) {
        _processCameraImage(img);
      });
    } catch (e) {
      print('Error starting camera stream: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Object Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          _isModelLoaded ? _buildResults() : _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildResults() {
    return Stack(
      children: _recognitions.map((recognition) {
        return Positioned(
          left: recognition['rect']['x'].toDouble(),
          top: recognition['rect']['y'].toDouble(),
          width: recognition['rect']['w'].toDouble(),
          height: recognition['rect']['h'].toDouble(),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            child: Text(
              '${recognition['detectedClass']} ${(recognition['confidence'] * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                background: Paint()..color = Colors.red,
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _processCameraImage(CameraImage img) async {
    if (_isModelLoaded) {
      try {
        List<dynamic>? recognitions = await Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "MobileNet_v1",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 127.5,
          imageStd: 127.5,
          numResultsPerClass: 1,
          threshold: 0.4,
        );
        if (recognitions != null) {
          List<dynamic> filteredRecognitions = _filterRecognitions(recognitions);
          setState(() {
            _recognitions = filteredRecognitions;
          });
        }
      } catch (e) {
        print('Error detecting objects: $e');
      }
    }
  }

  List<dynamic> _filterRecognitions(List<dynamic> recognitions) {
    List<dynamic> filteredRecognitions = recognitions.where((recognition) {
      return recognition['confidence'] > 0.5; // Adjust threshold as needed
    }).toList();
    return filteredRecognitions;
  }
}

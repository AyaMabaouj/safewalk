import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'models.dart';

typedef Callback = void Function(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  const Camera(this.cameras, this.model, this.setRecognitions, {Key? key})
      : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;
  late FlutterTts flutterTts;
  late int lastSpeakTime;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isEmpty) {
      log('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = DateTime.now().millisecondsSinceEpoch;

            if (widget.model == mobilenet) {
              Tflite.runModelOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((List<dynamic>? recognitions) {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                log("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);
                speakDetectedLabels(recognitions); 

                isDetecting = false;
              });
            } else if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((List<dynamic>? recognitions) {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                log("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);
                speakDetectedLabels(recognitions); 

                isDetecting = false;
              });
            } else {
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((List<dynamic>? recognitions) {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                log("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);
                speakDetectedLabels(recognitions); 

                isDetecting = false;
              });
            }
          }
        });
      });

      flutterTts = FlutterTts();
      lastSpeakTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void speakDetectedLabels(List<dynamic>? recognitions) {
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

  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}

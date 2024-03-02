import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';
import 'models.dart';

class BndBox extends StatefulWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String model;

  BndBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model, {Key? key}) : super(key: key);

  @override
  _BndBoxState createState() => _BndBoxState();
}

class _BndBoxState extends State<BndBox> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakDetectedLabels();
  }

  Future<void> speakDetectedLabels() async {
    for (var result in widget.results) {
      String label = "${result["label"]} ${(result["confidence"] * 100).toStringAsFixed(0)}%";
      await flutterTts.speak(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.model == mobilenet
          ? renderStrings()
          : widget.model == posenet ? renderKeypoints() : renderBoxes(),
    );
  }

  List<Widget> renderBoxes() {
    return widget.results.map((re) {
      var x0 = re["rect"]["x"];
      var w0 = re["rect"]["w"];
      var y0 = re["rect"]["y"];
      var h0 = re["rect"]["h"];
      dynamic scaleW, scaleH, x, y, w, h;

      if (widget.screenH / widget.screenW > widget.previewH / widget.previewW) {
        scaleW = widget.screenH / widget.previewH * widget.previewW;
        scaleH = widget.screenH;
        var difW = (scaleW - widget.screenW) / scaleW;
        x = (x0 - difW / 2) * scaleW;
        w = w0 * scaleW;
        if (x0 < difW / 2) w -= (difW / 2 - x0) * scaleW;
        y = y0 * scaleH;
        h = h0 * scaleH;
      } else {
        scaleH = widget.screenW / widget.previewW * widget.previewH;
        scaleW = widget.screenW;
        var difH = (scaleH - widget.screenH) / scaleH;
        x = x0 * scaleW;
        w = w0 * scaleW;
        y = (y0 - difH / 2) * scaleH;
        h = h0 * scaleH;
        if (y0 < difH / 2) h -= (difH / 2 - y0) * scaleH;
      }

      return Positioned(
        left: math.max(0, x),
        top: math.max(0, y),
        width: w,
        height: h,
        child: Container(
          padding: const EdgeInsets.only(top: 5.0, left: 5.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(247, 17, 17, 1),
              width: 3.0,
            ),
          ),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Color.fromRGBO(247, 17, 17, 1),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> renderStrings() {
    double offset = -10;
    return widget.results.map((re) {
      offset = offset + 14;
      return Positioned(
        left: 10,
        top: offset,
        width: widget.screenW,
        height: widget.screenH,
        child: Text(
          "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
          style: const TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> renderKeypoints() {
    var lists = <Widget>[];
    widget.results.forEach((re) {
      var list = re["keypoints"].values.map<Widget>((k) {
        var x0 = k["x"];
        var y0 = k["y"];
        double scaleW, scaleH, x, y;

        if (widget.screenH / widget.screenW > widget.previewH / widget.previewW) {
          scaleW = widget.screenH / widget.previewH * widget.previewW;
          scaleH = widget.screenH;
          var difW = (scaleW - widget.screenW) / scaleW;
          x = (x0 - difW / 2) * scaleW;
          y = y0 * scaleH;
        } else {
          scaleH = widget.screenW / widget.previewW * widget.previewH;
          scaleW = widget.screenW;
          var difH = (scaleH - widget.screenH) / scaleH;
          x = x0 * scaleW;
          y = (y0 - difH / 2) * scaleH;
        }
        return Positioned(
          left: x - 6,
          top: y - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: const TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    });

    return lists;
  }
}
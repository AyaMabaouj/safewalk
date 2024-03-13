import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class BarcodeWidget extends StatelessWidget {
  final Barcode barcode;

  BarcodeWidget(this.barcode);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.star),
      title: Text(barcode.displayValue),
      subtitle: Text('${barcode.format} [${barcode.valueFormat}]'),
     
    );
  }
}

class BarcodeScreen extends StatefulWidget {
  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  late int _cameraBarcode;
  late Size _previewBarcode;
  late int _onlyFormatBarcode;
  bool _autoFocusBarcode = false;
  bool _torchBarcode = false;
  bool _multipleBarcode = false;
  bool _waitTapBarcode = false;
  bool _showTextBarcode = false;
  List<Barcode> _barcodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBarcodeScreen(context),
    );
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

    // Other widget building code here...

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
  Future<void> _scan() async {
    List<Barcode> barcodes = [];
    Size _scanpreviewOcr = _previewBarcode ?? FlutterMobileVision.PREVIEW;

    try {
      barcodes = await FlutterMobileVision.scan(
        flash: _torchBarcode,
        autoFocus: _autoFocusBarcode,
        formats: _onlyFormatBarcode ?? Barcode.ALL_FORMATS,
        multiple: _multipleBarcode,
        waitTap: _waitTapBarcode,
        forceCloseCameraOnTap: true,
        imagePath: '', //'path/to/file.jpg'
        showText: _showTextBarcode,
        preview: _previewBarcode ?? FlutterMobileVision.PREVIEW,
        scanArea: Size(_scanpreviewOcr.width - 20, _scanpreviewOcr.height - 20),
        camera: _cameraBarcode ?? FlutterMobileVision.CAMERA_BACK,
        fps: 15.0,
      );
    } on Exception catch (e) {
      print('Error scanning barcodes: $e');
      barcodes.add(Barcode('Failed to get barcode.'));
    }

    if (!mounted) return;

    setState(() => _barcodes = barcodes);
  }
}

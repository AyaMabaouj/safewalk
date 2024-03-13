import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CodeScanner extends StatefulWidget {
  const CodeScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> with WidgetsBindingObserver {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Brightness currentBrightness;
  bool isFlashOn = false;
FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    currentBrightness = WidgetsBinding.instance!.window.platformBrightness;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Ajoutez l'observateur de la liaison des widgets
    WidgetsBinding.instance!.addObserver(this);

    // Vérifiez la luminosité de l'appareil et activez/désactivez le flash en conséquence
    _toggleFlashOnDarkMode(currentBrightness);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      final brightness = Theme.of(context).brightness;
      if (brightness != currentBrightness) {
        currentBrightness = brightness;
        _toggleFlashOnDarkMode(currentBrightness);
      }
    });
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      currentBrightness = WidgetsBinding.instance!.window.platformBrightness;
      _toggleFlashOnDarkMode(currentBrightness);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    // Retirez l'observateur de la liaison des widgets
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void _toggleFlashOnDarkMode(Brightness brightness) async {
    if (controller != null) {
      bool shouldTurnOnFlash = brightness == Brightness.dark;
      if (shouldTurnOnFlash != isFlashOn) {
        isFlashOn = shouldTurnOnFlash;
        await controller!.toggleFlash();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}') // your result is goes here
                  else
                    const Text('Scan a code'),
                    
                  Padding(
  padding: EdgeInsets.symmetric(horizontal: 20.0), // Espace horizontal de chaque côté de l'écran
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ElevatedButton.icon(
        onPressed: () async {
          await controller?.pauseCamera();
          flutterTts.speak("on pause");
        },
        icon: Icon(Icons.pause),
        label: Text("Pause"),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: Colors.blue, 
        ),
      ),
      SizedBox(width: 20),
      ElevatedButton.icon(
        onPressed: () async {
          await controller?.resumeCamera();
          flutterTts.speak("on resume");
        },
        icon: Icon(Icons.play_arrow),
        label: Text("Resume"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, 
          foregroundColor: Colors.white, 
        ),
      ),
    ],
  ),
),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      cameraFacing: CameraFacing.back, // Utilise toujours la caméra arrière
    );
  }

void _onQRViewCreated(QRViewController controller) {
  setState(() {
    this.controller = controller;
  });
  controller.scannedDataStream.listen((scanData) {
    setState(() {
      result = scanData;
    });

    if (result != null && result!.code != null) {
      print("Result"); // if you want to do any action with qr result then do code is here
      print(result!.code);
  flutterTts.speak(result!.code!);
}

  });
}


  void _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}

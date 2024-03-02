import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:safewalk/screens/MySplashPage.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 108, 149, 245)),
        useMaterial3: true,

      ),
      debugShowCheckedModeBanner: false,

      home: const MySplashPage(),
    );
  }
}


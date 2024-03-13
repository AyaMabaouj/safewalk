import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safewalk/screens/homepage.dart';

class AuthentificationFingerPrint extends StatefulWidget {
  
  @override
  _AuthentificationFingerPrintState createState() =>
      _AuthentificationFingerPrintState();
}

class _AuthentificationFingerPrintState
    extends State<AuthentificationFingerPrint> {
  @override
  void initState() {
    super.initState();
    _authenticate(context);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF211163), // Dark blue color
    body: Padding(
      padding: const EdgeInsets.all(20.0), // Added padding for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
        children: <Widget>[
                    SizedBox(height: 40),

          Center(
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 60, // Changed font size to 30
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.fingerprint, // Fingerprint icon
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 10), // Added SizedBox for spacing
                Text(
                  'Fingerprint Auth', // Text under the fingerprint icon
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                SizedBox(height: 20), // Added SizedBox for spacing
                Text(
                  'Authenticate using your fingerprint\ninstead of your password',
                  textAlign: TextAlign.center, // Aligning text to center
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _authenticate(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool isAvailable = await auth.canCheckBiometrics;
      if (isAvailable) {
        List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          bool authenticated = await auth.authenticate(
            localizedReason: 'Please authenticate to continue',
          );
          if (authenticated) {
            // User is successfully authenticated
            // Here, you can navigate to another page or perform any other necessary action
            print('Authentication Successful!');
            // Navigate to the desired page after authentication
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );

            // Speech Announcement
            final MethodChannel _channel = MethodChannel('flutter_tts');
            await _channel.invokeMethod(
                'speak',
                'Welcome to the home page. Click on the voice icon at the bottom to manage your voice command.');
          } else {
            // Authentication failed
            print('Authentication Failed.');
          }
        } else {
          // No biometrics available on this device
          print('No biometrics available on this device.');
        }
      } else {
        // Biometric authentication is not available on this device
        print('Biometric authentication is not available on this device.');
      }
    } on PlatformException catch (e) {
      print("Error during biometric authentication: $e");
      // Handle authentication errors
    }
  }
}

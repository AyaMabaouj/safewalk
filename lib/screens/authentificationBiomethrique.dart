import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safewalk/screens/authentificationFaciale.dart';
class AuthentificationBiometrique extends StatefulWidget {
  @override
  _AuthentificationBiometriqueState createState() => _AuthentificationBiometriqueState();
}

class _AuthentificationBiometriqueState extends State<AuthentificationBiometrique> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF211163),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          AuthentificationFingerPrint(
  key: UniqueKey(), // Provide a unique key
  onNext: () {
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  },
),
          AuthentificationFaciale(
            onBack: () {
              _pageController.animateToPage(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
        ],
      ),
    );
  }
}
class AuthentificationFingerPrint extends StatefulWidget {
  final VoidCallback onNext;

  const AuthentificationFingerPrint({Key? key, required this.onNext}) : super(key: key);

  @override
  _AuthentificationFingerPrintState createState() => _AuthentificationFingerPrintState();
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
      backgroundColor: Color(0xFF211163),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Center(
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.fingerprint,
                    size: 100,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fingerprint Auth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Authenticate using your fingerprint\ninstead of your password',
                    textAlign: TextAlign.center,
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
            print('Authentication Successful!');
            widget.onNext(); // Call the onNext callback
          } else {
            print('Authentication Failed.');
          }
        } else {
          print('No biometrics available on this device.');
        }
      } else {
        print('Biometric authentication is not available on this device.');
      }
    } on PlatformException catch (e) {
      print("Error during biometric authentication: $e");
    }
  }
}

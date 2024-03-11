import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:safewalk/screens/authentificationFingerPrint';


class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Durée de l'animation
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Ajouter une écoute pour savoir quand l'animation est terminée
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // L'animation est terminée, naviguer vers la page d'accueil
        navigateToHomePage();
      }
    });

    // Démarrer l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Méthode pour naviguer vers la page d'accueil
  void navigateToHomePage() {
      speakText("Welcome! Please use your finger to authenticate successfully.");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthentificationFingerPrint()),
    );
    
  }
void speakText(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Changer la couleur de l'arrière-plan au besoin
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            "assets/logo.png",
            width: screenWidth * 0.6, // Ajuster la taille au besoin
            height: screenHeight * 0.6, // Ajuster la taille au besoin
          ),
        ),
      ),
    );
  }
}

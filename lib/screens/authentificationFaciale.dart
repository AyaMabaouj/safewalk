import 'package:flutter/material.dart';
import 'package:safewalk/api/local_auth_api.dart';
import 'package:safewalk/screens/homepage.dart';

class AuthentificationFaciale extends StatelessWidget {
  final Function onBack;

  AuthentificationFaciale({required this.onBack});

  @override
  Widget build(BuildContext context) {
    authenticate(context); // Déclencher l'authentification dès que le widget est construit

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildHeader(),
            ],
          ),
        ),
      ),
    );
  }

  void authenticate(BuildContext context) async {
    final isAuthenticated = await LocalAuthApi.authenticate();

    if (isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Gérer les cas où l'authentification échoue
      // Vous pouvez afficher un message d'erreur ou rediriger vers une autre page
    }
  }

  Widget buildHeader() => Column(
    children: [
      Text(
        'Authentification faciale',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 16),
      ShaderMask(
        shaderCallback: (bounds) {
          final colors = [Colors.blueAccent, Colors.pink];
          return RadialGradient(colors: colors).createShader(bounds);
        },
        child: Icon(Icons.face_retouching_natural,
            size: 100, color: Colors.white),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:safewalk/screens/SafeWalk.dart';
import 'package:safewalk/screens/textRecogonition.dart';
import 'package:safewalk/utils/voiceCommande.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HomePage',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.settings,color: Colors.white,),
            onPressed: () {
              // Mettez ici le code pour la gestion du clic sur l'icône des paramètres
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Background color under Welcome message
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/welcome.gif',
                        width: 500,
                        height: 200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espacement entre le cercle et les cartes
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SafeWalk()), // Navigate to SafeWalk class
                          );                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 100,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Détection d\'objets',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TextRecognitionApp()), 
                          );                          },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.text_fields,
                                size: 100,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Détection de texte',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VoiceCommandApp()), 
                          );  
                      },
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                child: CircleAvatar(
                                  radius: 70, // Réduire la taille du cercle
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.mic,
                                    color:Colors.blue,
                                    size: 100, // Réduire la taille de l'icône
                                  ),
                                ),
                              ),
                              Text(
                                'Commande\nvocale',
                                style: TextStyle(
                                  fontSize: 20, // Réduire la taille de la police
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

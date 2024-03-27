import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PlacesListScreen extends StatefulWidget {
  final List<dynamic> places;

  const PlacesListScreen({Key? key, required this.places}) : super(key: key);

  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 0;
  bool _stopSpeaking = false;
  String _currentLocaleId = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    langdetect.initLangDetect();
    // Appel de la fonction pour annoncer les lieux une fois que la page est initialisée
    _announcePlaces();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
    _stopSpeaking = true;
  }

  @override
  void deactivate() {
    flutterTts.stop();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of places'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.places.isEmpty
                ? Center(
              child: Text('No places found.'),
            )
                : ListView.builder(
              itemCount: widget.places.length,
              itemBuilder: (context, index) {
                var place = widget.places[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      place['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (place['rating'] != null) // Vérifiez si 'rating' est non null
                          Row(
                            children: <Widget>[
                              Text(_calculateRating(place['rating'].toDouble()),      
                              style: TextStyle(color: Colors.amber),),
                               // Utilisez _calculateRating pour obtenir le nombre d'étoiles
                              SizedBox(width: 5),
                              Text(' (${place['user_ratings_total'] ?? 0} ratings)'),
                            ],
                          ),
                        Text(place['vicinity']),
                      ],
                    ),
                    leading: place['photos'] != null
                        ? Image.network(
                      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=${place['photos'][0]['photo_reference']}&key=AIzaSyCrDYCXAVQZeXxbZx84iRVe5SMmBpm5sy8",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.image_not_supported),
                    ),
                    onTap: () {
                      // Handle tap for accessibility
                      _announcePlace(context, place['name']);
                      _startNavigation(place['geometry']['location']['lat'], place['geometry']['location']['lng']);
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10), // Add some spacing between the list and the icon
          GestureDetector(
            onTap: _listen,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12.0),
              child: Icon(
                _isListening ? Icons.mic_none : Icons.mic,
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fonction pour calculer le nombre d'étoiles à partir de la note moyenne

String _calculateRating(double rating) {
  if (rating == null) {
    return 'N/A';
  }
  int numberOfStars = rating.round();
  String stars = '';
  for (int i = 0; i < numberOfStars; i++) {
    stars += '★';
  }
  return stars;
}

  Future<void> _announcePlaces() async {
    // Lire le nom de chaque lieu dans la liste
    for (var i = 0; i < widget.places.length; i++) {
      if (_stopSpeaking) break; // Vérifier si la lecture doit être interrompue
      await _speakPlace(widget.places[i]['name']);
            await _speakPlace(widget.places[i]['vicinity']);
    }
  }

  Future<void> _speakPlace(String placeName) async {
    // Utilisation de flutter_langdetect pour détecter la langue du texte
    String language = await langdetect.detect(placeName);

    // Liste des langues autorisées
    List<String> allowedLanguages = ['ar', 'en', 'fr'];

    // Si la langue détectée n'est pas dans les langues autorisées, utiliser l'anglais par défaut
    if (!allowedLanguages.contains(language)) {
      language = 'fr'; // Langue par défaut
    }

    // Ici, vous pouvez utiliser language pour configurer FlutterTts avec la langue détectée
    await flutterTts.setLanguage(language);

    // Lire le nom du lieu
    await flutterTts.speak(placeName);
    await Future.delayed(Duration(seconds: 5)); 
  }

  void _announcePlace(BuildContext context, String placeName) async {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Selected: $placeName'),
      ),
    );

    // Interrompre la lecture vocale
    _stopSpeaking = true;
  }

  void _startNavigation(double destinationLat, double destinationLng) async {
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String url = 'google.navigation:q=$destinationLat,$destinationLng&mode=d';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching navigation.')));
    }
  }

void _listen() async {
  if (!_isListening) {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
      onError: (errorNotification) {
        print('Speech recognition error: $errorNotification');
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      await _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            String recognizedText = result.recognizedWords.toLowerCase();
            bool placeFound = false;
            for (var place in widget.places) {
              if (recognizedText.contains(place['name'].toLowerCase())) {
                placeFound = true;
                _announcePlace(context, place['name']);
                _startNavigation(place['geometry']['location']['lat'], place['geometry']['location']['lng']);
                break;
              }
            }
            if (!placeFound) {
              print('Lieu non trouvé.');
            }
          } else {
            print('Type de lieu non valide.');
          }
          setState(() {
            _isListening = false;
          });
        },
      );
    } else {
      print('Speech recognition not available.');
    }
  } else {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }
}

}



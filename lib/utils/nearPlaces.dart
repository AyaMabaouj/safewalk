import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:safewalk/utils/placesListScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

class NearbyPlacesScreen extends StatefulWidget {
  @override
  _NearbyPlacesScreenState createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  late Position _currentPosition = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  Map<String, String> placeTypes = {
    'bakery': '🥖   Bakery',
    'bank': '🏦   Bank',
    'cafe': '☕   Cafe',
    'mosque': '🕌   Mosque',
    'doctor': '🩺   Doctor',
    'bus_station': '🚌   Bus Station',
    'hospital': '🏥   Hospital',
    'restaurant': '🍽️   Restaurant',
    'supermarket': '🛒   Supermarket',
    'police': '🚓   Police',
    'pharmacy': '💊   Pharmacy',
    'post_office': '📮   Post Office',
    'dentist': '🦷   Dentist',
    'primary_school': '🏫   Primary School',
    'university': '🎓   University',
    'school': '🏫   School',
    'secondary_school': '🏫   Secondary School',
    'beauty_salon': '💇   Beauty Salon',
    'taxi_stand': '🚖   Taxi Stand',
    'light_rail_station': '🚈   Light Rail Station',
    'train_station': '🚉   Train Station',
    'store': '🏬   Store',
    'subway_station': '🚇   Subway Station',
    'rv_park': '🚐   RV Park',
    'shoe_store': '👠   Shoe Store',
    'shopping_mall': '🏬   Shopping Mall',
    'book_store': '📚   Book Store',
    'cemetery': '⚰️   Cemetery',
    'church': '⛪   Church',
    'clothing_store': '👕   Clothing Store',
    'convenience_store': '🏪   Convenience Store',
    'courthouse': '🏛️   Courthouse',
    'department_store': '🛍️   Department Store',
    'electrician': '⚡   Electrician',
    'electronics_store': '🔌   Electronics Store',
    'fire_station': '🚒   Fire Station',
    'florist': '💐   Florist',
    'funeral_home': '⚰️   Funeral Home',
    'furniture_store': '🛋️   Furniture Store',
    'gas_station': '⛽   Gas Station',
    'hair_care': '💇   Hair Care',
    'hardware_store': '🔧   Hardware Store',
    'home_goods_store': '🏠   Home Goods Store',
    'insurance_agency': '🏛️   Insurance Agency',
    'jewelry_store': '💍   Jewelry Store',
    'laundry': '🧺   Laundry',
    'lawyer': '⚖️   Lawyer',
    'library': '📚   Library',
    'local_government_office': '🏛️   Local Government Office',
    'locksmith': '🔒   Locksmith',
    'lodging': '🏨   Lodging',
    'meal_delivery': '🍽️   Meal Delivery',
    'meal_takeaway': '🥡   Meal Takeaway',
    'movie_rental': '🎬   Movie Rental',
    'movie_theater': '🎥   Movie Theater',
    'moving_company': '🚚   Moving Company',
    'museum': '🏛️   Museum',
    'night_club': '🎶   Night Club',
    'painter': '🎨   Painter',
    'park': '🌳   Park',
    'pet_store': '🐾   Pet Store',
    'physiotherapist': '⚕️   Physiotherapist',
    'plumber': '🚰   Plumber',
    'real_estate_agency': '🏛️   Real Estate Agency',
    'spa': '💆   Spa',
    'stadium': '🏟️   Stadium',
    'synagogue': '🕍   Synagogue',
    'tourist_attraction': '🏞️   Tourist Attraction',
    'travel_agency': '✈️   Travel Agency',
    'veterinary_care': '🐾   Veterinary Care',
    'zoo': '🦁   Zoo',
  };

  List<dynamic> places = [];
  bool isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _speech = stt.SpeechToText();
  }


  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchNearbyPlaces(String type) async {
    setState(() {
      isLoading = true;
    });

    if (_currentPosition != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
              "?location=${_currentPosition.latitude},${_currentPosition.longitude}" +
              "&radius=5000" +
              "&types=$type" +
              "&key=AIzaSyCrDYCXAVQZeXxbZx84iRVe5SMmBpm5sy8"; // Replace with your API key

      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          setState(() {
            places = jsonDecode(response.body)['results'];
            isLoading = false;
          });
          _navigateToPlacesListScreen();
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to fetch places');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching places: $e');
      }
    }
  }

  void _navigateToPlacesListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlacesListScreen(places: places)),
    );
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
            print('Recognized Type: $recognizedText');
            if (placeTypes.containsKey(recognizedText)) {
              fetchNearbyPlaces(recognizedText);
            } else {
              print('Type de lieu non valide.');
            }
            setState(() {
              _isListening = false;
            });
          }
        },
        localeId: 'en_US', // Force la langue de reconnaissance vocale à l'anglais
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Places'),
      ),
      body: _currentPosition.latitude == 0.0 && _currentPosition.longitude == 0.0
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: placeTypes.length,
                    itemBuilder: (context, index) {
                      String key = placeTypes.keys.elementAt(index);
                      return Card(
                        color: Colors.white, // Set background color to white
                        child: ListTile(
                          title: Text(
                            placeTypes[key]!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () => fetchNearbyPlaces(key),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
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
                SizedBox(height: 20), // Add additional spacing if needed
              ],
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NearbyPlacesScreen(),
  ));
}

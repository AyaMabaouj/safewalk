import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MapExample extends StatefulWidget {
  const MapExample({Key? key}) : super(key: key);

  @override
  State<MapExample> createState() => _MapExampleState();
}

class _MapExampleState extends State<MapExample> {
  late LatLng myPosition = LatLng(0, 0);
  late LatLng destinationPosition = LatLng(0, 0);
  late String address = '';
  late TextEditingController searchController = TextEditingController();
  late StreamSubscription<Position> _positionStreamSubscription;
  final Completer<GoogleMapController> _controller = Completer();
  final stt.SpeechToText _speech = stt.SpeechToText();
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initSpeechRecognizer();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      myPosition = LatLng(position.latitude, position.longitude);


      // Move camera to the current position
      _moveCamera(myPosition);
            // Add marker for the current position

      _setMarker(myPosition, 'My Location', Colors.blue);

      // Listen for position updates
      _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
        myPosition = LatLng(position.latitude, position.longitude);
        _setMarker(myPosition, 'My Location', Colors.blue);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _setMarker(LatLng position, String title, Color color) {
    _markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(color == Colors.blue ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
      ),
    );
  }
  

  void _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _initSpeechRecognizer() {
    _speech.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            address = result.recognizedWords;
            searchController.text = address;
          });
          _searchDestination(address);
        }
      },
    );
  }

void _searchDestination(String destination) async {
  try {
    if (destination.isNotEmpty) {
      List<Location> locations = await locationFromAddress(destination);
      if (locations.isNotEmpty) {
        destinationPosition = LatLng(locations[0].latitude, locations[0].longitude);

        // Ajouter la route entre la position actuelle et la destination
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: [myPosition, destinationPosition],
        ));

        // Ajouter le marqueur de la destination
        _setMarker(destinationPosition, 'Destination', Colors.red);
        _moveCamera(destinationPosition);
      } else {
        Fluttertoast.showToast(msg: 'Destination non trouvée');
      }
    } else {
      Fluttertoast.showToast(msg: 'Veuillez fournir une destination');
    }
  } catch (e) {
    print("Erreur lors de la recherche de la destination: $e");
    Fluttertoast.showToast(msg: 'Erreur lors de la recherche de la destination');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: myPosition,
              zoom: 12,
            ),
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.blueAccent, size: 30,),
                      onPressed: () {
                        _searchDestination(searchController.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: MediaQuery.of(context).size.width / 2 - 90.0,
            child: SizedBox(
              width: 170.0,
              height: 170.0,
              child: FloatingActionButton(
                onPressed: _startListening,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.mic,
                  color: Colors.blue,
                  size: 120.0,
                ),
                elevation: 0,
                mini: false,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

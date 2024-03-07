import 'package:flutter/material.dart';
import 'package:safewalk/screens/SafeWalk.dart';
import 'package:safewalk/screens/settingPage.dart';
import 'package:safewalk/screens/textRecogonition.dart';
import 'package:safewalk/utils/map.dart';
import 'package:safewalk/utils/objectdetect.dart';
import 'package:safewalk/utils/voiceCommande.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  @override
  Widget build(BuildContext context) {
    List<String> options = [
      'Object Detection',
      'Text Recognition',
      'Navigation',
      'Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
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
                  height: 150,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return buildOptionCard(options[index]);
              },
            ),
          ),
          // Add the CardView for voice command
          buildOptionCard('CommandeVocale'),
        ],
      ),
    );
  }

  Widget buildOptionCard(String option) {
    IconData iconData;

    switch (option) {
      case 'Object Detection':
        iconData = Icons.search;
        break;
      case 'Text Recognition':
        iconData = Icons.text_fields;
        break;
      case 'Navigation':
        iconData = Icons.navigation;
        return InkWell(
          onTap: () {
          MapUtils.openMap();
          },
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 65,
                  color: Colors.blue,
                ),
                SizedBox(height: 16.0),
                Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      case 'Settings':
        iconData = Icons.settings;
        break;
      case 'CommandeVocale':
        iconData = Icons.mic;
        return Center(
          child: GestureDetector(
            onTap: () {
              if (!_isListening) {
                startListening();
              } else {
                stopListening();
              }
            },
            child: Card(
              shape: CircleBorder(),
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Icon(
                  Icons.mic,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
            ),
          ),
        );
      default:
        iconData = Icons.error;
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          if (option == 'Object Detection') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => objectDetect()),
            );
          } else if (option == 'Text Recognition') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TextRecognitionApp()),
            );
          } else if (option == 'Settings') {

             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 65,
              color: Colors.blue,
            ),
            SizedBox(height: 16.0),
            Text(
              option,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startListening() async {
    // Initialize SpeechToText instance if it's not already initialized
    if (!_speech.isAvailable) {
      await _speech.initialize();
    }

    // Check again if it's available after initialization
    if (_speech.isAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
            handleVoiceCommand(_text);
          },
        );
        setState(() {
          _isListening = true;
        });
      } catch (error) {
        print('Error: $error');
      }
    } else {
      print('Speech recognition is not available');
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void handleVoiceCommand(String command) {
    print('Command recognized: $command');
    if (command.toLowerCase() == 'open object détection') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SafeWalk()),
      );
    } else if (command.toLowerCase() == 'open text détection') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TextRecognitionApp()),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

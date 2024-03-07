import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:safewalk/utils/notificationSonore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

enum NotificationType { sound }

class _SettingsPageState extends State<SettingsPage> {
  bool _enableNotifications = false;
  NotificationType _notificationType = NotificationType.sound;
  List<String> _selectedObjects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                  if (_enableNotifications && _notificationType == NotificationType.sound) {
                    _showSoundNotification();
                  }
                });
              },
            ),
            Visibility(
              visible: _enableNotifications,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<NotificationType>(
                    title: Text('Sound Notification'),
                    value: NotificationType.sound,
                    groupValue: _notificationType,
                    onChanged: (NotificationType? value) {
                      setState(() {
                        _notificationType = value!;
                        if (_notificationType == NotificationType.sound && _enableNotifications) {
                          _showSoundNotification();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Object Types to Detect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 10),
                  Text('Person'),
                ],
              ),
              value: _selectedObjects.contains('Person'),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    _selectedObjects.add('Person');
                  } else {
                    _selectedObjects.remove('Person');
                  }
                  _loadModelBasedOnSelection();
                });
              },
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.directions_car),
                  SizedBox(width: 10),
                  Text('Car'),
                ],
              ),
              value: _selectedObjects.contains('Car'),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    _selectedObjects.add('Car');
                  } else {
                    _selectedObjects.remove('Car');
                  }
                  _loadModelBasedOnSelection();
                });
              },
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.pets),
                  SizedBox(width: 10),
                  Text('Animal'),
                ],
              ),
              value: _selectedObjects.contains('Animal'),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    _selectedObjects.add('Animal');
                  } else {
                    _selectedObjects.remove('Animal');
                  }
                  _loadModelBasedOnSelection();
                });
              },
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.traffic),
                  SizedBox(width: 10),
                  Text('Road Sign'),
                ],
              ),
              value: _selectedObjects.contains('Road Sign'),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    _selectedObjects.add('Road Sign');
                  } else {
                    _selectedObjects.remove('Road Sign');
                  }
                  _loadModelBasedOnSelection();
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logic to save settings here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings saved')),
                  );
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(150, 50)),
                ),
                child: Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoundNotification() async {
    await NotificationSonore.init();
    await NotificationSonore.showNotification(
      id: 0,
      title: 'Alert',
      body: 'Be cautious!',
    );
  }

  void _loadModelBasedOnSelection() {
    if (_selectedObjects.contains('Person') &&
        _selectedObjects.contains('Car') &&
        _selectedObjects.contains('Road Sign')) {
      _loadEnsembleModel();
    } else if (_selectedObjects.contains('Road Sign')) {
      _loadRoadSignModel();
    } else {
      _loadSSDModel();
    }
  }

  void _loadSSDModel() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
    // Additional logic after loading the SSD model
  }

  void _loadRoadSignModel() async {
    await Tflite.loadModel(
      model: "assets/detect.tflite",
      labels: "assets/detect_labelmap.txt",
    );
    // Additional logic after loading the road sign model
  }

  void _loadEnsembleModel() async {
    // Load the ensemble model
    // For example, you can load multiple models sequentially or in parallel
    await Tflite.loadModel(
      model: "assets/ensemble_model1.tflite",
      labels: "assets/ensemble_model1_labels.txt",
    );
    await Tflite.loadModel(
      model: "assets/ensemble_model2.tflite",
      labels: "assets/ensemble_model2_labels.txt",
    );
    // Additional logic after loading the ensemble model
  }
}

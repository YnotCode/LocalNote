import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = false; // State variable for notifications toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simplified gradient background for the entire screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD580), // Light sunset yellow
                  Color(0xFFFDA65A), // Sunset orange
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content of the screen
          Scaffold(
            backgroundColor: Colors.transparent, // Makes the body transparent
            appBar: AppBar(
              title: const Text(
                'Notification Settings',
                style: TextStyle(
                  color: Color.fromARGB(222, 57, 32, 15), // Similar to SettingsPage
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(
                color: Color.fromARGB(222, 57, 32, 15), // Back arrow color
              ),
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // Removes AppBar shadow
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(222, 57, 32, 15), // Matching color
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Color.fromARGB(222, 57, 32, 15), // Matching text color
                          fontSize: 20,
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeColor: Color.fromARGB(222, 57, 32, 15), // Matching switch color
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color.fromARGB(222, 57, 32, 15)), // Divider color consistency
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

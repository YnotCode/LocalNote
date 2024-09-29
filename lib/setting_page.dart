import 'package:flutter/material.dart';
import 'package:local_note_2/toggle_notifications.dart'; // Ensure this is the correct path for your toggle notifications page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _exclusiveFriends = false; // State variable for toggle

  void _logout() {
    // Implement logout logic here
    print('User logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background for the entire screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD580), // Light sunset yellow
                  Color(0xFFFDA65A), // Sunset orange
                  Color(0xFFF06D55), // Deep sunset peach
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content of the screen
          Scaffold(
            backgroundColor: Colors
                .transparent, // Makes the body of the Scaffold transparent
            appBar: AppBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white, // Set the back arrow color
              ),
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // Removes AppBar shadow
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Profile Picture
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150'), // Replace with your image URL
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'User Name',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // const Divider(color: Colors.white70), // Divider for profile section

                  // Toggle for exclusive friends
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Exclusive Friends Only',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20), // Adjust text color to fit the theme
                        textAlign: TextAlign.center, // Center the text
                      ),
                      Switch(
                        value: _exclusiveFriends,
                        onChanged: (value) {
                          setState(() {
                            _exclusiveFriends = value;
                          });
                        },
                        activeColor:
                            Colors.white, // Set the switch color when active
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      color: Colors.white70), // Divider for toggle section

                  // Additional Settings
                  ListTile(
                    leading:
                        const Icon(Icons.notifications, color: Colors.white),
                    title: const Text('Notifications',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                      color: Colors.white70), // Divider for notifications

                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.white),
                    title: const Text('Privacy',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Implement privacy settings logic
                    },
                  ),
                  const Divider(color: Colors.white70), // Divider for privacy

                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.white),
                    title: const Text('Help & Support',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Implement help & support logic
                    },
                  ),
                  const SizedBox(height: 20),
                  // Spacer to push the Log Out button to the bottom
                  const Spacer(),
                  const Divider(
                      color: Colors.white70), // Divider before log out

                  // Log out button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 188, 78, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

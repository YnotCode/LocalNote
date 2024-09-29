import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:local_note_2/toggle_notifications.dart'; // Ensure this is the correct path for your toggle notifications page
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

// Function to upload image to Firebase Storage (or any other storage service)
Future<String> _uploadImage(File imageFile, String phoneNumber) async {
  final storageRef = FirebaseStorage.instance.ref();
  // create a reference with phone and timestamp
  final imageRef = storageRef.child('images/$phoneNumber/${DateTime.now().millisecondsSinceEpoch}.jpg');
  await imageRef.putFile(imageFile);

  return await imageRef.getDownloadURL();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _exclusiveFriends = false;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  String username = '';
  String avatarUrl = '';

  _loadUserData () {
    SharedPreferences.getInstance().then((perfs)  {
      final ph = perfs.getString('phone-number');
      FirebaseFirestore.instance.collection('users').where('phoneNumber', isEqualTo: ph).get().then((user) {
        setState(() {

          username = user.docs[0].data()['name'];
          bool hasAvatar = user.docs[0].data()?.containsKey('avatar') ?? false;
          avatarUrl = hasAvatar ? user.docs[0].data()['avatar'] : '';
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to pick and crop the avatar image
  Future<void> _pickAndCropImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _avatarImage = File(croppedFile.path);
          });

          final perfs = await SharedPreferences.getInstance();
          final ph = perfs.getString('phone-number');
          final imageUrl = await _uploadImage(_avatarImage!, ph!);

          FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: ph)
            .get()
            .then((user) {
              user.docs[0].reference.update({'avatar': imageUrl});
            });
          
          _loadUserData();
          // Here you might want to upload the avatar to a server or save it locally
        }
      }
    } catch (e) {
      // Handle any errors here
      print('Error picking or cropping image: $e');
    }
  }

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
            decoration: const BoxDecoration(
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
                'Settings',
                style: TextStyle(
                  color: Color.fromARGB(222, 57, 32, 15),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Color.fromARGB(222, 57, 32, 15), // Set the back arrow color
              ),
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // Removes AppBar shadow
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickAndCropImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!) as ImageProvider
                              : avatarUrl == '' ? const NetworkImage('https://via.placeholder.com/150') : NetworkImage(avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(222, 57, 32, 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Toggle for exclusive friends
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Exclusive Friends Only',
                        style: TextStyle(
                          color: Color.fromARGB(222, 57, 32, 15),
                          fontSize: 20,
                        ),
                      ),
                      Switch(
                        value: _exclusiveFriends,
                        onChanged: (value) {
                          setState(() {
                            _exclusiveFriends = value;
                          });
                        },
                        activeColor: const Color.fromARGB(222, 57, 32, 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color.fromARGB(222, 57, 32, 15)),

                  // Additional Settings
                  ListTile(
                    leading: const Icon(Icons.notifications,
                        color: Color.fromARGB(222, 57, 32, 15)),
                    title: const Text('Notifications',
                        style: TextStyle(color: Color.fromARGB(222, 57, 32, 15))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color.fromARGB(222, 57, 32, 15)),

                  ListTile(
                    leading:
                        const Icon(Icons.lock, color: Color.fromARGB(222, 57, 32, 15)),
                    title: const Text('Privacy',
                        style: TextStyle(color: Color.fromARGB(222, 57, 32, 15))),
                    onTap: () {
                      // Implement privacy settings logic
                    },
                  ),
                  const Divider(color: Color.fromARGB(222, 57, 32, 15)),

                  ListTile(
                    leading:
                        const Icon(Icons.help, color: Color.fromARGB(222, 57, 32, 15)),
                    title: const Text('Help & Support',
                        style: TextStyle(color: Color.fromARGB(222, 57, 32, 15))),
                    onTap: () {
                      // Implement help & support logic
                    },
                  ),
                  const SizedBox(height: 20),

                  // Spacer to push the logout button to the bottom
                  Expanded(child: Container()),

                  // Log out button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 201, 121, 78),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _exclusiveFriends = false;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView in case content overflows
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickAndCropImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : const NetworkImage('https://via.placeholder.com/150'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'User Name',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Toggle for exclusive friends
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Exclusive Friends Only'),
                  Switch(
                    value: _exclusiveFriends,
                    onChanged: (value) {
                      setState(() {
                        _exclusiveFriends = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Additional Settings
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Implement notification settings navigation
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy'),
                onTap: () {
                  // Implement privacy settings logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Implement help & support logic
                },
              ),
              const SizedBox(height: 20),
              // Log out button
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
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
    );
  }
}

import 'dart:io'; // Needed for working with files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'package:photo_manager/photo_manager.dart'; // Import photo_manager for gallery access

class NoteUploadPage extends StatefulWidget {
  const NoteUploadPage({super.key});

  @override
  State<NoteUploadPage> createState() => _NoteUploadPageState();
}

class _NoteUploadPageState extends State<NoteUploadPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController(); // Controller for the note
  File? _image; // This will hold the selected image
  String _locationStatus = 'Location not available';

  @override
  void initState() {
    super.initState();
    // Attempt to load the first image from the gallery if no image has been taken
    _loadFirstGalleryImage();
  }

  // Function to load the first image from the gallery
  Future<void> _loadFirstGalleryImage() async {
    try {
      // Request permission to access the gallery
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        // Access the gallery and get the first image
        List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: RequestType.image,
        );
        if (albums.isNotEmpty) {
          List<AssetEntity> photos = await albums[0].getAssetListRange(
            start: 0,
            end: 1, // We only need the first image
          );
          if (photos.isNotEmpty) {
            File? file = await photos[0].file;
            if (file != null) {
              setState(() {
                _image = file;
              });
            }
          }
        }
      } else {
        // Handle the case when permission is denied
        debugPrint("Permission to access gallery denied.");
      }
    } catch (e) {
      debugPrint("Error loading gallery image: $e");
    }
  }

  // Function to open the camera
  Future<void> _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Store the image as a File
        });
      } else {
        debugPrint("No image captured.");
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Store the image as a File
        });
      } else {
        debugPrint("No image selected.");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _saveNote() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ph = prefs.getString("phone-number");

      // TODO: Implement image upload to cloud storage (e.g., Firebase Storage)
      // For now, we'll assume the image URL is obtained after upload
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      await FirebaseFirestore.instance.collection("notes").add({
        "note": noteController.text,
        "creator": ph ?? "Unknown",
        "location": GeoPoint(position.latitude, position.longitude),
        "title": titleController.text,
        "image": imageUrl, // Save the image URL
      });

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint("$e");
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  // Function to upload image to Firebase Storage (or any other storage service)
  Future<String> _uploadImage(File imageFile) async {
    // Implement the image upload logic here
    // Return the image URL after uploading
    // For demonstration, we'll return a placeholder URL
    return "https://example.com/image.jpg";
  }
@override
  Widget build(BuildContext context) {
    // Calculate the height for the image (30% of screen height)
    double imageHeight = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7), // Light sunset background
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // Allow tap outside to dismiss keyboard
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back Button (closer to the left side)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0), // Reduced left padding
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          CupertinoIcons.chevron_back,
                          size: 40.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Display Image Placeholder or selected image
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    height: imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                      color: Colors.grey.shade200, // Placeholder background color
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter, // Align top of the image
                            ),
                          )
                        : Center(
                            child: Text(
                              'Tap to select an image',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title Input
                CupertinoTextField(
                  cursorColor: const Color.fromARGB(222, 57, 32, 15),
                  controller: titleController,
                  placeholder: "Title",
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color.fromARGB(92, 255, 246, 235),
                  ),
                ),

                const SizedBox(height: 20),

                // Note Input Field
                CupertinoTextField(
                                    cursorColor: const Color.fromARGB(222, 57, 32, 15),

                  controller: noteController,
                  placeholder: "Note",
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  maxLines: null, // Allow multiple lines
                  expands: true, // Allow the text field to expand vertically
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color.fromARGB(92, 255, 246, 235),
                  ),
                ),

                const SizedBox(height: 20),

                // Save Note Button (with updated color to match the login page)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _saveNote,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    color: const Color(0xFFC9794E), // Warm sunset peach
                    child: const Text(
                      "Save Note",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // Add spacing to move the camera icon lower

                // Floating Action Button for Camera (closer to the bottom)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0), // Closer to the bottom
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 70, // Slightly smaller button
                      height: 70,
                      child: FloatingActionButton(
                        onPressed: _openCamera,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 35,
                          color: Colors.white,
                        ),
                        backgroundColor: const Color.fromARGB(255, 77, 40, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
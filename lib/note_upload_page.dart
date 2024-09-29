import 'dart:io';  // Needed for working with files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';  // Import image picker

class NoteUploadPage extends StatefulWidget {
  const NoteUploadPage({super.key});

  @override
  State<NoteUploadPage> createState() => _NoteUploadPageState();
}

class _NoteUploadPageState extends State<NoteUploadPage> {
  // Function to open the camera
  Future<void> _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);  // Store the image as a File
        // Navigate to the new screen and pass the image file
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => PhotoNoteScreen(imageFile: imageFile),
          ),
        );
      } else {
        debugPrint("No image captured.");
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed unnecessary SafeArea and Column
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 100, // Making the button bigger
              height: 100, // Making the button bigger
              child: FloatingActionButton(
                onPressed: _openCamera,
                child: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoNoteScreen extends StatefulWidget {
  final File imageFile;

  const PhotoNoteScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<PhotoNoteScreen> createState() => _PhotoNoteScreenState();
}

class _PhotoNoteScreenState extends State<PhotoNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  bool _isSaving = false; // To manage the loading state

  Future<void> _saveNote() async {
    setState(() {
      _isSaving = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ph = prefs.getString("phone-number");

      // TODO: Implement image upload to cloud storage (e.g., Firebase Storage)
      // For now, we'll assume the image URL is obtained after upload
      String imageUrl = await _uploadImage(widget.imageFile);

      await FirebaseFirestore.instance.collection("notes").add({
        "note": noteController.text,
        "creator": ph ?? "Unknown",
        "location": GeoPoint(position.latitude, position.longitude),
        "title": titleController.text,
        "image": imageUrl,  // Save the image URL
      });

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      debugPrint("$e");
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
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
    return Scaffold(
      // Enable swipe back by default on iOS; for Android, we can use WillPopScope if needed
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back button and other header elements
            Row(
              children: [
                const SizedBox(width: 5),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(CupertinoIcons.chevron_back, size: 40.0, color: Colors.black),
                ),
                Expanded(child: Container(),),
              ],
            ),
            // Display the captured image
            Expanded(
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            // Title input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: CupertinoTextField(
                controller: titleController,
                placeholder: "Title",
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                style: const TextStyle(
                  fontSize: 20,
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
                ),
              ),
            ),
            // Note input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: CupertinoTextField(
                controller: noteController,
                placeholder: "Write your note here...",
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                placeholderStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                maxLines: 4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isSaving ? null : _saveNote,
                  child: _isSaving
                      ? const CupertinoActivityIndicator()
                      : const Text('Save Note'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

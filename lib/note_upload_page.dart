import 'dart:io';  // Needed for working with files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_note_2/note_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';  // Import image picker

class NoteUploadPage extends StatefulWidget {
  const NoteUploadPage({super.key});

  @override
  State<NoteUploadPage> createState() => _NoteUploadPageState();
}

class _NoteUploadPageState extends State<NoteUploadPage> {
  TextEditingController titleController = TextEditingController();
  File? _image; // This will hold the captured image

  // Function to open the camera
  Future<void> _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);  // Store the image as a File
        });
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
            const SizedBox(height: 20),

            // Aesthetic Title Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoTextField(
                controller: titleController,
                placeholder: "Title",
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                placeholderStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            NoteUploadWidget(onAddNote: (String note) async {
              try {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? ph = prefs.getString("phone-number");

                FirebaseFirestore.instance.collection("notes").add({
                  "note": note,
                  "creator": ph ?? "ur mom",
                  "location": GeoPoint(position.latitude, position.longitude),
                  "title": titleController.text,
                  // We will implement how to store the image in the next step
                  "image": _image?.path,  // Save the image file path for now
                });

                Navigator.of(context).pop();
              } catch (e) {
                debugPrint("$e");
              }
            }),

            const Spacer(),

            // Larger Camera Button Positioned at the Bottom Middle
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 100, // Making the button bigger
                  height: 100, // Making the button bigger
                  child: FloatingActionButton(
                    onPressed: _openCamera,
                    child: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io'; // Needed for working with files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'package:image_cropper/image_cropper.dart'; // Import image cropper

class NoteUploadPage extends StatefulWidget {
  const NoteUploadPage({super.key});

  @override
  State<NoteUploadPage> createState() => _NoteUploadPageState();
}

class _NoteUploadPageState extends State<NoteUploadPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController(); // Controller for the note
  File? _image; // This will hold the selected image
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker
  String _locationStatus = 'Location not available';
  double? _imageAspectRatio; // Store the image's aspect ratio

  @override
  void initState() {
    super.initState();
  }

  // Function to open the camera
  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          await _setImageAndAspectRatio(croppedFile);
        }
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
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          await _setImageAndAspectRatio(croppedFile);
        }
      } else {
        debugPrint("No image selected.");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // Function to crop the image
  Future<File?> _cropImage(File imageFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error cropping image: $e");
      return null;
    }
  }

  // Function to set the image and calculate its aspect ratio
  Future<void> _setImageAndAspectRatio(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        var myImageWidth = info.image.width.toDouble();
        var myImageHeight = info.image.height.toDouble();
        completer.complete(Size(myImageWidth, myImageHeight));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _image = imageFile;
      _imageAspectRatio = imageSize.width / imageSize.height;
    });
  }

  Future<void> _saveNote() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ph = prefs.getString("phone-number");

      // Upload the image if present, otherwise skip
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      await FirebaseFirestore.instance.collection("notes").add({
        "note": noteController.text,
        "creator": ph ?? "Unknown",
        "location": GeoPoint(position.latitude, position.longitude),
        "title": titleController.text,
        if (imageUrl != null) "image": imageUrl, // Save the image URL only if there is an image
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

  // Remove the selected image
  void _removeImage() {
    setState(() {
      _image = null;
      _imageAspectRatio = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7), // Light sunset background
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // Allow tap outside to dismiss keyboard
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: SafeArea(
          bottom: false,
          child: Column( // Replaced with a simple Column for better expanding
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Row(
                children: [
                  const SizedBox(width: 5),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(CupertinoIcons.chevron_back,
                        size: 40.0, color: Colors.black),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              const SizedBox(height: 10),
              // Display the selected image or placeholder
              _image != null && _imageAspectRatio != null
                  ? Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.8,
                          child: AspectRatio(
                            aspectRatio: _imageAspectRatio!,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: 32,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            'Tap to select an image',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
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
              const SizedBox(height: 10),
              // Expanded note input widget to take up the remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[100], // Light yellow background for the note box
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CupertinoTextField(
                      controller: noteController,
                      placeholder: "write here", // Updated placeholder
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
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
                      decoration: const BoxDecoration(), // No default Cupertino decoration
                    ),
                  ),
                ),
              ),
              // Save Note Button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _saveNote,
                    color: Colors.orangeAccent[100], // Pastel orange button color
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: const Text(
                      'Save Note',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.white, // White text color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FloatingActionButton(
                      onPressed: _openCamera,
                      child: const Icon(Icons.camera_alt,
                          size: 35, color: Colors.white),
                      backgroundColor: Colors.black,
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
    );
  }
}
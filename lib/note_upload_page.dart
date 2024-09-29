import 'dart:async';
import 'dart:io'; // Needed for working with files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'package:photo_manager/photo_manager.dart'; // Import photo_manager for gallery access
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:image_cropper/image_cropper.dart'; // Import image cropper
import 'package:permission_handler/permission_handler.dart'; // For handling permissions

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

  // Function to request camera permission
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      return status.isGranted;
    }
    return true;
  }

  // Function to open the camera
  Future<void> _openCamera() async {
    try {
      // Request camera permission
      bool isGranted = await _requestCameraPermission();
      if (!isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to take pictures.')),
        );
        return;
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening camera: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cropping image: $e')),
      );
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
        imageUrl = await _uploadImage(_image!, ph!);
      }

      debugPrint("Image uploaded: $imageUrl");
      await FirebaseFirestore.instance.collection("notes").add({
        "note": noteController.text,
        "creator": ph ?? "Unknown",
        "location": GeoPoint(position.latitude, position.longitude),
        "timestamp": FieldValue.serverTimestamp(),
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

  // Function to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String phoneNumber) async {
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference with phone and timestamp
    final imageRef = storageRef.child('images/$phoneNumber/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);

    return await imageRef.getDownloadURL();
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
      
      backgroundColor: const Color(0xFFFFF8E7),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          bottom: false,
          child: Column(
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
                    child: const Icon(CupertinoIcons.chevron_back, size: 40.0, color: Colors.black),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              const SizedBox(height: 10),
              // Display the selected image or placeholder inside a box with padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _image != null && _imageAspectRatio != null
                      ? Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 0.8, // Image width with padding inside the box
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
                              right: -10,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.black.withOpacity(0.6),
                                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2, // Placeholder height
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
                                  fontFamily: 'courier',
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Note input area with "write here" placeholder aligned top-left
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 252, 252, 244),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CupertinoTextField(
                      cursorColor:  Color.fromARGB(255, 77, 40, 24),
                      controller: noteController,
                      placeholder: "write here",
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15), // Left-aligned with higher starting point
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'Courier', // Monospace typewriter font
                      ),
                      placeholderStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Courier', // Typewriter-style placeholder
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top, // Align text to the top
                      decoration: const BoxDecoration(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Save Note button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CupertinoButton(
                  onPressed: _saveNote,
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Smaller button padding
                  color: const Color.fromARGB(255, 112, 73, 52),
                  child: const Text(
                    "Save Note",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Smaller font size
                      fontFamily: 'Courier', // Monospace typewriter font
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Floating Action Button for Camera
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 60, // Smaller camera button
                    height: 60,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Open camera logic
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      ),
                      backgroundColor: const Color.fromARGB(255, 77, 40, 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_note_2/group_page.dart';
import 'package:local_note_2/firebase_options.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class ObscuredTextFieldSample extends StatefulWidget {
  final TextEditingController controller;

  // Constructor to accept the TextEditingController from the parent
  const ObscuredTextFieldSample({super.key, required this.controller});

  @override
  _ObscuredTextFieldSampleState createState() => _ObscuredTextFieldSampleState();
}

class _ObscuredTextFieldSampleState extends State<ObscuredTextFieldSample> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: widget.controller, // Use the controller passed from the parent
        keyboardType: TextInputType.phone,  // Number keyboard
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),  // Add phone icon
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),  // Rounded corners
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),  // Focused border color
          ),
          labelText: 'Phone Number',
          labelStyle: TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class TextFieldExampleApp extends StatefulWidget {
  const TextFieldExampleApp({super.key});

  @override
  _TextFieldExampleAppState createState() => _TextFieldExampleAppState();
}

class _TextFieldExampleAppState extends State<TextFieldExampleApp> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  void _handleLoginButtonPressed() async {
    String phoneNumber = "+1 ${_phoneController.text}";
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Log In'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                ObscuredTextFieldSample(controller: _phoneController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleLoginButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TextFieldExampleApp());
}

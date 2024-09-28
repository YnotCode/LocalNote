import 'package:flutter/material.dart';

class ObscuredTextFieldSample extends StatelessWidget {
  const ObscuredTextFieldSample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
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

class TextFieldExampleApp extends StatelessWidget {
  const TextFieldExampleApp({super.key});

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
                // Title or branding section
                const SizedBox(height: 20),
                // Obscured text field (phone number)
                const ObscuredTextFieldSample(),
                const SizedBox(height: 20),
                // Button to submit (login)
                ElevatedButton(
                  onPressed: () {
                    // Add login logic here
                  },
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

void main() => runApp(const TextFieldExampleApp());

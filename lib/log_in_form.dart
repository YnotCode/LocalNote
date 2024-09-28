import 'package:flutter/material.dart';

class ObscuredTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;

  const ObscuredTextField({
    super.key,
    required this.controller,
    this.labelText = 'Enter Text',
    this.icon = Icons.lock,  // Default icon is lock for obscure text
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'Log In',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
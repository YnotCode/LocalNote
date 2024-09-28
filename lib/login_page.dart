import 'dart:math';
import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String generateRandomNumber() {
  Random random = Random();
  int randomNumber = 10000 + random.nextInt(90000);  // Ensures a 5-digit number
  return randomNumber.toString();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controller = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String otpCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD580),  // Light sunset yellow
              Color(0xFFFDA65A),  // Sunset orange
              Color(0xFFF06D55)   // Deep sunset peach
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 48),
                Image.asset('assets/logo.jpg', width: 120, height: 120),
                SizedBox(height: 48),
                Text("Welcome Back!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Glad to see you!", style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 32),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final TwilioFlutter twilioFlutter = TwilioFlutter(
                      accountSid: 'YOUR_SID', 
                      authToken: 'YOUR_TOKEN', 
                      twilioNumber: 'YOUR_TWILIO_NUMBER'
                    );
                    setState(() {
                      otpCode = generateRandomNumber();
                    });
                    twilioFlutter.sendSMS(
                      toNumber: controller.text, 
                      messageBody: "Your OTP is $otpCode"
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('OTP has been sent to your phone number.'))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFB7268),  // Warm sunset peach
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {}, 
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () {}, 
                      child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      otpCode = generateRandomNumber();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('A new OTP has been sent to your phone number.'))
                    );
                  },
                  child: Text("Resend OTP", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

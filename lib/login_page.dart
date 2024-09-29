import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_note_2/location_ios.dart';
import 'verification_page.dart';
import 'package:http/http.dart' as http;

void sendVerification(String number) async {
  // Twilio credentials
  String accountSid = 'AC99e9169db4ebc2f46da08bf858a0b0b2';
  String authToken = '82f63c9e871cd8ef064e27b6917650f8';

  // Encode credentials in base64 for Basic Auth
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

  // Set the headers
  Map<String, String> headers = {
    'Authorization': basicAuth,
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  // Set the body
  Map<String, String> body = {
    'To': number,
    'Channel': 'sms',
  };

  // Make the POST request
  final response = await http.post(
    Uri.parse(
        'https://verify.twilio.com/v2/Services/VAc3b3e9da4cd4e79693c28ec2bff53e5a/Verifications'),
    headers: headers,
    body: body,
  );

  // Print the response
  if (response.statusCode == 200) {
    print('Verification sent successfully!');
  } else {
    print('Failed to send verification: ${response.statusCode}');
    print(response.body);
  }
}

String phoneNumberNormalization(String phoneNumber) {
  if (!RegExp(r'^[0-9+\-]+$').hasMatch(phoneNumber) ||
      phoneNumber.length < 10) {
    return "Error";
  }

  String normalizedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (normalizedNumber.length > 10) {
    normalizedNumber = normalizedNumber.substring(normalizedNumber.length - 10);
  }
  return '+1${normalizedNumber}';
}

class LoginPage extends StatefulWidget {
  final Function onSuccess;
  const LoginPage({super.key, required this.onSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String generateRandomNumber() {
  Random random = Random();
  int randomNumber = 10000 + random.nextInt(90000); // Ensures a 5-digit number
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
              Color(0xFFFFD580), // Light sunset yellow
              Color(0xFFFDA65A), // Sunset orange
              // Color(0xFFF06D55) // Deep sunset peach
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
                Text('Noteify', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                SizedBox(height: 48),
                // Text("Welcome Back!",
                //     style: TextStyle(
                //         color: const Color.fromARGB(255, 59, 29, 11),
                //         fontSize: 24,
                //         fontWeight: FontWeight.bold)),
                // SizedBox(height: 8),
                // Text("Glad to see you!",
                //     style: TextStyle(color: const Color.fromARGB(255, 66, 36, 19), fontSize: 18)),
                // SizedBox(height: 32),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  cursorColor: const Color.fromARGB(222, 57, 32, 15),
                  style: TextStyle(color: const Color.fromARGB(222, 57, 32, 15)),
                  decoration: InputDecoration(
                    hintText: "Phone Number",
                    hintStyle: TextStyle(color: const Color.fromARGB(222, 134, 109, 91)),
                    filled: true,
                    fillColor: const Color.fromARGB(92, 255, 246, 235),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Adjust the value as needed
                  child: ElevatedButton(
                  onPressed: () {
                    String normalizedPhoneNumber =
                        phoneNumberNormalization(controller.text);
                    if (normalizedPhoneNumber != "Error") {
                      sendVerification(normalizedPhoneNumber);
                      Navigator.push(
                        context, // Use the current context directly
                        CupertinoPageRoute(
                          builder: (context) => VerificationPage(
                              phoneNumber: normalizedPhoneNumber,
                              onSuccess: (text) {
                                Navigator.pop(context);
                                widget.onSuccess(text);
                              }),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('A code has been sent to your phone number.'),
                            backgroundColor: const Color.fromARGB(255, 194, 130, 73)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please enter a valid phone number.'),
                          backgroundColor: Colors.red));
                    }
                  },
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 201, 121, 78), // Warm sunset peach
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                  Text("Send Code",
                      style: TextStyle(color: const Color.fromARGB(221, 255, 255, 255), fontSize: 16)),
                ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

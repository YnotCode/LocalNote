import 'package:flutter/material.dart';
import 'package:local_note_2/login_page.dart';
import 'package:pinput/pinput.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationPage extends StatefulWidget {
  final Function onSuccess;
  final String phoneNumber;
  const VerificationPage(
      {super.key, required this.onSuccess, required this.phoneNumber});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

Future<bool> verifyPhoneNumber(ph, code) async {
  String accountSid = 'AC99e9169db4ebc2f46da08bf858a0b0b2';
  String authToken =
      '82f63c9e871cd8ef064e27b6917650f8'; // Replace with your Twilio Auth Token
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

  final response = await http.post(
    Uri.parse(
        'https://verify.twilio.com/v2/Services/VAc3b3e9da4cd4e79693c28ec2bff53e5a/VerificationCheck'),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'To': ph, // Replace with the phone number you're verifying
      'Code': code, // Replace with the verification code
    },
  );

  if (response.statusCode == 200) {
    print('Verification successful');
    return true;
  } else {
    print('Verification failed: ${response.statusCode}');
    return false;
  }
  // return true;
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background for the entire screen, including AppBar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                 Color(0xFFFFD580), // Light sunset yellow
              Color(0xFFFDA65A), // Sunset orange
                  // Color(0xFFF06D55), // Deep sunset peach
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content of the screen
          Scaffold(
            backgroundColor: Colors
                .transparent, // Makes the body of the Scaffold transparent
            appBar: AppBar(
              title: Text(
                "Verification",
                style: TextStyle(
                  color: Color.fromARGB(222, 57, 32, 15),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(
                color: Color.fromARGB(222, 57, 32, 15), // Set the back arrow color
              ),
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // Removes AppBar shadow
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              padding:
                  const EdgeInsets.all(16.0), // Add padding around the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Enter Code" Message with Padding
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 40.0), // Adds padding below the text
                    child: Text(
                      "Enter Code",
                      style: TextStyle(
                        color: Color.fromARGB(222, 57, 32, 15), // Message text color
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Verification Code Input
                  Pinput(
                    controller: otpController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    defaultPinTheme: PinTheme(
                      textStyle: TextStyle(
                        fontSize:
                            24, // Set the desired font size for the numbers
                        fontWeight:
                            FontWeight.bold, // Optionally make the numbers bold
                        color:
                            Colors.black, // Set the text color for the numbers
                      ),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.2), // Transparent white inside each square
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(color: const Color.fromARGB(255, 68, 32, 87)),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      textStyle: TextStyle(
                        fontSize:
                            24, // Set the desired font size for focused input
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.1), // Transparent white inside each square
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color.fromARGB(255, 96, 60, 35)),
                      ),
                    ),
                    onCompleted: (pin) async {
                      bool isVerified =
                          await verifyPhoneNumber(widget.phoneNumber, pin);
                      if (isVerified) {
                        widget.onSuccess(widget.phoneNumber);
                      } else {
                        debugPrint("Verification failed");
                      }
                    },
                  ),
                  SizedBox(height: 32),

                  // Resend OTP Button with Brighter Font Color
                  TextButton(
                    onPressed: () {
                      sendVerification(widget.phoneNumber);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'A new code has been sent to your phone number.',
                            style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)), // Text color
                          ),
                          backgroundColor: const Color.fromARGB(255, 194, 130, 73), // Set SnackBar background color to transparent
                          // behavior: SnackBarBehavior
                          //     .floating, // Optional: makes the SnackBar float above the content
                        ),
                      );
                    },
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        color: Color.fromARGB(222, 98, 57, 30), // Brighter font color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

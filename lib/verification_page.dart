import 'package:flutter/material.dart';
import 'package:local_note_2/login_page.dart';
import 'package:pinput/pinput.dart';

class VerificationPage extends StatefulWidget {
  final Function onSuccess;
  final String phoneNumber;
  const VerificationPage({super.key, required this.onSuccess, required this.phoneNumber});

  @override
  _VerificationPageState createState() => _VerificationPageState();
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
                  Color(0xFFFFD580),  // Light sunset yellow
                  Color(0xFFFDA65A),  // Sunset orange
                  Color(0xFFF06D55),  // Deep sunset peach
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content of the screen
          Scaffold(
            backgroundColor: Colors.transparent,  // Makes the body of the Scaffold transparent
            appBar: AppBar(
              title: Text(
                "Verification",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,  // Set the back arrow color
              ),
              backgroundColor: Colors.transparent,  // Transparent AppBar
              elevation: 0,  // Removes AppBar shadow
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),  // Add padding around the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Enter Code" Message with Padding
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.0),  // Adds padding below the text
                    child: Text(
                      "Enter Code",
                      style: TextStyle(
                        color: Colors.white,  // Message text color
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
      fontSize: 24,  // Set the desired font size for the numbers
      fontWeight: FontWeight.bold,  // Optionally make the numbers bold
      color: Colors.black,  // Set the text color for the numbers
    ),
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),  // Transparent white inside each square
      borderRadius: BorderRadius.circular(8),
      // border: Border.all(color: const Color.fromARGB(255, 68, 32, 87)),
    ),
  ),
  focusedPinTheme: PinTheme(
    textStyle: TextStyle(
      fontSize: 24,  // Set the desired font size for focused input
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),  // Transparent white inside each square
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color.fromARGB(255, 107, 67, 118)),
    ),
  ),
  onCompleted: (pin) async {
    bool isVerified = await verifyPhoneNumber(widget.phoneNumber, pin);
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
                      style: TextStyle(color: Colors.white),  // Text color
                    ),
                    backgroundColor: Colors.transparent,  // Set SnackBar background color to transparent
                    behavior: SnackBarBehavior.floating,  // Optional: makes the SnackBar float above the content
                  ),
                );
                    },
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        color: const Color.fromARGB(205, 255, 255, 255),  // Brighter font color
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

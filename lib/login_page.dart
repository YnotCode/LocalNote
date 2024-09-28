import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_note_2/location_ios.dart';



void sendVerification(String number) async {
  // Twilio credentials
  String accountSid = 'AC99e9169db4ebc2f46da08bf858a0b0b2';
  String authToken = '82f63c9e871cd8ef064e27b6917650f8';
  
  // Encode credentials in base64 for Basic Auth
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

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
    Uri.parse('https://verify.twilio.com/v2/Services/VAc3b3e9da4cd4e79693c28ec2bff53e5a/Verifications'),
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


Future<bool> verifyPhoneNumber(ph, code) async {
  String accountSid = 'AC99e9169db4ebc2f46da08bf858a0b0b2';
  String authToken = '82f63c9e871cd8ef064e27b6917650f8';   // Replace with your Twilio Auth Token
  final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

  final response = await http.post(
    Uri.parse('https://verify.twilio.com/v2/Services/VAc3b3e9da4cd4e79693c28ec2bff53e5a/VerificationCheck'),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'To': ph,  // Replace with the phone number you're verifying
      'Code': code,      // Replace with the verification code
    },
  );

  if (response.statusCode == 200) {
    print('Verification successful');
    return true;
  } else {
    print('Verification failed: ${response.statusCode}');
    return false;
  }

}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String generateRandomNumber() {
  Random random = Random();
  int randomNumber = 10000 + random.nextInt(90000); // Generates a number between 10000 and 99999
  return randomNumber.toString();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController controller = TextEditingController();
  TextEditingController optController = TextEditingController();
  String optCode = "sdkfjhskjfhdoisafjnfiijvnjksdnv";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Login Page"),
          CupertinoTextField(
            placeholder: "Enter Phone Number",
            controller: controller,
          ),
          CupertinoButton(
            onPressed: () {
              setState(() {
                sendVerification("+17343238630");
              });
            },
            child: const Text("Login"),
          ),
          CupertinoTextField(
            placeholder: "Enter OTP",
            controller: optController
          ),  
          CupertinoButton(
            onPressed: () async {
              debugPrint("They entered: ${optController.text}");
              bool didGood = await verifyPhoneNumber(controller.text, optController.text);

              if (!didGood){
                debugPrint("L");
              }
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) => LocationTracker()));
              //TODO: Show toast with toastification.show()
            },
            child: Text("Submit"),
          )
        ],
      )
    );
  }
}
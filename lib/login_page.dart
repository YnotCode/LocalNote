import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

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
              final TwilioFlutter twilioFlutter = TwilioFlutter(
                  accountSid: '', // replace with Account SID
                  authToken: '', // replace with Auth Token
                  twilioNumber: '' // replace with Twilio Number(With country code)
              );

              setState(() {
                optCode = generateRandomNumber();
              });
              twilioFlutter.sendSMS(toNumber: controller.text, messageBody: "Your OTP is $optCode");
            },
            child: const Text("Login"),
          ),
          CupertinoTextField(
            placeholder: "Enter OTP",
            controller: optController
          ),  
          CupertinoButton(
            onPressed: (){
              debugPrint("They entered: ${optController.text}");
              if (optController.text == optCode){
                debugPrint("VALID");
              }
              else{
                debugPrint("INVALID");
              }
            },
            child: Text("Submit"),
          )
        ],
      )
    );
  }
}
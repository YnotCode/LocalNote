// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_note_2/group_page.dart';
import 'package:local_note_2/firebase_options.dart';
import 'package:local_note_2/location_ios.dart';
import 'note_upload.dart';
import 'log_in_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LocationTracker(),
        ),
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: BottomNavBar(),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CupertinoButton(
          child: const Icon(CupertinoIcons.group, size: 40.0, color: Colors.black),
          onPressed: (){
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const GroupPage()));
          },
        ),
        CupertinoButton(
          child: const Icon(CupertinoIcons.add, size: 40.0, color: Colors.black),
          onPressed: () async {
            final doc = await FirebaseFirestore.instance.collection("test").doc("counter").get();
            debugPrint("${doc.data()?["count"]}"); 
          },
        ),
        CupertinoButton(
          child: const Icon(CupertinoIcons.settings, size: 40.0, color: Colors.black),
          onPressed: () async{
            // await FirebaseAuth.instance.verifyPhoneNumber(
            //     phoneNumber: '+1-734-323-8630',
            //     verificationCompleted: (PhoneAuthCredential credential) {},
            //     verificationFailed: (FirebaseAuthException e) {},
            //     codeSent: (String verificationId, int? resendToken) {},
            //     codeAutoRetrievalTimeout: (String verificationId) {},
            //   );
          },
        ),

      ],
    );
  }
}


class NoteUploadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Note App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: NoteUploadHome(),
    );
  }
}

class NoteUploadHome extends StatefulWidget {
  @override
  _NoteUploadHomeState createState() => _NoteUploadHomeState();
}

class _NoteUploadHomeState extends State<NoteUploadHome> {
  List<String> NoteUploads = [];

  void _addNoteCallback(String note) {
    setState(() {
      NoteUploads.add(note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Use the NoteUploadWidget and pass the callback
            NoteUploadWidget(onAddNote: _addNoteCallback),
            SizedBox(height: 20),
            // Display saved sticky notes
            Expanded(
              child: ListView.builder(
                itemCount: NoteUploads.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.yellow[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(NoteUploads[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

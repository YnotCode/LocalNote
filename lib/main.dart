// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_note_2/group_page.dart';
import 'package:local_note_2/firebase_options.dart';
import 'package:local_note_2/location_ios.dart';
import 'package:local_note_2/login_page.dart';
import 'package:local_note_2/map.dart';
import 'package:local_note_2/note_upload_page.dart';
import 'note_upload.dart';

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
    return const MaterialApp(
      home: Scaffold(
        body: LoginPage(),
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
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => LocationTracker()));
          },
        ),
        CupertinoButton(
          child: const Icon(CupertinoIcons.add, size: 40.0, color: Colors.black),
          onPressed: () async {
            final doc = await FirebaseFirestore.instance.collection("test").doc("counter").get();
            debugPrint("${doc.data()?["count"]}"); 
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const NoteUploadPage()));
          },
        ),
        CupertinoButton(
          child: const Icon(CupertinoIcons.settings, size: 40.0, color: Colors.black),
          onPressed: () async{
            // await FirebaseAuth.instance.verifyPhoneNumber(
            //     phoneNumber: '+1-734-383-3455',
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
  const NoteUploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Note App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const NoteUploadHome(),
    );
  }
}

class NoteUploadHome extends StatefulWidget {
  const NoteUploadHome({super.key});

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
        title: const Text('Note App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Use the NoteUploadWidget and pass the callback
            NoteUploadWidget(onAddNote: _addNoteCallback),
            const SizedBox(height: 20),
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
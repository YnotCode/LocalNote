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
// import 'package:local_note_2/map.dart';
import 'package:local_note_2/note_upload_page.dart';
import 'package:local_note_2/setting_page.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_upload.dart';
import 'friends.dart';
import 'setting_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rxdart/rxdart.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling background message!!");
  await Firebase.initializeApp();

  //print("Handling a background message: ${message.messageId}");
}

void main() async {
  SharedPreferences.setMockInitialValues({"logged-in": "true", "phone-number": "+17343238630", "name": "Tony"});
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 // TODO: Request permission
 final messaging = FirebaseMessaging.instance;

 // TODO: Register with FCM
 // TODO: Set up foreground message handler
 // TODO: Set up background message handler


  // Web/iOS app users need to grant permission to receive messages
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Handling a foreground message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title}');
    debugPrint('Message notification: ${message.notification?.body}');

    _messageStreamController.sink.add(message);
  });

  // TODO: Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  debugPrint('Permission granted: ${settings.authorizationStatus}');

  const topic = 'all';
  await messaging.subscribeToTopic(topic);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  bool userIsLoggedIn = false;

  @override 
  void initState() {


    Location location = Location();

    location.onLocationChanged.listen((LocationData currentLocation) {
      debugPrint("NEW POS: ${currentLocation.latitude} ${currentLocation.longitude}");
    });

    location.enableBackgroundMode(enable: true);

    SharedPreferences.getInstance().then((prefs){
      String? x = prefs.getString("logged-in");
      String? y = prefs.getString("name");

      debugPrint("HELLO!!");
      if (x == null){
        setState(() {
          userIsLoggedIn = false;
        });
      }
      else if (x == "true"){
        setState(() {
          userIsLoggedIn = true;
        });
      }

      if (y == null){
        setState(() {
          exists = false;
        });
      }
      else{
        setState(() {
          exists = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: userIsLoggedIn ? 
          const MainMap()
         : LoginPage(onSuccess: (phNumber) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("logged-in", "true");
          prefs.setString("phone-number", phNumber);
          setState(() {
            userIsLoggedIn = true;
          });
        },),
        bottomNavigationBar: userIsLoggedIn ? const SafeArea(
          bottom: true,
          child: BottomNavBar(),
        ) : null,
        
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
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CommunityPage()));
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
          onPressed: () async {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const SettingsPage()));
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
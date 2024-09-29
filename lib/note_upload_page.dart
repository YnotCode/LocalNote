import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_note_2/note_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteUploadPage extends StatefulWidget {
  const NoteUploadPage({super.key});

  @override
  State<NoteUploadPage> createState() => _NoteUploadPageState();
}

class _NoteUploadPageState extends State<NoteUploadPage> {

  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {


    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                CupertinoButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Icon(CupertinoIcons.chevron_back, size: 40.0, color: Colors.black)
                ), 
                Expanded(child: Container(),)
              ]
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: titleController,
              placeholder: "Title",
            ),
            NoteUploadWidget(onAddNote: (String note) async {
              try{
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? ph = prefs.getString("phone-number");
                  FirebaseFirestore.instance.collection("notes").add({
                    "note": note,
                    "creator": ph ?? "ur mom",
                    "location": GeoPoint(position.latitude, position.longitude),
                    "title": titleController.text
                  });
              Navigator.of(context).pop();
              }
              catch(e){
                debugPrint("$e");
              }              
            }),
      
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_note_2/note_upload.dart';

class NoteUploadPage extends StatelessWidget {
  const NoteUploadPage({super.key});

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
                SizedBox(width: 5),
                CupertinoButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Icon(CupertinoIcons.chevron_back, size: 40.0, color: Colors.black)
                ), 
                Expanded(child: Container(),)
              ]
            ),
            NoteUploadWidget(onAddNote: (String note) async {
              try{
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  FirebaseFirestore.instance.collection("notes").add({
                    "note": note,
                    "creator": "+1111111111",
                    "location": GeoPoint(position.latitude, position.longitude),
                    "title": "NOTE"
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
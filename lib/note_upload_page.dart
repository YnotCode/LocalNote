import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_note_2/map.dart';
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
            NoteUploadWidget(onAddNote: (String note){
              FirebaseFirestore.instance.collection("notes").add({
                "note": note,
                "creator": "+1111111111",
                "location": "37.7749,-122.4194",
                "title": "NOTE"
              });
            }),
      
          ],
        ),
      ),
    );
  }
}
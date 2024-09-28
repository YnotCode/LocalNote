import 'package:flutter/material.dart';

class NoteUploadWidget extends StatefulWidget {
  final Function(String) onAddNote; // Callback when a note is added

  NoteUploadWidget({required this.onAddNote});

  @override
  _NoteUploadWidgetState createState() => _NoteUploadWidgetState();
}

class _NoteUploadWidgetState extends State<NoteUploadWidget> {
  TextEditingController _controller = TextEditingController();

  void _handleAddNote() {
    if (_controller.text.isNotEmpty) {
      widget.onAddNote(_controller.text); // Pass the note back to the parent
      _controller.clear(); // Clear the input after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your note here...',
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _handleAddNote,
            child: Text('Add Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

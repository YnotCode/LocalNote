import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoteUploadWidget extends StatefulWidget {
  final Function(String) onAddNote; // Callback when a note is added

  const NoteUploadWidget({super.key, required this.onAddNote});

  @override
  _NoteUploadWidgetState createState() => _NoteUploadWidgetState();
}

class _NoteUploadWidgetState extends State<NoteUploadWidget> {
  final TextEditingController _controller = TextEditingController();

  void _handleAddNote() {
    if (_controller.text.isNotEmpty) {
      widget.onAddNote(_controller.text); // Pass the note back to the parent
      _controller.clear(); // Clear the input after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 400,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CupertinoTextField(
            controller: _controller,
            maxLines: 14,
            padding: const EdgeInsets.only(
              top: 8.0,  // Adjust this for the desired top padding
              left: 8.0, // Adjust this for the desired left padding
            ),
            decoration: const BoxDecoration(
              border: Border(),
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _handleAddNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }
}

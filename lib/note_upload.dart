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
    return Scaffold(
      backgroundColor: Colors.white, // You can set a background color if you want
      body: Center(
        child: Container(
          width: 300, // Adjust the width to your preference
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
            mainAxisSize: MainAxisSize.min, // Ensures the box height fits its content
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
                child: Text(
                  'Add Note',
                  style: TextStyle(color: const Color.fromARGB(255, 255, 252, 244)), // Set text color to white
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(255, 140, 70, 170); // Darker background when pressed
                      }
                      return const Color.fromARGB(255, 144, 77, 176); // Default background color
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GetNamePage extends StatefulWidget {
  final Function(String) onSuccess;

  const GetNamePage({super.key, required this.onSuccess});

  @override
  State<GetNamePage> createState() => _GetNamePageState();
}

class _GetNamePageState extends State<GetNamePage> {
  TextEditingController _nameController = TextEditingController();

  void _submitName() {
    String name = _nameController.text;
    widget.onSuccess(name);
    // Implement further logic here (e.g., save or process the entered name)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD580), // Light sunset yellow
              Color(0xFFFDA65A), // Sunset orange
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Image.asset('assets/logo.jpg', width: 120, height: 120),  // Placeholder image
                const SizedBox(height: 48),
                const Text("Enter Your Name", 
                  style: TextStyle(
                    color: Color.fromARGB(222, 57, 32, 15), 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  cursorColor: const Color.fromARGB(222, 57, 32, 15),
                  style: const TextStyle(color: Color.fromARGB(222, 57, 32, 15)),
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: const Color.fromARGB(222, 134, 109, 91)),
                    filled: true,
                    fillColor: Color.fromARGB(92, 255, 246, 235),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 201, 121, 78),  // Warm sunset peach
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Submit", 
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

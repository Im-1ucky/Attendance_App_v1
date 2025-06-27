import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableImagePage extends StatefulWidget {
  @override
  _TimetableImagePageState createState() => _TimetableImagePageState();
}

class _TimetableImagePageState extends State<TimetableImagePage> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    loadSavedImage();
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      if (kIsWeb) {
        Uint8List? bytes = result.files.first.bytes;
        if (bytes != null) {
          final base64String = base64Encode(bytes);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('timetableBase64', base64String);
          setState(() => _imageBytes = bytes);
        }
      } else {
        final path = result.files.single.path;
        if (path != null) {
          final originalFile = File(path);
          final appDir = await getApplicationDocumentsDirectory();
          final savedPath = '${appDir.path}/timetable.jpg';
          await originalFile.copy(savedPath);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('timetablePath', savedPath);
          Uint8List bytes = await File(savedPath).readAsBytes();
          setState(() => _imageBytes = bytes);
        }
      }
    }
  }

  Future<void> loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final base64String = prefs.getString('timetableBase64');
      if (base64String != null) {
        setState(() => _imageBytes = base64Decode(base64String));
      }
    } else {
      final path = prefs.getString('timetablePath');
      if (path != null && File(path).existsSync()) {
        Uint8List bytes = await File(path).readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Image'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // important for gradient to show
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      // Inside your build method
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text("Upload Timetable"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      side: const BorderSide(color: Colors.indigo),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_imageBytes != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _imageBytes = null);
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.remove(
                              kIsWeb ? 'timetableBase64' : 'timetablePath');
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Clear"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              if (_imageBytes != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullscreenImageView(imageBytes: _imageBytes!),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                        ),
                      )),
                )
              else
                Column(
                  children: [
                    Icon(Icons.image_outlined,
                        size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      "No timetable uploaded yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenImageView extends StatelessWidget {
  final Uint8List imageBytes;

  const FullscreenImageView({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height,
                  maxWidth: screenSize.width,
                ),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

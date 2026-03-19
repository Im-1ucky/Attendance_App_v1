import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logs/15daylogs.dart';
import 'instructions.dart';
import 'timetable.dart';

class AppDrawer extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final Function(int) onNavigateToPage;
  final List<Map<String, dynamic>> notes;
  final List<Map<String, dynamic>> logs;
  final double Function(List<Map<String, dynamic>>) calculateOverallAttendance;
  final bool isHolidayMode;
  final Future<void> Function(double) updateTodayLogFromAttendance;
  final Future<void> Function() loadLogs;

  const AppDrawer({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.onNavigateToPage,
    required this.notes,
    required this.logs,
    required this.calculateOverallAttendance,
    required this.isHolidayMode,
    required this.updateTodayLogFromAttendance,
    required this.loadLogs,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Uint8List? _headerImage;

  @override
  void initState() {
    super.initState();
    loadHeaderImage();
  }

  Future<void> loadHeaderImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final base64 = prefs.getString('timetableBase64');
      if (base64 != null) {
        setState(() => _headerImage = base64Decode(base64));
      }
    } else {
      final path = prefs.getString('timetablePath');
      if (path != null && File(path).existsSync()) {
        final bytes = await File(path).readAsBytes();
        setState(() => _headerImage = bytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {
              if (_headerImage != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullscreenImageView(imageBytes: _headerImage!),
                  ),
                );
              }
            },
            child: DrawerHeader(
              decoration: _headerImage != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_headerImage!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                      ),
                    )
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
              child: _headerImage == null
                  ? const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Attendance Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('15 Days Logs'),
            onTap: () async {
              Navigator.pop(context);
              List<Map<String, dynamic>> updatedLogs =
                  await loadAttendanceLogs();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FifteenDayLogsPage(
                          logs: updatedLogs,
                          notes: widget.notes,
                          isHolidayMode: widget.isHolidayMode,
                          calculateOverallAttendance:
                              widget.calculateOverallAttendance,
                          updateTodayLogFromAttendance:
                              widget.updateTodayLogFromAttendance,
                          loadLogs: widget.loadLogs,
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Upload/View Timetable'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimetableImagePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('How to Use the App'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InstructionsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

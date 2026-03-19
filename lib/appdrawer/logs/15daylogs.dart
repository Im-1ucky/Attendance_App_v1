import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logshelper.dart';

// Save attendance logs to SharedPreferences
Future<void> saveAttendanceLogs(List<Map<String, dynamic>> logs) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedLogs = jsonEncode(logs);
  await prefs.setString('attendance_logs', encodedLogs);
}

// Load attendance logs from SharedPreferences
Future<List<Map<String, dynamic>>> loadAttendanceLogs() async {
  final prefs = await SharedPreferences.getInstance();
  final encodedLogs = prefs.getString('attendance_logs');
  if (encodedLogs != null) {
    // Decode JSON string to List<Map<String, dynamic>>
    final List<dynamic> decoded = jsonDecode(encodedLogs);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return [];
}

class FifteenDayLogsPage extends StatefulWidget {
  final List<Map<String, dynamic>> logs;
  final List<Map<String, dynamic>> notes;
  final bool isHolidayMode;
  final double Function(List<Map<String, dynamic>>) calculateOverallAttendance;
  final Future<void> Function(double) updateTodayLogFromAttendance;
  final Future<void> Function() loadLogs;

  const FifteenDayLogsPage({
    required this.logs,
    required this.notes,
    required this.isHolidayMode,
    required this.calculateOverallAttendance,
    required this.updateTodayLogFromAttendance,
    required this.loadLogs,
  });

  @override
  _FifteenDayLogsPageState createState() => _FifteenDayLogsPageState();
}

class _FifteenDayLogsPageState extends State<FifteenDayLogsPage> {
  List<Map<String, dynamic>> logs = [];
  bool isHolidayMode = false;

  @override
  void initState() {
    super.initState();
    logs = widget.logs;
    loadHolidayMode();
  }

  Future<void> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsString = prefs.getString('attendance_logs');
    if (logsString != null) {
      setState(() {
        logs = List<Map<String, dynamic>>.from(json.decode(logsString));
      });
    }
  }

  Future<void> loadHolidayMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isHolidayMode = prefs.getBool('isHolidayMode') ?? false;
    });
  }

  Future<void> toggleHolidayMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHolidayMode', value);
    final notesString = prefs.getString('notes');
    final notes = notesString != null
        ? (json.decode(notesString) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    setState(() {
      isHolidayMode = value;
    });

    if (value) {
      // Remove today's log if holiday is enabled
      final today = DateTime.now();
      logs.removeWhere((log) {
        final logDate = DateTime.parse(log['date']);
        return logDate.year == today.year &&
            logDate.month == today.month &&
            logDate.day == today.day;
      });
      await prefs.setString('attendance_logs', json.encode(logs));
      await loadLogs();
    } else {
      // Recreate today's log if holiday is turned off and notes exist
      if (notes.isNotEmpty) {
        await recalculateTodayLogIfNeeded(
          notes,
          isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        await loadLogs();
      }
    }
  }

  Color getAttendanceColor(double percentage) {
    if (percentage < 65) return Colors.red;
    if (percentage < 75 && percentage >= 65) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final tileColor = isDarkMode ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          '15 Days Attendance Logs',
          style: TextStyle(color: textColor),
        ),
        actions: [
          Tooltip(
            message: isHolidayMode
                ? 'Yes, today is a Holiday'
                : "No, today isn't a Holiday",
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    'Is today a Holiday?',
                    style: TextStyle(color: textColor),
                  ),
                ),
                Switch(
                  value: isHolidayMode,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  onChanged: toggleHolidayMode,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: logs.isEmpty
          ? Center(
              child: Text(
                "No attendance logs created.",
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: logs.length + 1, // Extra item for Clear Logs button
              separatorBuilder: (_, __) => Divider(
                color: isDarkMode ? Colors.white12 : Colors.black12,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                if (index < logs.length) {
                  final log = logs[index];
                  DateTime date;
                  if (log['date'] is String) {
                    date = DateTime.parse(log['date']);
                  } else {
                    date = log['date'];
                  }
                  final attendance = (log['attendance'] ?? 0.0) as double;
                  final dayOfWeek = DateFormat('EEEE').format(date);
                  final formattedDate =
                      '${DateFormat('MMM d, yyyy').format(date)} ($dayOfWeek)';
                  final color = getAttendanceColor(attendance);
                  return Container(
                    color: tileColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: color,
                      ),
                      title: Text(
                        formattedDate,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '${attendance.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Clear Logs button at end
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Clear All Logs?"),
                              content: const Text(
                                "This will permanently delete all 15-day attendance logs.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text(
                                    "Clear",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('attendance_logs');
                          setState(() {
                            logs.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      label: const Text(
                        "Clear Logs",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: const StadiumBorder(), // ⬅️
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}

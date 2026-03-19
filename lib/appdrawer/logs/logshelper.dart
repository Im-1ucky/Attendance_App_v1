import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

Future<void> setLogStartDateIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('logs_start_date')) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('logs_start_date', today);
  }
}

Future<void> recalculateTodayLogIfNeeded(
  List<Map<String, dynamic>> notes,
  bool isHolidayMode,
  double Function(List<Map<String, dynamic>>) calculateOverallAttendance,
  Future<void> Function(double) updateTodayLogFromAttendance,
  Future<void> Function() loadLogs,
) async {
  final prefs = await SharedPreferences.getInstance();
  final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Map<String, dynamic>> logs = [];

  final logsString = prefs.getString('attendance_logs');
  if (logsString != null) {
    logs = List<Map<String, dynamic>>.from(json.decode(logsString));
  }

  final includedNotes =
      notes.where((note) => note['isIncluded'] != false).toList();

  if (isHolidayMode || notes.isEmpty || includedNotes.isEmpty) {
    // Remove today's log if it's a holiday, no notes, or all are skipped
    logs.removeWhere((log) => log['date'] == todayString);
    await prefs.setString('attendance_logs', json.encode(logs));
    await loadLogs();
    return;
  }

  // Otherwise, update today's log
  final percentage = calculateOverallAttendance(notes);
  await updateTodayLogFromAttendance(percentage);
  await loadLogs();
}

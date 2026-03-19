import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'appdrawer/logs/logshelper.dart';
import 'pages/secondpiepage/secondpage.dart';
import 'pages/splash.dart';
import 'pages/homepage.dart';
import 'pages/secondpiepage/piechart.dart';
import 'appdrawer/appdrawer.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBM1C2wUHjI28g8F-5jUrzEHQpJ_wT-JtI",
            authDomain: "attendance-lucky.firebaseapp.com",
            projectId: "attendance-lucky",
            storageBucket: "attendance-lucky.appspot.com",
            messagingSenderId: "317267477792",
            appId: "1:317267477792:web:f2324873839bcd80184345"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // This should be set to false here
    home: SplashScreen(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PageController _pageController;
  List<Map<String, dynamic>> notes = [];
  bool isDarkMode = false; // Theme mode toggle
  int selectedIndex = 0;
  bool isSplashComplete = false;
  List<bool> selectedDays = List.generate(6, (_) => false);
  String noteSubject = ""; // Variable to store the subject name input
  List<Map<String, dynamic>> logs = [];
  bool isHolidayMode = false;
  bool resetVisualCounters = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadNotes();
    loadThemeMode();
    loadHolidayMode();
    loadLogs();
    checkResetVisualCounters().then((shouldReset) {
      resetVisualCounters = shouldReset;
      setState(() {});
    });
  }

  Future<bool> checkResetVisualCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString('lastResetDate');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastReset != today) {
      await prefs.setString('lastResetDate', today);
      return true; // means reset is needed
    } else {
      return false; // same day, no reset
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    if (notesString != null) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(json.decode(notesString));
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(notes));
  }

  Future<void> updateTodayLogFromAttendance(double percentage) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);

    final logsString = prefs.getString('attendance_logs');
    List<Map<String, dynamic>> logs = logsString != null
        ? List<Map<String, dynamic>>.from(json.decode(logsString))
        : [];

    logs.removeWhere((log) => log['date'] == todayString);

    logs.add({
      'date': todayString,
      'attendance': percentage,
    });

    // Keep only last 15 logs
    if (logs.length > 15) {
      logs = logs.sublist(logs.length - 15);
    }

    await prefs.setString('attendance_logs', jsonEncode(logs));
  }

  void addNote(Map<String, dynamic> newNote) async {
    setState(() {
      notes.add(newNote);
    });
    await saveNotes();
    await recalculateTodayLogIfNeeded(
      notes,
      isHolidayMode,
      calculateOverallAttendance,
      updateTodayLogFromAttendance,
      loadLogs,
    );
  }

  void deleteNoteAt(int index) async {
    setState(() {
      notes.removeAt(index);
    });
    await saveNotes();
    await recalculateTodayLogIfNeeded(
      notes,
      isHolidayMode,
      calculateOverallAttendance,
      updateTodayLogFromAttendance,
      loadLogs,
    );
  }

  void updateNoteAt(int index, Map<String, dynamic> updatedNote) async {
    setState(() {
      notes[index] = updatedNote;
    });
    await saveNotes();
    await recalculateTodayLogIfNeeded(
      notes,
      isHolidayMode,
      calculateOverallAttendance,
      updateTodayLogFromAttendance,
      loadLogs,
    );
  }

  // Load holiday mode
  Future<void> loadHolidayMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isHolidayMode = prefs.getBool('isHolidayMode') ?? false;
    });
  }

// Save holiday mode
  Future<void> saveHolidayMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHolidayMode', value);
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

  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTheme = prefs.getBool('isDarkMode');
    if (storedTheme != null) {
      setState(() {
        isDarkMode = storedTheme;
      });
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    saveThemeMode(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        endDrawer: AppDrawer(
          isDarkMode: isDarkMode,
          toggleTheme: toggleTheme,
          onNavigateToPage: _navigateToPage,
          notes: notes,
          logs: logs,
          calculateOverallAttendance: calculateOverallAttendance,
          isHolidayMode: isHolidayMode,
          updateTodayLogFromAttendance: updateTodayLogFromAttendance,
          loadLogs: loadLogs,
        ),
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          leading: IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              size: 30,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: toggleTheme,
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          children: [
            HomePage(
              notes: notes,
              isDarkMode: isDarkMode,
              addNote: addNote,
              saveNotes: saveNotes,
              recalculateTodayLogIfNeeded: (
                notes,
                isHolidayMode,
                calculateOverallAttendance,
                updateTodayLogFromAttendance,
                loadLogs,
              ) async {
                await recalculateTodayLogIfNeeded(
                  notes,
                  isHolidayMode,
                  calculateOverallAttendance,
                  updateTodayLogFromAttendance,
                  loadLogs,
                );
              },
              resetVisualCounters: resetVisualCounters,
              checkResetVisualCounters: checkResetVisualCounters,
              isHolidayMode: isHolidayMode,
              calculateOverallAttendance: calculateOverallAttendance,
              updateTodayLogFromAttendance: updateTodayLogFromAttendance,
              loadLogs: loadLogs,
            ),
            SecondPage(
              notes: notes,
              isDarkMode: isDarkMode,
              buildPieChart: (context, notes) => AttendancePieChart(
                overallAttendance: calculateOverallAttendance(notes),
                notes: notes,
                saveNotes: saveNotes,
                recalculateTodayLogIfNeeded: (
                  notes,
                  isHolidayMode,
                  calculateOverallAttendance,
                  updateTodayLogFromAttendance,
                  loadLogs,
                ) async {
                  await recalculateTodayLogIfNeeded(
                    notes,
                    isHolidayMode,
                    calculateOverallAttendance,
                    updateTodayLogFromAttendance,
                    loadLogs,
                  );
                },
                isHolidayMode: isHolidayMode,
                calculateOverallAttendance: calculateOverallAttendance,
                updateTodayLogFromAttendance: updateTodayLogFromAttendance,
                loadLogs: loadLogs,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          currentIndex: selectedIndex,
          onTap: _navigateToPage,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Tracker",
            ),
          ],
        ),
      ),
    );
  }
}

double calculateOverallAttendance(List<Map<String, dynamic>> notes) {
  final includedNotes =
      notes.where((note) => note['isIncluded'] != false).toList();

  int totalPresent = 0;
  int totalAbsent = 0;

  for (var note in includedNotes) {
    totalPresent += (note['presentCount'] as int? ?? 0);
    totalAbsent += (note['absentCount'] as int? ?? 0);
  }

  if (totalPresent + totalAbsent == 0) {
    return 0.0;
  }

  return (totalPresent / (totalPresent + totalAbsent)) * 100;
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to MyApp after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(87, 171, 247, 1.0),
      body: Center(
          child: Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromRGBO(87, 171, 247, 1.0), width: 4.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Image.asset('assets/images/splashscreen.gif'),
      )),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Theme mode toggle
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadNotes(); // Load saved notes when the app starts
    loadTheme(); // Load the saved theme preference when the app starts
  }

  // Save Notes to SharedPreferences
  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedNotes = jsonEncode(notes);
    await prefs.setString('notes', encodedNotes);
  }

  // Load Notes when app starts
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedNotes = prefs.getString('notes');
    if (encodedNotes != null) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(jsonDecode(encodedNotes));
      });
    }
  }

  void saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode); // Save the theme preference
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Default to light theme
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              size: 30,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode; // Toggle dark mode
              });
              saveTheme();
            },
          ),
        ),
        body: selectedIndex == 0 ? buildHomePage() : buildSecondPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
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

  // List of notes
  List<Map<String, dynamic>> notes = [];
  bool isSplashComplete = false;

  // Days selected for note (now 6 days: Monday to Saturday)
  List<bool> selectedDays = List.generate(6, (_) => false);
  String noteSubject = ""; // Variable to store the subject name input
  void addNote(Map<String, dynamic> newNote) {
    setState(() {
      notes.add(newNote); // Adds new note to the list
    });
    saveNotes();
  }

  // Calculate overall attendance percentage
  double calculateOverallAttendance() {
    int totalPresent = 0;
    int totalAbsent = 0;

    for (var note in notes) {
      // Safely cast 'presentCount' and 'absentCount' to int
      totalPresent += (note['presentCount'] as int);
      totalAbsent += (note['absentCount'] as int);
    }

    if (totalPresent + totalAbsent == 0) {
      return 0.0; // Avoid division by zero
    }

    return (totalPresent / (totalPresent + totalAbsent)) * 100;
  }

// Build doughnut chart with only the present percentage
  Widget buildPieChart() {
    double attendancePercentage = calculateOverallAttendance();

    // Define the colors dynamically based on attendance
    Color startColor;
    Color endColor;

    if (attendancePercentage < 65) {
      // Red to orange gradient for low attendance
      startColor = Colors.red;
      endColor = Colors.deepOrange;
    } else if (attendancePercentage >= 65 && attendancePercentage < 75) {
      // Amber gradient for moderate attendance
      startColor = Color(0xFFFFA500);
      endColor = Color(0xFFFFC107);
    } else if (attendancePercentage >= 75 && attendancePercentage < 100) {
      // Green gradient for high attendance
      startColor = Colors.green;
      endColor = Colors.lightGreen;
    } else {
      startColor = Colors.green;
      endColor = Colors.green;
    }
    return Container(
      padding: EdgeInsets.all(1.5),
      child: Container(
        height: 210,
        width: 300,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // Transparent to retain the white circle
        ),
        child: SfRadialGauge(axes: [
          RadialAxis(
            radiusFactor: 0.99,
            axisLineStyle: AxisLineStyle(
              thickness: 35,
              color: Colors.grey.shade200, // White outer circle
            ),
            pointers: [
              RangePointer(
                value: attendancePercentage,
                gradient: SweepGradient(
                  colors: [startColor, endColor], // Use the correct colors
                  startAngle: 0.0,
                  endAngle: 1.0,
                ),
                width: 35,
                animationType: AnimationType.ease,
                enableAnimation: true,
                animationDuration: 500,
                cornerStyle: (attendancePercentage == 100)
                    ? CornerStyle.bothFlat
                    : CornerStyle.bothCurve,
              ),
            ],
            startAngle: 270,
            endAngle: 270,
            showLabels: false,
            showTicks: false,
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  '${attendancePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }

  // Build date container
  Widget buildDateContainer(DateTime date, bool isToday) {
    Color textColor =
        isToday ? Colors.white : (isDarkMode ? Colors.white : Colors.black);

    return Container(
      width: 66,
      height: 90,
      decoration: BoxDecoration(
        gradient: isToday
            ? LinearGradient(
                colors: [
                  Color(0xFF2D55FF),
                  Color(0xFF4A90E2)
                ], // Gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null, // No gradient for other dates
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 24,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Build home page
  Widget buildHomePage() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(now);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for Today and Add Subject Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 25,
                          color: const Color.fromRGBO(90, 90, 90, 1.0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 27,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // Add Subject Button
                  Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2D55FF),
                          Color(0xFF4A90E2)
                        ], // Gradient color
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return buildAddSubjectDialog();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // The background color here won't be used since we're using the Container's gradient
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Container(
                        child: Text(
                          "+ Add Sub",
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Date containers (Scrollable horizontally if needed)
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: buildDateContainer(
                        DateTime.now().add(Duration(days: index)),
                        DateTime.now().day ==
                                DateTime.now().add(Duration(days: index)).day &&
                            DateTime.now().month ==
                                DateTime.now()
                                    .add(Duration(days: index))
                                    .month &&
                            DateTime.now().year ==
                                DateTime.now().add(Duration(days: index)).year,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),
              // Today's Notes
              ExpansionTile(
                shape: const Border(),
                title: Text(
                  "Today's Subjects",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                children: notes
                    .where((note) => note['days'].contains(now.weekday - 1))
                    .map((note) {
                  return buildNoteCard(note);
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Other Subjects
              ExpansionTile(
                shape: const Border(),
                title: Text(
                  "Other Subjects",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                children: notes
                    .where((note) => !note['days'].contains(now.weekday - 1))
                    .map((note) {
                  return buildNoteCard(note);
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Build note card
  Widget buildNoteCard(Map<String, dynamic> note) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      // Reduced padding
      width: double.infinity,
      height: 110,
      // Keep the height fixed
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D55FF), Color(0xFF4A90E2)], // Smooth gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Section: Subject Name & Attendance Counters
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 15), // Reduced padding
                child: Text(
                  note['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8), // Reduced space

              // Attendance Counters
              Row(
                children: [
                  attendanceCounter(
                      "Present", note, 'presentCount', Colors.green),
                  SizedBox(width: 10), // Reduced space
                  Container(
                      width: 2,
                      height: 35,
                      color: Colors.white54), // Reduced height
                  SizedBox(width: 10), // Reduced space
                  attendanceCounter("Absent", note, 'absentCount', Colors.red),
                ],
              ),
            ],
          ),
          // Right Section: Delete Button
          GestureDetector(
              onTap: () {
                setState(() {
                  notes.remove(note);
                });
                saveNotes();
              },
              child: Material(
                color: Colors.transparent,
                // Keep the background transparent so it doesn't override CircleAvatar color
                shape: CircleBorder(),
                // Keep the circle shape
                child: InkWell(
                  onTap: () {
                    setState(() {
                      notes.remove(note);
                    });
                    saveNotes();
                  },
                  highlightColor: Colors.black26,
                  borderRadius: BorderRadius.circular(25),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
                    child: Icon(Icons.delete_outline,
                        color: Colors.black, size: 31),
                  ),
                ),
              ))
        ],
      ),
    );
  }

// Custom Widget for Attendance Counter
  Widget attendanceCounter(
      String label, Map<String, dynamic> note, String key, Color color) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  note[key] += 1;
                });
                saveNotes();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.8),
                ),
                padding: EdgeInsets.all(5), // Reduced padding
                child: Icon(Icons.add,
                    color: Colors.white, size: 14), // Reduced icon size
              ),
            ),
            SizedBox(width: 6), // Reduced space
            Text(
              '${note[key]}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Reduced font size
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6), // Reduced space
            GestureDetector(
              onTap: () {
                setState(() {
                  if (note[key] > 0) note[key] -= 1;
                });
                saveNotes();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                ),
                padding: EdgeInsets.all(5), // Reduced padding
                child: Icon(Icons.remove,
                    color: Colors.black, size: 14), // Reduced icon size
              ),
            ),
          ],
        ),
        SizedBox(height: 4), // Reduced space
        Text(
          label,
          style: TextStyle(
              color: Colors.white70, fontSize: 12), // Reduced font size
        ),
      ],
    );
  }

  // Build second page
  Widget buildSecondPage() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(now);

    // Function to calculate individual attendance
    double calculateIndividualAttendance(Map<String, dynamic> note) {
      int presentDays = note['presentCount'];
      int totalDays = note['presentCount'] + note['absentCount'];

      if (totalDays == 0) return 0.0; // Avoid division by zero
      return (presentDays / totalDays) * 100;
    }

    return SingleChildScrollView(
      // Wrap the entire content in a scroll view
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Today and Add Subject Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 25,
                        color: const Color.fromRGBO(90, 90, 90, 1.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 27,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Overall Attendance',
                      style: TextStyle(
                        fontSize: 22,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
            // Pie Chart and Legend
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart (Centered horizontally)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        buildPieChart(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                    width: 15), // Reduced spacing between chart and legends
              ],
            ),
            const SizedBox(height: 20),
            // Individual subject attendance list
            Text(
              "Individual Subject Attendance",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Wrap the individual notes in SingleChildScrollView to make them scrollable
            Column(
              children: notes.map((note) {
                double individualAttendance =
                    calculateIndividualAttendance(note);

                // Dynamic Color Gradient Based on Attendance Percentage
                Color startColor =
                    individualAttendance < 40 ? Colors.red : Colors.green;
                Color endColor = individualAttendance < 40
                    ? Colors.deepOrange
                    : Colors.lightGreen;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        startColor.withOpacity(0.9),
                        endColor.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(3, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Subject Name
                      Expanded(
                        child: Text(
                          note['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Attendance Percentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${individualAttendance.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  // Add subject dialog
  Widget buildAddSubjectDialog() {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900] // Dark mode background
            : Colors.white,
        title: Text(
          "Add Subject",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter subject name",
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // Dark mode input field
                          : Colors.grey[200],
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    onChanged: (text) {
                      setState(() {
                        noteSubject = text;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Days:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: List.generate(6, (index) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedDays[index],
                            onChanged: (value) {
                              setState(() {
                                selectedDays[index] = value!;
                              });
                            },
                            activeColor: Colors.blue,
                            checkColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                          ),
                          Text(
                            DateFormat('EEE').format(DateTime(2022, 1, 3)
                                .add(Duration(days: index))),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              List<int> selectedWeekdays = [];
              for (int i = 0; i < 6; i++) {
                if (selectedDays[i]) selectedWeekdays.add(i);
              }
              if (selectedWeekdays.isNotEmpty && noteSubject.isNotEmpty) {
                final newNote = {
                  'name': noteSubject,
                  'days': selectedWeekdays,
                  'attendance': 'None',
                  'presentCount': 0,
                  'absentCount': 0,
                };
                addNote(
                    newNote); // Calls the addNote function to add the new note
                Navigator.of(context).pop(); // Close the dialog
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(45, 85, 255, 1.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ]);
  }
}

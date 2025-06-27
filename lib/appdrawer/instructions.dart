import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use the App'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Add Your Subjects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '• Tap the "+ Add Sub" button on the Home screen.\n'
              '• Type the subject name.\n'
              '• Choose the days when you have this subject.\n'
              '• Tap "Save".',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Mark Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '• On the Home screen, you’ll see today’s subjects.\n'
              '• Tap + if you were Present for the class.\n'
              '• Tap - if you were Absent for the class.\n'
              '• To correct spelling or days of a subject, tap the subject name to edit.\n'
              '• Use the "Include/Skip" toggle:\n'
              '   - *Included*: Subject affects attendance %.\n'
              '   - *Skipped*: Subject is ignored in the overall %.\n'
              '   - Useful for uncertain subjects like mentoring.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Pie Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '• The Pie Chart will show your overall attendance from beginning.\n'
              '• Below it, you’ll see attendance for each subject (try to keep it above 40%).\n'
              '• Tap the Pie Chart to edit subject attendance manually.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '15 Days Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '• Shows attendance logs for the last 15 days.\n'
              '• Logs are saved only when at least one subject is included.\n'
              '• Use "Clear Logs" to delete all logs, once deleted cannot be recovered.\n'
              '• Turn on "Is Today a Holiday?" to skip today\'s log.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Upload/View Timetable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '• You can upload a screenshot of your timetable for your convenience, it will be displayed in the app.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Developer\'s Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hello everyone, this app was made by me so you can track your individual attendance instead of waiting for official updates.\n\n'
              'I hope this app is helpful to you all. This is my first app, so any feedback or bug reports are truly appreciated.\n\n'
              'If you find any issue or want to share suggestions, please email me at: luckymi11lite@gmail.com\n\n'
              'Thank you in advance, and I hope this app works well for you. Feel free to share it with your friends too!\n\n'
              'Peace ✌️',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

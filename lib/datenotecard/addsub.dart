import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apptest2024/appdrawer/logs/logshelper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddSubjectDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) addNote;
  final bool isDarkMode;
  final BuildContext parentContext;
  final Map<String, dynamic>? existingNote;
  final Function(Map<String, dynamic>)? onUpdate;

  const AddSubjectDialog({
    Key? key,
    required this.addNote,
    required this.isDarkMode,
    required this.parentContext,
    this.existingNote,
    this.onUpdate,
  }) : super(key: key);

  @override
  _AddSubjectDialogState createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  late String noteSubject;
  late List<bool> selectedDays;

  /*final List<String> weekdayNames = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];*/

  @override
  void initState() {
    super.initState();
    noteSubject = widget.existingNote?['name'] ?? '';
    selectedDays = List.generate(
      7,
      (index) =>
          widget.existingNote != null &&
          (widget.existingNote!['days'] as List).contains(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      title: Text(
        widget.existingNote != null ? "Edit Subject" : "Add Subject",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: noteSubject),
              onChanged: (text) => noteSubject = text,
              decoration: InputDecoration(
                hintText: "Enter subject name",
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor:
                    widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Days:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(7, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: selectedDays[index],
                      onChanged: (value) {
                        setState(() {
                          selectedDays[index] = value ?? false;
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor:
                          widget.isDarkMode ? Colors.black : Colors.white,
                    ),
                    Text(
                      DateFormat('EEE').format(DateTime(2024, 6, 23 + index)),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            List<int> selectedWeekdays = [];
            for (int i = 0; i < 7; i++) {
              if (selectedDays[i]) selectedWeekdays.add(i);
            }

            if (noteSubject.isEmpty) {
              showErrorSnackBar(
                  widget.parentContext, 'Please enter a subject name');
              return;
            }

            if (selectedWeekdays.isEmpty) {
              showErrorSnackBar(
                  widget.parentContext, 'Please select at least one day');
              return;
            }

            final updatedNote = {
              'name': noteSubject,
              'days': selectedWeekdays,
              'attendance': widget.existingNote?['attendance'] ?? 'None',
              'presentCount': widget.existingNote?['presentCount'] ?? 0,
              'absentCount': widget.existingNote?['absentCount'] ?? 0,
              'isIncluded': widget.existingNote?['isIncluded'] ?? true,
            };

            final prefs = await SharedPreferences.getInstance();
            List<Map<String, dynamic>> notes = [];

            final notesString = prefs.getString('notes');
            if (notesString != null) {
              notes = List<Map<String, dynamic>>.from(jsonDecode(notesString));
            }
            if (widget.existingNote != null && widget.onUpdate != null) {
              final index = notes
                  .indexWhere((n) => n['name'] == widget.existingNote!['name']);
              if (index != -1) {
                notes[index] = updatedNote;
              }
              widget.onUpdate!(updatedNote);
            } else {
              notes.add(updatedNote);
              widget.addNote(updatedNote);
              setLogStartDateIfNeeded();
            }
            await prefs.setString('notes', jsonEncode(notes));
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(45, 85, 255, 1.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            widget.existingNote != null ? "Update" : "Add",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

void showAnimatedAddSubjectDialog({
  required BuildContext context,
  required Function(Map<String, dynamic>) addNote,
  required bool isDarkMode,
  required BuildContext parentContext,
  Map<String, dynamic>? existingNote,
  Function(Map<String, dynamic>)? onUpdate,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: AddSubjectDialog(
          addNote: addNote,
          isDarkMode: isDarkMode,
          parentContext: parentContext,
          existingNote: existingNote,
          onUpdate: onUpdate,
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: curvedAnimation,
        child: child,
      );
    },
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.redAccent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
    ),
  );
}

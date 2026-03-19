import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../datenotecard/notecard.dart';
import '../datenotecard/datelist.dart';
import '../datenotecard/addsub.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final bool isDarkMode;
  final Function(Map<String, dynamic>) addNote;
  final Future<void> Function() saveNotes;
  final bool isHolidayMode;
  final double Function(List<Map<String, dynamic>>) calculateOverallAttendance;
  final Future<void> Function(double) updateTodayLogFromAttendance;
  final Future<void> Function() loadLogs;
  final Future<void> Function(
      List<Map<String, dynamic>> notes,
      bool isHolidayMode,
      double Function(List<Map<String, dynamic>>) calculateOverallAttendance,
      Future<void> Function(double) updateTodayLogFromAttendance,
      Future<void> Function()) recalculateTodayLogIfNeeded;
  final bool resetVisualCounters;
  final Future<bool> Function() checkResetVisualCounters;

  const HomePage({
    required this.notes,
    required this.isDarkMode,
    required this.addNote,
    required this.saveNotes,
    required this.recalculateTodayLogIfNeeded,
    required this.isHolidayMode,
    required this.calculateOverallAttendance,
    required this.updateTodayLogFromAttendance,
    required this.loadLogs,
    required this.resetVisualCounters,
    required this.checkResetVisualCounters,
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.checkResetVisualCounters().then((shouldReset) {
      if (shouldReset) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.checkResetVisualCounters().then((shouldReset) {
        if (shouldReset) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.isDarkMode;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(now);
    bool isTodayExpanded = true;
    bool isOtherExpanded = false;
    int todayIndex = DateTime.now().weekday % 7;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 120,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2D55FF), Color(0xFF4A90E2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                showAnimatedAddSubjectDialog(
                                  context: context,
                                  isDarkMode: isDarkMode,
                                  parentContext: context,
                                  addNote: (newNote) {
                                    widget.addNote(newNote);
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: const Text(
                                "+ Add Sub",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: List.generate(5, (index) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: buildDateContainer(
                                DateTime.now().add(Duration(days: index)),
                                DateTime.now().day ==
                                        DateTime.now()
                                            .add(Duration(days: index))
                                            .day &&
                                    DateTime.now().month ==
                                        DateTime.now()
                                            .add(Duration(days: index))
                                            .month &&
                                    DateTime.now().year ==
                                        DateTime.now()
                                            .add(Duration(days: index))
                                            .year,
                                isDarkMode,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      ExpansionTile(
                        key: const PageStorageKey<String>(
                            'today_expansion_tile'),
                        initiallyExpanded: isTodayExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            isTodayExpanded = expanded;
                          });
                        },
                        title: Text(
                          "Today's Subjects",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        children: widget.notes
                            .where((note) => note['days'].contains(todayIndex))
                            .map((note) => buildNoteCard(note))
                            .toList(),
                      ),
                      ExpansionTile(
                        key: const PageStorageKey<String>(
                            'other_expansion_tile'),
                        initiallyExpanded: isOtherExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            isOtherExpanded = expanded;
                          });
                        },
                        title: Text(
                          "Other Subjects",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        children: widget.notes
                            .where((note) => !note['days'].contains(todayIndex))
                            .map((note) => buildNoteCard(note))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoteCard(Map<String, dynamic> note) {
    int visualPresent = widget.resetVisualCounters ? 0 : note['presentCount'];
    int visualAbsent = widget.resetVisualCounters ? 0 : note['absentCount'];

    return NoteCard(
      note: note,
      visualPresent: visualPresent,
      visualAbsent: visualAbsent,
      key: ValueKey(note['name']),
      onDelete: () async {
        widget.notes.remove(note);
        await widget.saveNotes();
        await widget.recalculateTodayLogIfNeeded(
          widget.notes,
          widget.isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        setState(() {});
      },
      onIncrementPresent: () async {
        note['presentCount']++;
        note['attendance'] = 'Present';
        await widget.saveNotes();
        await widget.recalculateTodayLogIfNeeded(
          widget.notes,
          widget.isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        setState(() {});
      },
      onDecrementPresent: () async {
        if (note['presentCount'] > 0) note['presentCount']--;
        await widget.saveNotes();
        await widget.recalculateTodayLogIfNeeded(
          widget.notes,
          widget.isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        setState(() {});
      },
      onIncrementAbsent: () async {
        note['absentCount']++;
        note['attendance'] = 'Absent';
        await widget.saveNotes();
        await widget.recalculateTodayLogIfNeeded(
          widget.notes,
          widget.isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        setState(() {});
      },
      onDecrementAbsent: () async {
        if (note['absentCount'] > 0) note['absentCount']--;
        await widget.saveNotes();
        await widget.recalculateTodayLogIfNeeded(
          widget.notes,
          widget.isHolidayMode,
          widget.calculateOverallAttendance,
          widget.updateTodayLogFromAttendance,
          widget.loadLogs,
        );
        setState(() {});
      },
      onEdit: () {
        showAnimatedAddSubjectDialog(
          context: context,
          isDarkMode: widget.isDarkMode,
          parentContext: context,
          existingNote: note,
          onUpdate: (updatedNote) async {
            final index = widget.notes.indexOf(note);
            if (index != -1) {
              widget.notes[index] = updatedNote;
              await widget.saveNotes();
              await widget.recalculateTodayLogIfNeeded(
                widget.notes,
                widget.isHolidayMode,
                widget.calculateOverallAttendance,
                widget.updateTodayLogFromAttendance,
                widget.loadLogs,
              );
              setState(() {});
            }
          },
          addNote: (_) {},
        );
      },
      onToggleIncluded: () async {
        final index = widget.notes.indexOf(note);
        final toggled = !(note['isIncluded'] ?? true);
        if (index != -1) {
          widget.notes[index] = {
            ...widget.notes[index],
            'isIncluded': toggled,
          };
          await widget.saveNotes();
          await widget.recalculateTodayLogIfNeeded(
            widget.notes,
            widget.isHolidayMode,
            widget.calculateOverallAttendance,
            widget.updateTodayLogFromAttendance,
            widget.loadLogs,
          );
          setState(() {});
        }
      },
    );
  }
}

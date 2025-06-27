import 'package:flutter/material.dart';

class SubjectAttendanceEditPage extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const SubjectAttendanceEditPage({
    Key? key,
    required this.notes,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _SubjectAttendanceEditPageState createState() =>
      _SubjectAttendanceEditPageState();
}

class _SubjectAttendanceEditPageState extends State<SubjectAttendanceEditPage> {
  late List<Map<String, dynamic>> updatedNotes;
  late List<TextEditingController> presentControllers;
  late List<TextEditingController> totalControllers;

  @override
  void initState() {
    super.initState();
    updatedNotes = List<Map<String, dynamic>>.from(widget.notes);

    presentControllers = List.generate(
      updatedNotes.length,
      (index) => TextEditingController(
          text: updatedNotes[index]['presentCount'].toString()),
    );

    totalControllers = List.generate(
      updatedNotes.length,
      (index) {
        final note = updatedNotes[index];
        final total = (note['presentCount'] ?? 0) + (note['absentCount'] ?? 0);
        return TextEditingController(text: total.toString());
      },
    );
  }

  void _updateCounts(int index, String presentStr, String totalStr) {
    final present = int.tryParse(presentStr) ?? 0;
    final total = int.tryParse(totalStr) ?? 0;
    final absent = (total - present).clamp(0, total);

    setState(() {
      updatedNotes[index]['presentCount'] = present;
      updatedNotes[index]['absentCount'] = absent;
    });
  }

  @override
  void dispose() {
    for (var controller in presentControllers) {
      controller.dispose();
    }
    for (var controller in totalControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Edit Subject Attendance',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, updatedNotes); // Save and go back
            },
          ),
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView.builder(
        itemCount: updatedNotes.length,
        itemBuilder: (context, index) {
          final note = updatedNotes[index];
          final presentController = presentControllers[index];
          final totalController = totalControllers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Card(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['name'] ?? 'Unnamed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: presentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Attended',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _updateCounts(
                                index, value, totalController.text),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: totalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total Classes',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _updateCounts(
                                index, presentController.text, value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

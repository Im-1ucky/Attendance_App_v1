import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SecondPage extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> notes;
  final Widget Function(BuildContext, List<Map<String, dynamic>>) buildPieChart;

  SecondPage({
    required this.isDarkMode,
    required this.notes,
    required this.buildPieChart,
  });

  double calculateIndividualAttendance(Map<String, dynamic> note) {
    int presentDays = note['presentCount'];
    int totalDays = note['presentCount'] + note['absentCount'];
    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(now);

    return Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
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
                            buildPieChart(context, notes),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 15), // Reduced spacing between chart and legends
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Individual Subject Attendance",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: notes.map((note) {
                    double individualAttendance =
                        calculateIndividualAttendance(note);
                    Color startColor =
                        individualAttendance < 40 ? Colors.red : Colors.green;
                    Color endColor = individualAttendance < 40
                        ? Colors.deepOrange
                        : Colors.lightGreen;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
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
                          Expanded(
                            child: Text(
                              note['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                ),
              ],
            ),
          ),
        ));
  }
}

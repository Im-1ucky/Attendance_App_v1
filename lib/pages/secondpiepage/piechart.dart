import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'pieedit.dart';

class AttendancePieChart extends StatelessWidget {
  final double overallAttendance;
  final List<Map<String, dynamic>> notes;
  final Future<void> Function() saveNotes;
  final Future<void> Function(
    List<Map<String, dynamic>> notes,
    bool isHolidayMode,
    double Function(List<Map<String, dynamic>>) calculateOverallAttendance,
    Future<void> Function(double) updateTodayLogFromAttendance,
    Future<void> Function() loadLogs,
  ) recalculateTodayLogIfNeeded;
  final bool isHolidayMode;
  final double Function(List<Map<String, dynamic>>) calculateOverallAttendance;
  final Future<void> Function(double) updateTodayLogFromAttendance;
  final Future<void> Function() loadLogs;

  const AttendancePieChart({
    super.key,
    required this.overallAttendance,
    required this.notes,
    required this.saveNotes,
    required this.recalculateTodayLogIfNeeded,
    required this.isHolidayMode,
    required this.calculateOverallAttendance,
    required this.updateTodayLogFromAttendance,
    required this.loadLogs,
  });

  @override
  Widget build(BuildContext context) {
    Color startColor;
    Color endColor;

    if (overallAttendance < 65) {
      startColor = Colors.red;
      endColor = Colors.deepOrange;
    } else if (overallAttendance >= 65 && overallAttendance < 75) {
      startColor = const Color(0xFFFFA500);
      endColor = const Color(0xFFFFC107);
    } else {
      startColor = Colors.green;
      endColor = Colors.green;
    }

    return GestureDetector(
      onTap: () async {
        final updatedNotes = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectAttendanceEditPage(
              notes: notes,
              onUpdate: (newNotes) {
                // This is called when Save is pressed inside SubjectAttendanceEditPage
                notes.clear();
                notes.addAll(newNotes);
              },
            ),
          ),
        );
        if (updatedNotes != null) {
          await saveNotes(); // save the updated notes list
          // Pass all required parameters here:
          await recalculateTodayLogIfNeeded(
            notes,
            isHolidayMode,
            calculateOverallAttendance,
            updateTodayLogFromAttendance,
            loadLogs,
          );
          await loadLogs(); // refresh logs after recalculation
        }
      },
      child: Container(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          height: 210,
          width: 300,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: SfRadialGauge(axes: [
            RadialAxis(
              radiusFactor: 0.99,
              axisLineStyle: AxisLineStyle(
                thickness: 35,
                color: Colors.grey.shade200,
              ),
              pointers: [
                RangePointer(
                  value: overallAttendance,
                  gradient: SweepGradient(
                    colors: [startColor, endColor],
                    startAngle: 0.0,
                    endAngle: 1.0,
                  ),
                  width: 35,
                  animationType: AnimationType.ease,
                  enableAnimation: true,
                  animationDuration: 500,
                  cornerStyle: (overallAttendance == 100)
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
                    '${overallAttendance.toStringAsFixed(1)}%',
                    style: const TextStyle(
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
      ),
    );
  }
}

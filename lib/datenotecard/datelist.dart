import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildDateContainer(DateTime date, bool isToday, bool isDarkMode) {
  Color textColor =
      isToday ? Colors.white : (isDarkMode ? Colors.white : Colors.black);

  return Container(
    width: 66,
    height: 90,
    decoration: BoxDecoration(
      gradient: isToday
          ? const LinearGradient(
              colors: [Color(0xFF2D55FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
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

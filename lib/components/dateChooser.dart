import 'package:flutter/material.dart';

class DateTimeChooser extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onDateTimeSelected;
  final DateTime? firstDate;

  const DateTimeChooser({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeSelected,
    this.firstDate,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime initialDate = selectedDateTime != null
        ? (selectedDateTime!.isBefore(firstDate ?? DateTime.now())
              ? (firstDate ?? DateTime.now())
              : selectedDateTime!)
        : (firstDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF7A30),
              onPrimary: Colors.white,
              onSurface: const Color(0xFFFF7A30),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF7A30),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay initialTime = selectedDateTime != null
        ? TimeOfDay(
            hour: selectedDateTime!.hour,
            minute: selectedDateTime!.minute,
          )
        : TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteColor: const Color(0xFFFF7A30),
              hourMinuteTextColor: Colors.black,
              dayPeriodColor: const Color(0xFFFF7A30),
              dayPeriodTextColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF7A30),
              onPrimary: Colors.white,
              onSurface: const Color(0xFFFF7A30),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onDateTimeSelected(combined);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDateTime == null
                  ? "Choose date & time"
                  : "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} "
                        "${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}",
            ),
            const Icon(Icons.calendar_today, color: Color(0xFFFF7A30)),
          ],
        ),
      ),
    );
  }
}

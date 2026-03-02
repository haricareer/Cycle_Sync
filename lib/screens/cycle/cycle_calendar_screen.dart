import 'package:cycle_sync/screens/cycle/cycle_input_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cycle_model.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/cycle_calculator.dart';

class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cycle Calendar")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _monthHeader(),
            const SizedBox(height: 12),
            _weekDaysRow(),
            const SizedBox(height: 8),
            _calendarGrid(),
            const SizedBox(height: 20),
            _selectedDateInfo(),
          ],
        ),
      ),
    );
  }

  // ---------------- MONTH HEADER ----------------
  Widget _monthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            });
          },
        ),
        Text(
          "${_monthName(_focusedMonth.month)} ${_focusedMonth.year}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  // ---------------- WEEK DAYS ----------------
  Widget _weekDaysRow() {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------- CALENDAR GRID ----------------
  Widget _calendarGrid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Expanded(child: Center(child: Text("Please log in")));
    }

    return StreamBuilder<List<CycleModel>>(
      stream: FirestoreService().streamCycles(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final cycles = snapshot.data ?? [];
        final Set<String> periodDays = {};
        final Set<String> ovulationDays = {};

        int avgCycleLength = CycleCalculator.calculateAverageCycleLength(
          cycles,
        );

        for (var cycle in cycles) {
          final start = DateTime(
            cycle.startDate.year,
            cycle.startDate.month,
            cycle.startDate.day,
          );
          final end = cycle.endDate != null
              ? DateTime(
                  cycle.endDate!.year,
                  cycle.endDate!.month,
                  cycle.endDate!.day,
                )
              : start;

          final days = end.difference(start).inDays;
          for (int i = 0; i <= days; i++) {
            final periodDay = start.add(Duration(days: i));
            periodDays.add(
              "${periodDay.year}-${periodDay.month}-${periodDay.day}",
            );
          }

          final ovulationDay = CycleCalculator.predictOvulation(
            start,
            avgCycleLength,
          );
          final fertileWindow = CycleCalculator.getFertilityWindow(
            ovulationDay,
          );

          final fertileStart = fertileWindow['start']!;
          final fertileEnd = fertileWindow['end']!;

          final fertileDays = fertileEnd.difference(fertileStart).inDays;
          for (int i = 0; i <= fertileDays; i++) {
            final ovuDay = fertileStart.add(Duration(days: i));
            ovulationDays.add("${ovuDay.year}-${ovuDay.month}-${ovuDay.day}");
          }
        }

        final firstDayOfMonth = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          1,
        );
        final daysInMonth = DateTime(
          _focusedMonth.year,
          _focusedMonth.month + 1,
          0,
        ).day;
        final startWeekday = firstDayOfMonth.weekday % 7;

        final totalCells = daysInMonth + startWeekday;

        return Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }

              final day = index - startWeekday + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final dateKey = "${date.year}-${date.month}-${date.day}";

              final isSelected =
                  _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              final isCycleDay = periodDays.contains(dateKey);
              final isOvulationDay =
                  ovulationDays.contains(dateKey) && !isCycleDay;

              Widget cell = GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedDate = date;
                  });

                  if (!isCycleDay && !isOvulationDay) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CycleInputScreen(selectedDate: _selectedDate),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isCycleDay
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : isOvulationDay
                        ? Colors.purple.withValues(alpha: 0.2)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isCycleDay
                          ? AppColors.primary
                          : isOvulationDay
                          ? Colors.purple
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : isCycleDay
                            ? AppColors.primary
                            : isOvulationDay
                            ? Colors.purple
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );

              if (isCycleDay || isOvulationDay) {
                cell = Tooltip(
                  message: isCycleDay ? "Period Day" : "Ovulation Window",
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  child: cell,
                );
              }

              return cell;
            },
          ),
        );
      },
    );
  }

  // ---------------- SELECTED DATE INFO ----------------
  Widget _selectedDateInfo() {
    if (_selectedDate == null) {
      return const Text(
        "Tap a date to log or view cycle details",
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        "Selected Date: ${_selectedDate!.day} "
        "${_monthName(_selectedDate!.month)} "
        "${_selectedDate!.year}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ---------------- MONTH NAME ----------------
  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}

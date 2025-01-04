import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../shared/themes/styles.dart';
import '../views/widgets/calendar_widget.dart';
import '../views/widgets/task_list.dart';
import '/shared/widgets/bottom_navigation.dart';
import '../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late List<Map<String, dynamic>> _tasks;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL');
    _tasks = TaskService.getTasks(); // Pobranie danych z serwisu
  }

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDay = TaskService.getTasksForDay(_tasks, _selectedDay);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Filter overlay
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Main screen content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Calendar widget
                CalendarWidget(
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                // Divider
                Container(
                  color: AppStyles.transparentWhite,
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                // Task list
                Expanded(
                  child: TaskList(
                    selectedDay: _selectedDay,
                    tasks: tasksForSelectedDay,
                  ),
                ),
                // Bottom Navigation
                BottomNavigation(
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';
import '../widgets/task_item.dart';

class ConstructionCalendarScreen extends StatefulWidget {
  const ConstructionCalendarScreen({super.key});

  @override
  _ConstructionCalendarScreenState createState() =>
      _ConstructionCalendarScreenState();
}

class _ConstructionCalendarScreenState
    extends State<ConstructionCalendarScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  // List of tasks
  final List<Map<String, dynamic>> _tasks = [
    {
      "id": 0,
      "name": "Piwo materiałów",
      "message": "Kurier przywiezie materiały na budowę.",
      "startTime": DateTime.parse("2024-12-02T10:00:00.000Z"),
      "endTime": DateTime.parse("2024-12-04T18:00:00.000Z"),
      "allDay": true,
      "placeId": 1,
    },
    {
      "id": 1,
      "name": "Szpachlowanie gładzi",
      "message": "Szpachlowanie ścian w salonie.",
      "startTime": DateTime.parse("2024-12-03T08:00:00.000Z"),
      "endTime": DateTime.parse("2024-12-03T12:00:00.000Z"),
      "allDay": false,
      "placeId": 1,
    },
    {
      "id": 2,
      "name": "Montaż płyt",
      "message": "Montaż płyt meblowych w kuchni.",
      "startTime": DateTime.parse("2024-12-04T14:00:00.000Z"),
      "endTime": DateTime.parse("2024-12-04T16:00:00.000Z"),
      "allDay": false,
      "placeId": 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL');
    _selectedDay = DateTime.now();
    appState.currentPage = 'calendar'; // Set the current page to calendar
  }

  // Get tasks for the selected day and sort by start time
  List<Map<String, dynamic>> _getSortedTasksForSelectedDay() {
    final tasksForDay = _tasks.where((task) {
      final start = task['startTime'] as DateTime;
      final end = task['endTime'] as DateTime;
      return _selectedDay != null &&
          _selectedDay!.isAfter(start.subtract(const Duration(days: 1))) &&
          _selectedDay!.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    // Sort tasks by start time
    tasksForDay.sort((a, b) => (a['startTime'] as DateTime)
        .compareTo(b['startTime'] as DateTime));

    return tasksForDay;
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasksForSelectedDay = _getSortedTasksForSelectedDay();

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
                // Calendar
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: AppStyles.transparentWhite,
                  child: TableCalendar(
                    locale: 'pl_PL',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: '',
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle:
                          TextStyle(color: Colors.black, fontSize: 12),
                      weekendTextStyle:
                          TextStyle(color: Colors.black, fontSize: 12),
                      outsideTextStyle:
                          TextStyle(color: Colors.grey, fontSize: 12),
                      todayTextStyle:
                          TextStyle(color: Colors.white, fontSize: 12),
                      selectedTextStyle:
                          TextStyle(color: Colors.white, fontSize: 12),
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: true,
                    ),
                    daysOfWeekHeight: 20.0,
                    rowHeight: 28.0,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 10),
                      weekendStyle: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                // Divider
                Container(
                  color: AppStyles.transparentWhite,
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                // Task section
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zadania na: ${DateFormat('dd.MM.yyyy', 'pl_PL').format(_selectedDay!)}',
                          style: AppStyles.headerStyle,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: sortedTasksForSelectedDay.isEmpty
                              ? const Center(child: Text('Brak zadań na ten dzień.'))
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: sortedTasksForSelectedDay.length,
                                  itemBuilder: (context, index) {
                                    final task = sortedTasksForSelectedDay[index];
                                    return TaskItem(
                                      title: task['name'],
                                      description: task['message'],
                                      startTime: DateFormat('HH:mm')
                                          .format(task['startTime']),
                                      endTime: DateFormat('HH:mm')
                                          .format(task['endTime']),
                                      createdBy: 'System', // Placeholder
                                      taskDate: DateFormat('dd.MM.yyyy')
                                          .format(task['startTime']),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
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

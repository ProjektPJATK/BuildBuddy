import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/calendar/views/widgets/task_item.dart';
import 'package:mobile/features/construction_calendar/services/calendar_service,dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task_model.dart';



class ConstructionCalendarScreen extends StatefulWidget {
  const ConstructionCalendarScreen({super.key});

  @override
  _ConstructionCalendarScreenState createState() => _ConstructionCalendarScreenState();
}

class _ConstructionCalendarScreenState extends State<ConstructionCalendarScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _selectedDay = DateTime.now();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await CalendarService.fetchTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load tasks')));
    }
  }

  List<TaskModel> _getTasksForSelectedDay() {
    return _tasks.where((task) {
      return isSameDay(task.startTime, _selectedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDay = _getTasksForSelectedDay();

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                color: AppStyles.transparentWhite,
                child: TableCalendar(
                  locale: 'pl_PL',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : tasksForSelectedDay.isEmpty
                        ? const Center(child: Text('No tasks for this day'))
                        : ListView.builder(
                            itemCount: tasksForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final task = tasksForSelectedDay[index];
                              return TaskItem(
                                title: task.name,
                                description: task.message,
                                startTime: DateFormat('HH:mm').format(task.startTime),
                                endTime: DateFormat('HH:mm').format(task.endTime),
                                taskDate: DateFormat('dd.MM.yyyy').format(task.startTime),
                              );
                            },
                          ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}

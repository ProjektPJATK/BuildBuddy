import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';
import '../widgets/task_item.dart';  // Import TaskItem

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL');
    _selectedDay = DateTime.now();
    appState.currentPage = 'calendar'; // Ustawiamy aktualną stronę na kalendarz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło całej strony
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Filtr dla całej strony
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Zawartość ekranu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Kalendarz
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: AppStyles.transparentWhite, // Jasne tło z przezroczystością dla kalendarza
                  child: TableCalendar(
                    locale: 'pl_PL',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month, // Stały widok kalendarza
                    availableCalendarFormats: const {
                      CalendarFormat.month: '',
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false, // Ukrycie przycisku zmiany widoku
                      titleCentered: true, // Wyśrodkowanie tytułu
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
                      defaultTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12, // Zmniejszamy czcionkę dla dni
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12, // Zmniejszamy czcionkę dla weekendów
                      ),
                      outsideTextStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 12, // Zmniejszamy czcionkę dla dni spoza miesiąca
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white, // Kolor tekstu dla dzisiejszego dnia
                        fontSize: 12, // Dopasowujemy rozmiar czcionki
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white, // Kolor tekstu dla wybranego dnia
                        fontSize: 12, // Dopasowujemy rozmiar czcionki
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle, // Kółko dla dzisiejszego dnia
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle, // Kółko dla wybranego dnia
                      ),
                      outsideDaysVisible: true, // Pokazywanie dni spoza miesiąca
                    ),
                    daysOfWeekHeight: 20.0,
                    rowHeight: 28.0,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontSize: 10, // Czcionka dla dni tygodnia
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 10, // Czcionka dla weekendów
                      ),
                    ),
                  ),
                ),
                // Divider między kalendarzem a sekcją z zadaniami
                Container(
                  color: AppStyles.transparentWhite, // Tło sekcji zgodne z innymi stronami
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                // Sekcja z zadaniami
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite, // Białe tło z przezroczystością dla zadań
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zadania na: ${DateFormat('dd.MM.yyyy', 'pl_PL').format(_selectedDay!)}',
                          style: AppStyles.headerStyle,
                        ),
                        const SizedBox(height: 8), // Odstęp
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              TaskItem(
                                title: 'Kurier przywiezie płytki',
                                description: 'Płytki dotrą na budowę.',
                                startTime: '10:00 AM',
                                endTime: '11:00 AM',
                                createdBy: 'Jan Kowalski',
                                taskDate: '12.09.2023',
                              ),
                              TaskItem(
                                title: 'Szpachlowanie gładzi',
                                description: 'Szpachlowanie ścian w salonie.',
                                startTime: '12:00 PM',
                                endTime: '02:00 PM',
                                createdBy: 'Anna Wiśniewska',
                                taskDate: '13.09.2023',
                              ),
                              TaskItem(
                                title: 'Montaż płyt meblowych',
                                description: 'Montaż nowych płyt w kuchni.',
                                startTime: '03:00 PM',
                                endTime: '04:30 PM',
                                createdBy: 'Piotr Malinowski',
                                taskDate: '14.09.2023',
                              ),
                            ],
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

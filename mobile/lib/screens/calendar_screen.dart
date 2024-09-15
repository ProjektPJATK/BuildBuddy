import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/bottom_navigation.dart'; // Importujemy nasz dolny widget nawigacyjny
import '../app_state.dart' as appState; // Importujemy zmienną globalną

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ustawienie lokalizacji na polską
    initializeDateFormatting('pl_PL');
    
    // Ustawienie domyślnego wybranego dnia na dzisiejszy
    _selectedDay = DateTime.now();

    // Ustawienie aktualnej strony na 'calendar'
    appState.currentPage = 'calendar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Użycie tego samego obrazu tła co w HomeScreen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Filtr z przezroczystością
          Container(
            color: Colors.black.withOpacity(0.75), // Czarny filtr
          ),
          // Zawartość ekranu
          Column(
            children: [
              // Kalendarz na górze
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white.withOpacity(0.7), // Jasne tło z przezroczystością
                child: TableCalendar(
                  locale: 'pl_PL',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month, // Ustawienie stałego widoku na miesiąc
                  
                  availableCalendarFormats: const {
                    CalendarFormat.month: '',
                  },

                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerVisible: true,
                  daysOfWeekHeight: 12.0, 
                  rowHeight: 35.0, 
                  
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // Ukrycie przycisku zmiany widoku
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
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.black, fontSize: 14),
                    weekendTextStyle: TextStyle(color: Colors.black, fontSize: 14),
                    outsideTextStyle: TextStyle(color: Colors.grey, fontSize: 14), 
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
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 10),
                    weekendStyle: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              
              // Divider pomiędzy kalendarzem a sekcją z zadaniami z tłem o opacity 0.7
              Container(
                color: Colors.white.withOpacity(0.7),
                child: Divider(
                  color: Colors.white,
                  thickness: 1, 
                ),
              ),

              // Sekcja z zadaniami
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zadania na: ${DateFormat('dd.MM.yyyy', 'pl_PL').format(_selectedDay!)}',
                        style: TextStyle(
                          color: Color.fromARGB(255, 49, 49, 49),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8), 
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            TaskItem('Kurier przywiezie płytki', fontSize: 12),
                            TaskItem('Szpachlowanie gładzi', fontSize: 12),
                            TaskItem('Montaż płyt meblowych', fontSize: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: BottomNavigation(
                onTap: (index) {
                  if (index == 0) {
                    // Strona kalendarza już załadowana, brak akcji
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/chats');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget dla elementu taska
class TaskItem extends StatelessWidget {
  final String title;
  final double fontSize;

  TaskItem(this.title, {this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), 
          borderRadius: BorderRadius.circular(8), 
        ),
        padding: EdgeInsets.all(12), 
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.black), 
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: fontSize, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

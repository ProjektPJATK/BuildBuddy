import 'package:flutter/material.dart';

import '../widgets/build_option.dart';
import '../widgets/notification_item.dart';
import 'profile.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Użyj tego samego obrazu tła
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Filtr
          Container(
            color: Colors.black.withOpacity(0.75), // Czarny filtr
            margin: EdgeInsets.only(top: 20), // Margines dostosowany, aby nie zasłaniał zbyt wiele
          ),
          // Małe logo
          Align(
            alignment: Alignment.topCenter, // Wyśrodkowanie logo
            child: Padding(
              padding: const EdgeInsets.only(top: 30), // Margines od góry
              child: SizedBox(
                width: 45, // Zmniejszone wymiary logo
                height: 45,
                child: Image.asset('assets/logo_small.png'),
              ),
            ),
          ),
          // Zawartość ekranu
          Positioned(
            top: 100, // Margines od góry, aby nie nakładało się na logo
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  flex: 4, // Ustalamy elastyczność sekcji budowy
                  child: Container(
                    padding: const EdgeInsets.all(12.0), // Zmniejszony padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7), // Jasne tło z lekką przezroczystością
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        // Górna część z nagłówkiem i opcjami
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.0), // Zmniejszenie paddingu
                          child: Text(
                            'Wybierz budowę',
                            style: TextStyle(
                              color: Color.fromARGB(255, 49, 49, 49),
                              fontSize: 18, // Zmniejszona czcionka
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero, // Usunięcie domyślnego paddingu ListView
                            children: [
                              // Zmiana na InkWell, który obsługuje kliknięcia
                              InkWell(
                                onTap: () {
                                  // Akcja po kliknięciu
                                  Navigator.pushNamed(context, '/gdansk'); // Przejście na stronę Gdańska
                                },
                                child: BuildOption(title: 'Budowa w Gdańsku'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/warszawa'); // Przejście na stronę Warszawy
                                },
                                child: BuildOption(title: 'Budowa w Warszawie'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/krakow'); // Przejście na stronę Krakowa
                                },
                                child: BuildOption(title: 'Budowa w Krakowie'),
                              ),
                            ],
                          ),
                        ),
                        // Dodanie odstępu między ListView a Dividerem
                        SizedBox(height: 10), // Przerwa o wysokości 30px
                        Divider(thickness: 1, color: Colors.white, height: 10), // Kreska oddzielająca sekcje
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4, // Ustalamy elastyczność sekcji powiadomień
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Column(
                      children: [
                        // Nagłówek dla sekcji powiadomień
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.0), // Zmniejszenie paddingu
                          child: Text(
                            'Powiadomienia',
                            style: TextStyle(
                              color: Color.fromARGB(255, 49, 49, 49),
                              fontSize: 18, // Czcionka nagłówka
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero, // Usunięcie domyślnego paddingu ListView
                            children: [
                              NotificationItem(title: 'Powiadomienie 1: Nowa aktualizacja budowy w Gdańsku'),
                              NotificationItem(title: 'Powiadomienie 2: Termin zakończenia budowy w Warszawie przesunięty'),
                              NotificationItem(title: 'Powiadomienie 3: Zmiana w planie budowy w Krakowie'),
                              NotificationItem(title: 'Powiadomienie 4: Spotkanie z inwestorem w Gdańsku'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Kreska oddzielająca pasek z ikonami
                Container(
                  color: Colors.white.withOpacity(0.7), // Przezroczyste tło dla oddzielającej kreski
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: Colors.white,
                        height: 20, // Zmniejszenie przestrzeni pod Dividerem
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.calendar_today, size: 20), // Rozmiar ikony
                            Icon(Icons.chat, size: 20), // Rozmiar ikony
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UserProfileScreen())
                                );
                              },
                            child:Icon(Icons.person, size: 20 ), ),// Rozmiar ikony
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

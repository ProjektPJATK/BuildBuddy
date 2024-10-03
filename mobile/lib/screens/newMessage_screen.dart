import 'package:flutter/material.dart';
import '../styles.dart'; // Import your styles

class NewMessageScreen extends StatefulWidget {
  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<String> selectedRecipients = [];
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Czarny filtr z przezroczystością 0.75
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // White semi-transparent filter over entire page using styles
          Container(
            color: AppStyles.transparentWhite, // Use transparentWhite from styles.dart
          ),
          // Main content of the page
          Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Powrót do poprzedniego ekranu
                    },
                  ),
                ),
              ),
              // Section for displaying selected recipients as input field
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 80, // Zwiększono wysokość pola odbiorców
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      // Open recipient selection screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipientSelectionScreen(selectedRecipients),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          selectedRecipients = result;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: selectedRecipients.isEmpty
                          ? 'Dodaj odbiorców'
                          : selectedRecipients.join(', '),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null, // Pozwala na wyświetlenie kilku linii odbiorców
                  ),
                ),
              ),
              // Message input field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          maxLines: null, // Możliwość wpisania dłuższej wiadomości
                          expands: true, // Pole rozszerza się na dostępne miejsce
                          decoration: InputDecoration(
                            hintText: 'Wpisz swoją wiadomość...',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Send button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Logika wysyłania wiadomości
                          },
                          child: Text('Wyślij'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecipientSelectionScreen extends StatefulWidget {
  final List<String> initialSelectedRecipients;

  RecipientSelectionScreen(this.initialSelectedRecipients);

  @override
  _RecipientSelectionScreenState createState() => _RecipientSelectionScreenState();
}

class _RecipientSelectionScreenState extends State<RecipientSelectionScreen> {
  List<String> allRecipients = ['Marta Nowak', 'Jan Kowalski', 'Piotr Malinowski', 'Anna Wiśniewska'];
  List<String> displayedRecipients = [];
  List<String> selectedRecipients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allRecipients.sort(); // Sortujemy odbiorców alfabetycznie
    displayedRecipients = List.from(allRecipients); // Kopia listy wszystkich odbiorców
    selectedRecipients = widget.initialSelectedRecipients;
  }

  // Funkcja wyszukiwania z dynamiczną aktualizacją
  void _filterChats(String query) {
    final results = allRecipients.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      displayedRecipients = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Czarny filtr z przezroczystością 0.75
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // White semi-transparent filter over entire page using styles
          Container(
            color: AppStyles.transparentWhite, // Use transparentWhite from styles.dart
          ),
          // Search and recipient list
          Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context, selectedRecipients); // Powrót do ekranu wiadomości
                    },
                  ),
                ),
              ),
              // Wyszukiwarka
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterChats,
                  decoration: InputDecoration(
                    hintText: 'Szukaj po imieniu i nazwisku...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              // Lista odbiorców
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: displayedRecipients.length,
                    itemBuilder: (context, index) {
                      String recipient = displayedRecipients[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7), // Białe tło z przezroczystością
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            recipient,
                            style: TextStyle(color: Colors.black),
                          ),
                          value: selectedRecipients.contains(recipient),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedRecipients.add(recipient);
                              } else {
                                selectedRecipients.remove(recipient);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

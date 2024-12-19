import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';

class RecipientSelectionScreen extends StatefulWidget {
  final List<String> initialSelectedRecipients;

  const RecipientSelectionScreen(this.initialSelectedRecipients, {super.key});

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
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Container(color: AppStyles.transparentWhite),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context, selectedRecipients); // Powrót z wybranymi odbiorcami
                    },
                  ),
                ),
              ),
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
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: displayedRecipients.length,
                    itemBuilder: (context, index) {
                      String recipient = displayedRecipients[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            recipient,
                            style: const TextStyle(color: Colors.black),
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

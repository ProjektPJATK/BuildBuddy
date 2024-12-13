import 'package:flutter/material.dart';

class EditItemDialog extends StatefulWidget {
  final int remaining;
  final int purchased;
  final ValueChanged<int> onSave;

  const EditItemDialog({
    super.key,
    required this.remaining,
    required this.purchased,
    required this.onSave,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _remainingController;

  @override
  void initState() {
    super.initState();
    _remainingController = TextEditingController(text: widget.remaining.toString());
  }

  @override
  void dispose() {
    _remainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Remaining', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _remainingController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Remaining',
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            final newRemaining = int.tryParse(_remainingController.text);
            if (newRemaining == null || newRemaining > widget.purchased) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Remaining cannot exceed purchased quantity!')),
              );
            } else {
              widget.onSave(newRemaining);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

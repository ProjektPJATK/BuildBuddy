import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';


class ConstructionDetails extends StatelessWidget {
  final String constructionName;

  const ConstructionDetails({super.key, required this.constructionName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.transparentWhite,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Szczegóły budowy:',
            style: AppStyles.headerStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Opis inwestycji i wszelkie istotne informacje dotyczące tej budowy.',
            style: AppStyles.textStyle,
          ),
        ],
      ),
    );
  }
}

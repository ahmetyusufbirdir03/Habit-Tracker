import 'package:flutter/material.dart';

void showErrorDialog({
  required BuildContext context,
  required String title,
  required List<String> errors,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: SingleChildScrollView(
          child: ListBody(
            children: errors.map((error) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $error', style: const TextStyle(fontSize: 15)),
                ),
            ).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Tamam'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
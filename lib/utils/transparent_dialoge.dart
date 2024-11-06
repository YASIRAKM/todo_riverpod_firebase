import 'package:flutter/material.dart';

transparantDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: SizedBox(width: 200, child: LinearProgressIndicator()),
      );
    },
  );
}

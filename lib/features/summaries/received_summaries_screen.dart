import 'package:flutter/material.dart';

class ReceivedSummariesScreen extends StatelessWidget {
  const ReceivedSummariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Summaries'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No summaries received yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

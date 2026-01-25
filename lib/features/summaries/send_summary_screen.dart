import 'package:flutter/material.dart';

class SendSummaryScreen extends StatefulWidget {
  const SendSummaryScreen({super.key});

  @override
  State<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends State<SendSummaryScreen> {
  final _textController = TextEditingController();

  void _send() {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter summary text')),
      );
      return;
    }
    // Logic to send summary to delegate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary sent to delegate successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Summary'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your summary with the delegate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Type your summary here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, // PDF/Image picker logic
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach PDF/Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send to Delegate', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  final Future<String> Function(String prompt) onSendPrompt;
  const AIChatScreen({Key? key, required this.onSendPrompt}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  void _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(prompt, true));
      _isLoading = true;
      _controller.clear();
    });
    final response = await widget.onSendPrompt(prompt);
    setState(() {
      _messages.add(_ChatMessage(response, false));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendPrompt(),
                    decoration: const InputDecoration(
                      hintText: 'Type your question...'
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendPrompt,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

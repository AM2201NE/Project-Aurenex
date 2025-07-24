import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../ai/llm_interface.dart';
import 'dart:typed_data';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  AIAssistantScreenState createState() => AIAssistantScreenState();
}

class AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  late LLMInterface _aiService;
  bool _isInitialized = false;
  String _initStatus = 'Initializing AI...';

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    setState(() {
      _isInitialized = false;
      _initStatus = 'Initializing AI...';
    });

    try {
      _aiService = AIService();
      final success = await _aiService.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = success;
          _initStatus = success 
              ? 'AI initialized successfully' 
              : 'Failed to initialize AI. Please check model files.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _initStatus = 'Error initializing AI: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_promptController.text.trim().isEmpty || !_isInitialized || _isGenerating) {
      return;
    }

    final userMessage = ChatMessage(
      text: _promptController.text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _promptController.clear();
    _scrollToBottom();

    // Add a placeholder for the AI response
    final aiMessage = ChatMessage(
      text: '',
      isUser: false,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    try {
      await _aiService.generateText(
        userMessage.text,
        onToken: (token) {
          if (mounted) {
            setState(() {
              aiMessage.text += token;
            });
            _scrollToBottom();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          aiMessage.text = 'Error generating response: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendImageWithPrompt(Uint8List imageData) async {
    if (!_isInitialized || _isGenerating) {
      return;
    }

    final prompt = _promptController.text.trim().isEmpty 
        ? 'Describe this image in detail.' 
        : _promptController.text;

    final userMessage = ChatMessage(
      text: prompt,
      isUser: true,
      hasImage: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _promptController.clear();
    _scrollToBottom();

    // Add a placeholder for the AI response
    final aiMessage = ChatMessage(
      text: '',
      isUser: false,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    try {
      await _aiService.generateTextWithImage(
        prompt,
        imageData.toList(),
        onToken: (token) {
          if (mounted) {
            setState(() {
              aiMessage.text += token;
            });
            _scrollToBottom();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          aiMessage.text = 'Error generating response: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeAI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGenerating ? null : _initializeAI,
            tooltip: 'Reinitialize AI',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isInitialized)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              width: double.infinity,
              child: Text(
                _initStatus,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber.shade900),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeMessage()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'VibeAI Assistant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything or share an image for analysis',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_isInitialized)
            ElevatedButton(
              onPressed: _initializeAI,
              child: const Text('Initialize AI'),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasImage)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: const Icon(
                  Icons.image,
                  color: Colors.white,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _isInitialized && !_isGenerating
                ? () {
                    // Image selection would be implemented here
                    // For now, just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image selection not implemented in this demo'),
                      ),
                    );
                  }
                : null,
            tooltip: 'Add image',
          ),
          Expanded(
            child: TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              enabled: _isInitialized && !_isGenerating,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isInitialized && !_isGenerating ? _sendMessage : null,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final bool hasImage;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasImage = false,
  });
}

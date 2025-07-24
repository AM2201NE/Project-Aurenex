import 'package:flutter/material.dart';
import '../../models/page.dart';
import '../../ai/llm_interface.dart';

/// AI assistant panel widget
class AiAssistantPanel extends StatefulWidget {
  final NotePage page;
  final VoidCallback onClose;
  final Function(Block) onInsertBlock;
  
  const AiAssistantPanel({
    Key? key,
    required this.page,
    required this.onClose,
    required this.onInsertBlock,
  }) : super(key: key);

  @override
  _AiAssistantPanelState createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final TextEditingController _promptController = TextEditingController();
  final LLMInterface _llmInterface = LLMInterface();
  String _response = '';
  bool _isGenerating = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAi();
  }
  
  /// Initialize the AI
  Future<void> _initializeAi() async {
    setState(() {
      _isInitialized = false;
    });
    
    await _llmInterface.initialize();
    
    setState(() {
      _isInitialized = true;
      _response = 'VibeAI assistant is ready. How can I help you with your note?';
    });
  }
  
  /// Generate text from prompt
  Future<void> _generateText() async {
    final prompt = _promptController.text;
    if (prompt.isEmpty) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Create context from page content
      final pageContent = widget.page.blocks.values
          .map((block) {
            if (block.type.startsWith('heading')) {
              return '# ${(block as dynamic).plainText}';
            } else if (block.type == 'paragraph') {
              return (block as dynamic).plainText;
            } else {
              return '';
            }
          })
          .where((text) => text.isNotEmpty)
          .join('\n\n');
      
      // Create full prompt with context
      final fullPrompt = '''
Context:
Title: ${widget.page.title}
Content:
$pageContent

User request: $prompt

Please provide a helpful response:
''';
      
      final response = await _llmInterface.generateText(
        fullPrompt,
        temperature: 0.7,
        maxTokens: 1024,
      );
      
      setState(() {
        _response = response;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isGenerating = false;
      });
    }
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    _llmInterface.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8.0),
                Text(
                  'VibeAI Assistant',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          
          // Response area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isInitialized)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.0),
                            Text('Initializing AI assistant...'),
                          ],
                        ),
                      )
                    else if (_isGenerating)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.0),
                            Text('Generating response...'),
                          ],
                        ),
                      )
                    else
                      Text(_response),
                  ],
                ),
              ),
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      hintText: 'Ask VibeAI...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    enabled: _isInitialized && !_isGenerating,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isInitialized && !_isGenerating ? _generateText : null,
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MermaidRenderer extends StatefulWidget {
  final String code;
  final String? caption;
  
  const MermaidRenderer({
    super.key,
    required this.code,
    this.caption,
  });
  
  @override
  MermaidRendererState createState() => MermaidRendererState();
}

class MermaidRendererState extends State<MermaidRenderer> {
  late WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _renderMermaid();
          },
        ),
      )
      ..loadHtmlString(_buildHtml());
  }
  
  String _buildHtml() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
        <style>
          body { margin: 0; padding: 0; background-color: transparent; }
          #diagram { width: 100%; }
        </style>
      </head>
      <body>
        <div class="mermaid" id="diagram">
          ${widget.code}
        </div>
        <script>
          mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
          });
        </script>
      </body>
      </html>
    ''';
  }
  
  void _renderMermaid() {
    _controller.runJavaScript('''
      mermaid.init(undefined, document.querySelector('.mermaid'));
    ''');
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          height: 300, // Fixed height, could be made dynamic
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        if (widget.caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.caption!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}

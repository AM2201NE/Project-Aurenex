import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeService themeService;
  
  const SettingsScreen({
    super.key,
    required this.themeService,
  });
  
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  
  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeService.themeModeNotifier.value;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildThemeSection(),
          const Divider(),
          _buildAISection(),
          const Divider(),
          _buildStorageSection(),
          const Divider(),
          _buildAboutSection(),
        ],
      ),
    );
  }
  
  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('Choose light, dark, or system theme'),
          trailing: DropdownButton<ThemeMode>(
            value: _themeMode,
            onChanged: (ThemeMode? newValue) {
              if (newValue != null) {
                setState(() {
                  _themeMode = newValue;
                  widget.themeService.setThemeMode(newValue);
                });
              }
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('AI Model'),
          subtitle: const Text('Qwen2-VL-2B-Instruct'),
          trailing: const Icon(Icons.info_outline),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('AI Model Information'),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Model: Qwen2-VL-2B-Instruct'),
                      SizedBox(height: 8),
                      Text('Size: 2 billion parameters'),
                      SizedBox(height: 8),
                      Text('Type: Multimodal (text + images)'),
                      SizedBox(height: 8),
                      Text('Quantization: 4-bit'),
                      SizedBox(height: 16),
                      Text('This model runs completely offline on your device.'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        SwitchListTile(
          title: const Text('Voice Input'),
          subtitle: const Text('Enable voice commands for AI assistant'),
          value: false, // This would be a stored preference
          onChanged: (bool value) {
            // Toggle voice input setting
          },
        ),
      ],
    );
  }
  
  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Storage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Export All Notes'),
          subtitle: const Text('Save all notes as Markdown files'),
          trailing: const Icon(Icons.download),
          onTap: () {
            // Export notes functionality
          },
        ),
        ListTile(
          title: const Text('Import Notes'),
          subtitle: const Text('Import notes from Markdown files'),
          trailing: const Icon(Icons.upload),
          onTap: () {
            // Import notes functionality
          },
        ),
        ListTile(
          title: const Text('Storage Location'),
          subtitle: const Text('Change where notes are stored'),
          trailing: const Icon(Icons.folder),
          onTap: () {
            // Change storage location
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          trailing: const Icon(Icons.code),
          onTap: () {
            // Open GitHub link
          },
        ),
        ListTile(
          title: const Text('License'),
          subtitle: const Text('MIT License'),
          trailing: const Icon(Icons.description),
          onTap: () {
            // Show license information
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/workspace.dart';

/// Sidebar widget for the application
class Sidebar extends StatelessWidget {
  final List<Workspace> workspaces;
  final String? selectedWorkspaceId;
  final Function(String) onWorkspaceSelected;
  final VoidCallback onCreateWorkspace;
  
  const Sidebar({
    Key? key,
    required this.workspaces,
    required this.selectedWorkspaceId,
    required this.onWorkspaceSelected,
    required this.onCreateWorkspace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
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
                Text(
                  'Workspaces',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onCreateWorkspace,
                  tooltip: 'Create Workspace',
                ),
              ],
            ),
          ),
          
          // Workspace list
          Expanded(
            child: ListView.builder(
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final workspace = workspaces[index];
                final isSelected = workspace.id == selectedWorkspaceId;
                
                return ListTile(
                  title: Text(workspace.name),
                  subtitle: Text(
                    '${workspace.pages.length} pages',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () => onWorkspaceSelected(workspace.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

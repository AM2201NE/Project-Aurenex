import 'package:flutter/material.dart';
import '../../models/workspace.dart';
import 'empty_state.dart';
import '../ai_chat_screen.dart';

/// Page list widget for displaying pages in a workspace
class PageList extends StatelessWidget {
  final Workspace workspace;
  final String? selectedPageId;
  final VoidCallback onCreatePage;
  final void Function(String pageId) onPageSelected;

  const PageList({
    Key? key,
    required this.workspace,
    required this.onCreatePage,
    required this.onPageSelected,
    this.selectedPageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Defensive: Ensure workspace.pages is a Map and workspace.pageOrder is a List
    // Defensive: workspace.pages and workspace.pageOrder are always non-null
    final pages = workspace.pages;
    // Always reconstruct pageOrder from valid page IDs in pages
    final reconstructedPageOrder = pages?.keys.map((k) => k.toString()).where((k) => k.isNotEmpty && k != 'null').toList() ?? <String>[];
    if (pages == null || pages.isEmpty || reconstructedPageOrder.isEmpty) {
      debugPrint('PageList: workspace.pages or reconstructedPageOrder is empty. Showing EmptyState.');
      return EmptyState(
        title: 'No Pages',
        message: 'Create a page to get started',
        buttonText: 'Create Page',
        onButtonPressed: onCreatePage,
      );
    }

    return Column(
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
                workspace.name ?? 'Workspace',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onCreatePage,
                tooltip: 'Create Page',
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                tooltip: 'Open AI Chat',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AIChatScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        // Page list
        Expanded(
          child: ListView.builder(
            itemCount: reconstructedPageOrder.length,
            itemBuilder: (context, index) {
              final pageId = reconstructedPageOrder[index];
              final page = pages[pageId];
              if (page == null) {
                debugPrint('PageList: pageId "$pageId" not found in workspace.pages, skipping.');
                return const SizedBox.shrink();
              }
              // Defensive: Check page.title and page.updatedAt
              final title = page.title.toString().isNotEmpty ? page.title.toString() : 'Untitled';
              final updatedAt = int.tryParse(page.updatedAt.toString()) != null
                  ? int.parse(page.updatedAt.toString())
                  : DateTime.now().millisecondsSinceEpoch;
              final isSelected = pageId == selectedPageId;
              return ListTile(
                title: Text(title),
                subtitle: Text(
                  'Modified: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(updatedAt))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                selected: isSelected,
                selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                onTap: () => onPageSelected(pageId),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

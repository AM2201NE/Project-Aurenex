import 'package:flutter/material.dart';
import '../models/page.dart' as page_model;

class DashboardScreen extends StatelessWidget {
  final List<page_model.Page> pages;
  final void Function(page_model.Page) onOpenPage;
  final VoidCallback onCreatePage;
  final Widget? aiChatButton;
  const DashboardScreen({Key? key, required this.pages, required this.onOpenPage, required this.onCreatePage, this.aiChatButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (aiChatButton != null) aiChatButton!,
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Page',
            onPressed: onCreatePage,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: pages.length,
        itemBuilder: (context, i) {
          final page = pages[i];
          return GestureDetector(
            onTap: () => onOpenPage(page),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      page.description.isNotEmpty ? page.description : 'No description',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

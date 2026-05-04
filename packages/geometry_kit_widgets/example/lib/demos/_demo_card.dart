import 'package:flutter/material.dart';

class DemoCard extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget child;

  const DemoCard({
    super.key,
    required this.title,
    required this.child,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(caption!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

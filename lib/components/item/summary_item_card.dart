import 'package:flutter/material.dart';

class SummaryItemCard extends StatelessWidget {
  const SummaryItemCard({
    super.key,
    required this.type,
    required this.name,
    required this.amount,
    this.imageUrl,
    this.items = const [],
    this.showToggle = false,
    this.paid = false,
    this.onToggle,
    this.onTap,
  });

  final String type;
  final String name;
  final double amount;
  final String? imageUrl;
  final List<String> items;
  final bool showToggle;
  final bool paid;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = type == 'subscription'
        ? cs.inversePrimary
        : cs.outlineVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: type == 'subscription'
            ? _buildSubscriptionContent(context)
            : _buildParticipantContent(context, cs),
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50.0,
          width: 50.0,
          child: imageUrl != null
              ? Image.network(imageUrl!)
              : const Icon(Icons.subscriptions, size: 40),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Text('${amount.toStringAsFixed(2)} บาท'),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantContent(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text('${amount.toStringAsFixed(2)} บาท'),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: items.map((e) => Chip(label: Text(e))).toList(),
          ),
        ],
        if (showToggle)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('ชำระแล้ว'),
            value: paid,
            onChanged: (v) => onToggle?.call(v ?? false),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.onTap,
    this.title,
    this.totalAmount,
    this.yourOwe,
    this.paidByYou,
    this.isSummary = false,
  });

  final VoidCallback onTap;
  final String? title;
  final double? totalAmount;
  final double? yourOwe;
  final bool? paidByYou;
  final bool isSummary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = paidByYou == true ? cs.primary : cs.secondary;
    final iconData = paidByYou == true ? Icons.task_alt : Icons.receipt_long;
    final displayYourOwe = yourOwe ?? 0.0;

    return InkWell(
      onTap: isSummary ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSummary ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.inversePrimary),
        ),
        child: isSummary
            ? _CardData(context, cs)
            : _detailCard(context, cs, iconData, iconColor, displayYourOwe),
      ),
    );
  }

  Widget _CardData(BuildContext context, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ยอดที่คุณต้องจ่ายรวม',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '${totalAmount?.toStringAsFixed(2) ?? '0.00'} บาท',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
        ),
      ],
    );
  }

  Widget _detailCard(
    BuildContext context,
    ColorScheme cs,
    IconData iconData,
    Color iconColor,
    double displayYourOwe,
  ) {
    return Row(
      children: [
        Icon(iconData, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'รายการบิล',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text('รวมบิล: ${totalAmount?.toStringAsFixed(2) ?? '0.00'} บาท'),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayYourOwe > 0.0 ? 'คุณต้องจ่าย' : 'คุณจะได้รับ',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              displayYourOwe.toStringAsFixed(2),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: displayYourOwe > 0.0 ? cs.error : cs.tertiary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
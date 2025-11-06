import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/constants.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.onTap,
    this.title,
    this.totalAmount,
    this.yourOwe,
    this.paidByYou,
    this.isSummary = false,
    this.category,
    this.billStatus,
  });

  final VoidCallback onTap;
  final String? title;
  final double? totalAmount;
  final double? yourOwe;
  final bool? paidByYou;
  final bool isSummary;
  final BillCategory? category;
  final String? billStatus;

  String get _categoryDisplay {
    if (category == null) return '';
    final index = BillCategory.values.indexWhere((e) => e == category);
    return index >= 0 && index < billCategories.length ? billCategories[index] : '';
  }

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

  Widget _buildStatusTag(BuildContext context, ColorScheme cs, String status) { 
    Color color;
    if (status == 'ปิดบิล') {
      color = Colors.green.shade700;
    } else if (status == 'กำลังเก็บ') {
      color = Colors.orange.shade700;
    } else {
      color = cs.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold), 
      ),
    );
}

  Widget _CardData(BuildContext context, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'รวมยอดที่รอเรียกเก็บเงิน',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (billStatus != null) _buildStatusTag(context, cs, billStatus!), 
              
              Text(
                title ?? 'รายการบิล',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (_categoryDisplay.isNotEmpty)
                Text(
                  _categoryDisplay,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
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
              displayYourOwe > 0.0 ? 'รอเรียกเก็บเงิน' : 'รอเรียกเก็บเงิน',
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
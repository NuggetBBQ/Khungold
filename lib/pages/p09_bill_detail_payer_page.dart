import 'package:flutter/material.dart';
import 'package:khungold/components/input/payment_method_field.dart';
import 'package:khungold/components/input/tip_chips.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/constants.dart';


class BillDetailPayerPage extends StatefulWidget {
  const BillDetailPayerPage({super.key, required this.bill});
  final Bill bill;
  @override
  State<BillDetailPayerPage> createState() => _BillDetailPayerPageState();
}

class _BillDetailPayerPageState extends State<BillDetailPayerPage> {
  final _formKey = GlobalKey<FormState>();
  int _tipIndex = 0;
  String? _method;

  @override
  void initState() {
    super.initState();
    final idx = tipChoices.indexWhere((e) => e == widget.bill.yourTip.round());
    _tipIndex = idx >= 0 ? idx : 0;
  }

  double _yourTotalWithTip() {
    return widget.bill.yourBaseShare + tipChoices[_tipIndex].toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateString = widget.bill.date.toString().split(' ')[0];
    final alreadyPaid = widget.bill.paidByYou;
    final yourPay = alreadyPaid ? 0.0 : _yourTotalWithTip();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('รายละเอียดบิล (ผู้ต้องจ่าย)'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.inversePrimary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เจ้าของบิล: ${widget.bill.ownerName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.bill.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text('วันที่: $dateString'),
                  const SizedBox(height: 8),
                  Text('รวมบิล: ${widget.bill.total.toStringAsFixed(2)} บาท'),
                  const SizedBox(height: 2),
                  Text('คุณต้องจ่าย: ${yourPay.toStringAsFixed(2)} บาท'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...widget.bill.participants.map(
              (p) => SummaryItemCard(
                type: 'participant',
                name: p.name,
                amount: p.baseShare,
                items: p.items,
              ),
            ),
            const SizedBox(height: 16),
            Text('เลือกทิป', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TipChips(
              choices: tipChoices,
              selectedIndex: _tipIndex,
              onChanged: alreadyPaid
                  ? (_) {}
                  : (i) => setState(() => _tipIndex = i),
            ),
            const SizedBox(height: 12),
            PaymentMethodField(
              methods: paymentMethods,
              value: _method,
              onChanged: alreadyPaid
                  ? (_) {}
                  : (v) => setState(() => _method = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: alreadyPaid
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        final flags = widget.bill.participants
                            .map((e) => e.paid)
                            .toList();
                        final meIndex = widget.bill.participants.indexWhere(
                          (e) => e.isYou,
                        );
                        if (meIndex != -1) flags[meIndex] = true;
                        final updated = Bill(
                          title: widget.bill.title,
                          date: widget.bill.date,
                          ownerId: widget.bill.ownerId,
                          ownerName: widget.bill.ownerName,
                          ownerIsYou: widget.bill.ownerIsYou,
                          participants: List.generate(
                            widget.bill.participants.length,
                            (i) {
                              final p = widget.bill.participants[i];
                              return Participant(
                                id: p.id,
                                name: p.name,
                                baseShare: p.baseShare,
                                items: List<String>.from(p.items),
                                paid: flags[i],
                                isYou: p.isYou,
                              );
                            },
                          ),
                          status: widget.bill.status,
                          note: widget.bill.note,
                          yourTip: tipChoices[_tipIndex].toDouble(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ชำระเงิน ${yourPay.toStringAsFixed(2)} บาท สำเร็จ',
                            ),
                          ),
                        );
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (mounted) Navigator.pop(context, updated);
                      },
                child: Text(
                  alreadyPaid
                      ? 'จ่ายแล้ว'
                      : 'จ่ายเงิน ${yourPay.toStringAsFixed(2)} บาท',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
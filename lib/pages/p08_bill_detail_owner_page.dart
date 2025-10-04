import 'package:flutter/material.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/bill_models.dart';



class BillDetailOwnerPage extends StatefulWidget {
  const BillDetailOwnerPage({super.key, required this.bill});
  final Bill bill;
  @override
  State<BillDetailOwnerPage> createState() => _BillDetailOwnerPageState();
}

class _BillDetailOwnerPageState extends State<BillDetailOwnerPage> {
  final _formKey = GlobalKey<FormState>();
  late String _status;
  String _note = '';
  late List<bool> _paidFlags;

  @override
  void initState() {
    super.initState();
    _status = widget.bill.status;
    _note = widget.bill.note ?? '';
    _paidFlags = widget.bill.participants.map((e) => e.paid).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateString = widget.bill.date.toString().split(' ')[0];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('รายละเอียดบิล (เจ้าของ)'),
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
                  if (_note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('หมายเหตุ: $_note'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(widget.bill.participants.length, (i) {
              final p = widget.bill.participants[i];
              return SummaryItemCard(
                type: 'participant',
                name: p.name,
                amount: p.baseShare,
                items: p.items,
                showToggle: true,
                paid: _paidFlags[i],
                onToggle: (v) => setState(() => _paidFlags[i] = v),
              );
            }),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'สถานะบิล',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'กำลังเก็บ', child: Text('กำลังเก็บ')),
                DropdownMenuItem(value: 'ปิดบิล', child: Text('ปิดบิล')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'กำลังเก็บ'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'กรุณาเลือกสถานะ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _note,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุ (ไม่บังคับ)',
                border: OutlineInputBorder(),
              ),
              onSaved: (v) => _note = (v ?? '').trim(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final allPaid = _paidFlags.every((v) => v);
                  if (_status == 'ปิดบิล' && !allPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ต้องติ๊กทุกคนชำระแล้วก่อนปิดบิล'),
                      ),
                    );
                    return;
                  }
                  _formKey.currentState!.save();
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
                          paid: _paidFlags[i],
                          isYou: p.isYou,
                        );
                      },
                    ),
                    status: _status,
                    note: _note,
                    yourTip: widget.bill.yourTip,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกการเปลี่ยนแปลงแล้ว')),
                  );
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (mounted) Navigator.pop(context, updated);
                },
                child: const Text('บันทึกการเปลี่ยนแปลง'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
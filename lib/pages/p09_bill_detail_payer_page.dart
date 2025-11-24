import 'package:flutter/material.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/data_service.dart';

class BillDetailPayerPage extends StatefulWidget {
  const BillDetailPayerPage({super.key, required this.bill});
  final Bill bill;

  @override
  State<BillDetailPayerPage> createState() => _BillDetailPayerPageState();
}

class _BillDetailPayerPageState extends State<BillDetailPayerPage> {
  final _formKey = GlobalKey<FormState>();

  late String _status;
  late String _note;
  late List<bool> _paidFlags;

  @override
  void initState() {
    super.initState();

    _status = widget.bill.status;
    _note = widget.bill.note ?? '';

    // เก็บสถานะ paid ของแต่ละคน
    _paidFlags = widget.bill.participants.map((e) => e.paid).toList();
  }

  Widget _buildCollectorUI(ColorScheme cs) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'หมวดหมู่: ${widget.bill.category.toString().split('.').last}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),

              Text(
                widget.bill.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(height: 30),

              Text(
                'ยอดรวมบิล: ${widget.bill.total.toStringAsFixed(2)} ฿',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'ยอดที่เรียกเก็บ: ${widget.bill.totalToCollect.toStringAsFixed(2)} ฿',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: cs.primary),
              ),
              const SizedBox(height: 10),

              Text(
                'ผู้เข้าร่วม (${widget.bill.participants.length} คน)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              ...List.generate(widget.bill.participants.length, (i) {
                final p = widget.bill.participants[i];
                return SummaryItemCard(
                  type: 'participant',
                  name: p.isYou ? '${p.name} (คุณ)' : p.name,
                  amount: p.baseShare,
                  items: p.items,
                  showToggle: true,
                  paid: _paidFlags[i],
                  onToggle: (v) => setState(() => _paidFlags[i] = v),
                );
              }),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'สถานะบิล',
                  border: OutlineInputBorder(),
                ),
                items: ['กำลังเก็บ', 'ปิดบิล', 'ยกเลิก']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(
                  labelText: 'บันทึก (Note)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _note = v,
                maxLines: 2,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกการเปลี่ยนแปลง'),
                  onPressed: () async {
                    final updated = Bill(
                      id: widget.bill.id,
                      title: widget.bill.title,
                      date: widget.bill.date,
                      ownerId: widget.bill.ownerId,
                      ownerName: widget.bill.ownerName,
                      ownerIsYou: widget.bill.ownerIsYou,
                      category: widget.bill.category,
                      participantEmails: widget.bill.participantEmails,
                      participants: List.generate(
                        widget.bill.participants.length,
                        (i) => widget.bill.participants[i].copyWith(
                          paid: _paidFlags[i],
                        ),
                      ),
                      status: _status,
                      note: _note,
                      yourTip: widget.bill.yourTip,
                    );

                    await DataService.updateBill(updated);

                    if (mounted) Navigator.pop(context, updated);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('รายละเอียดบิล'),
      ),
      body: Form(key: _formKey, child: _buildCollectorUI(cs)),
    );
  }
}

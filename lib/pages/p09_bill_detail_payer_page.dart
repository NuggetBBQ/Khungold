import 'package:flutter/material.dart';
import 'package:khungold/components/input/payment_method_field.dart';
import 'package:khungold/components/input/tip_chips.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/constants.dart';
import 'package:khungold/services/data_service.dart';

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

  String _getCategoryDisplay(BillCategory category) {
    final enumString = category.toString().split('.').last;
    final index = BillCategory.values.indexWhere(
      (e) => e.toString().split('.').last == enumString,
    );
    return index != -1 && index < billCategories.length
        ? billCategories[index]
        : 'อื่นๆ';
  }

  late bool _isCollector;
  late String _status;
  late String _note;
  late List<bool> _paidFlags;

  @override
  void initState() {
    super.initState();
    _isCollector = widget.bill.ownerIsYou;
    _status = widget.bill.status;
    _note = widget.bill.note ?? '';
    _paidFlags = widget.bill.participants.map((e) => e.paid).toList();

    if (!_isCollector && widget.bill.participants.any((p) => p.isYou)) {
      final idx = tipChoices.indexWhere(
        (e) => e == widget.bill.yourTip.round(),
      );
      _tipIndex = idx >= 0 ? idx : 0;
    }
  }

  Widget _buildCollectorUI(
    ColorScheme cs,
    String dateString,
    String categoryDisplay,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'หมวดหมู่: ${categoryDisplay}',
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
                  onToggle: (v) {
                    setState(() => _paidFlags[i] = v);
                  },
                );
              }),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'สถานะบิล',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    _formKey.currentState!.save();

                    final updated = Bill(
                      id: widget.bill.id,
                      title: widget.bill.title,
                      date: widget.bill.date,
                      ownerId: widget.bill.ownerId,
                      ownerName: widget.bill.ownerName,
                      ownerIsYou: widget.bill.ownerIsYou,
                      category: widget.bill.category,
                      participants: List.generate(
                        widget.bill.participants.length,
                        (i) {
                          final p = widget.bill.participants[i];
                          return p.copyWith(paid: _paidFlags[i]);
                        },
                      ),
                      status: _status,
                      note: _note,
                      yourTip: widget.bill.yourTip,
                    );

                    await DataService.updateBill(updated);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกการเปลี่ยนแปลงแล้ว')),
                    );
                    await Future.delayed(const Duration(milliseconds: 800));
                    if (mounted) Navigator.pop(context, updated);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกการเปลี่ยนแปลง'),
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
    final dateString = widget.bill.date.toString().split(' ')[0];
    final categoryDisplay = _getCategoryDisplay(widget.bill.category);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('รายละเอียดบิล'),
      ),
      body: Form(
        key: _formKey,
        child: _buildCollectorUI(cs, dateString, categoryDisplay),
      ),
    );
  }
}

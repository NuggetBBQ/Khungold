import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';

class AddItemDialog extends StatefulWidget {
  final List<Participant> participants;

  const AddItemDialog({super.key, required this.participants});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _itemFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<String> _selectedIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เพิ่มรายการอาหาร'),
      content: SingleChildScrollView(
        child: Form(
          key: _itemFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (v) => v!.isEmpty ? 'โปรดระบุชื่อ' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v!) == null || double.parse(v) <= 0
                    ? 'ระบุราคาที่ถูกต้อง'
                    : null,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('ใครต้องจ่ายรายการนี้บ้าง:'),
              ),
              ...widget.participants.map((p) => CheckboxListTile(
                    title: Text(p.name),
                    value: _selectedIds.contains(p.id),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedIds.add(p.id);
                        } else {
                          _selectedIds.remove(p.id);
                        }
                      });
                    },
                  )).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('เพิ่ม'),
        ),
      ],
    );
  }

  void _addItem() {
    if (_itemFormKey.currentState!.validate()) {
      if (_selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('โปรดเลือกผู้เข้าร่วมอย่างน้อย 1 คน'))
        );
        return;
      }
      
      final newItem = BillItem(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        participantIds: _selectedIds,
      );
      
      Navigator.pop(context, newItem); 
    }
  }
}
import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';

class AddItemPage extends StatefulWidget {
  final List<Participant> participants;

  const AddItemPage({super.key, required this.participants});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _itemFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addItem() {
    
    if (_itemFormKey.currentState!.validate()) {
      if (_selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('โปรดเลือกผู้เข้าร่วมอย่างน้อย 1 คน'),
                duration: Duration(seconds: 2),
              )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มรายการอาหาร'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _itemFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                  validator: (v) => v!.isEmpty ? 'โปรดระบุชื่อ' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v!) == null || double.parse(v!) <= 0
                      ? 'ระบุราคาที่ถูกต้อง'
                      : null,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 5),
                  child: Text('ใครต้องจ่ายรายการนี้บ้าง:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      contentPadding: EdgeInsets.zero,
                    )).toList(),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('เพิ่มรายการ'),
                ),
                
                const SizedBox(height: 10),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
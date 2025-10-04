import 'package:flutter/material.dart';
import 'package:khungold/models/subscription_models.dart';

class AddSub extends StatefulWidget {
  const AddSub({super.key});
  
  @override
  State<AddSub> createState() => _AddSubState();
}

class _AddSubState extends State<AddSub> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _saveName = '';
  double _savePrice = 0;

  void _submitForm() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();

      final newSub = Subscription(
        name: _saveName, 
        price: _savePrice, 
        imageUrl: 'https://cdn-icons-png.flaticon.com/128/4063/4063291.png', 
      );

      Navigator.pop(context, newSub);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title : const Text('เพิ่มรายการใหม่'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อรายการ',
                  hintText: 'เช่น App ABC',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'โปรดระบุชื่อรายการ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _saveName = value!;
                },
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'ราคา (บาท)',
                  hintText: 'เช่น 100.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'โปรดใส่ราคาที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _savePrice = double.tryParse(value!) ?? 0.0;
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Text('บันทึกรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
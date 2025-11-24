import 'package:flutter/material.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/services/data_service.dart';
import 'package:uuid/uuid.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mainNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otherNamesController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      const uuid = Uuid();
      final newId = uuid.v4();

      final otherNames = _otherNamesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final newContact = Contact(
        id: newId,
        mainName: _mainNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        otherNames: otherNames,
      );

      DataService.addContact(newContact);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึก ${newContact.mainName} แล้ว')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มรายชื่อใหม่'),
        backgroundColor: cs.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _mainNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อหลัก (Main Name)',
                  hintText: 'เช่น นาย, John',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'โปรดระบุชื่อหลัก';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล (Email)',
                  hintText: 'ระบุอีเมลเพื่อนเพื่อเชื่อมต่อบัญชี',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _otherNamesController,
                decoration: const InputDecoration(
                  labelText: 'ชื่ออื่นๆ (Other Names)',
                  hintText: 'เช่น Nine, 9, ไนน์',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
                child: const Text('บันทึกรายชื่อ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

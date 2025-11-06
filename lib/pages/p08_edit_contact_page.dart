import 'package:flutter/material.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/services/data_service.dart';

class EditContactPage extends StatefulWidget {
  final Contact contactToEdit;
  
  const EditContactPage (
    {
      super.key, required this.contactToEdit
      }
      );

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late final TextEditingController _mainNameController;
  late final TextEditingController _otherNamesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mainNameController = TextEditingController(text: widget.contactToEdit.mainName);
    _otherNamesController = TextEditingController(text: widget.contactToEdit.otherNames.join(', '));
  }

  @override
  void dispose() {
    _mainNameController.dispose();
    _otherNamesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final newMainName = _mainNameController.text.trim();
      final newOtherNames = _otherNamesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

          final updatedContact = widget.contactToEdit.copyWith(
      mainName: newMainName,
      otherNames: newOtherNames,
    );

      try {
        await DataService.updateContact(updatedContact);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บันทึกการแก้ไขเรียบร้อย!')),
          );
          
          Navigator.of(context).pop(true); 
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข: ${widget.contactToEdit.mainName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${widget.contactToEdit.id}'),
              const SizedBox(height: 20),

              TextFormField(
                controller: _mainNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อหลัก (Main Name)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ชื่อหลักห้ามว่าง!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _otherNamesController,
                decoration: const InputDecoration(
                  labelText: 'ชื่ออื่นๆ (คั่นด้วย ,)',
                  helperText: 'เช่น: พาย, ส้ม, Pie',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
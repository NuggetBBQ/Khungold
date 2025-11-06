import 'package:flutter/material.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/services/data_service.dart';
import 'package:uuid/uuid.dart';

class AddSub extends StatefulWidget {
  final Subscription? subToEdit;
  
  const AddSub({super.key, this.subToEdit});
  
  @override
  State<AddSub> createState() => _AddSubState();
}

class _AddSubState extends State<AddSub> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  String _saveId = '';
  String _saveName = '';
  double _savePrice = 0;
  String _selectedIconUrl = ''; 
  
  bool get isEditing => widget.subToEdit != null;

  final List<String> _iconChoices = const [
    'https://cdn-icons-png.flaticon.com/128/5968/5968617.png',
    'https://cdn-icons-png.flaticon.com/128/717/717421.png',
    'https://cdn-icons-png.flaticon.com/128/3669/3669688.png',
    'https://cdn-icons-png.flaticon.com/128/9116/9116712.png',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _saveId = widget.subToEdit!.id;
      _nameController.text = widget.subToEdit!.name;
      _priceController.text = widget.subToEdit!.price.toString();
      _selectedIconUrl = widget.subToEdit!.imageUrl; 
    } else {
      _saveId = const Uuid().v4(); 
      _selectedIconUrl = _iconChoices.last; 
    }
  }

  void _submitForm() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();

      final newSub = Subscription(
        id: _saveId, 
        name: _saveName, 
        price: _savePrice, 
        imageUrl: _selectedIconUrl, 
      );

      if (isEditing) {
        await DataService.updateSubscription(newSub);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('แก้ไข ${newSub.name} สำเร็จ')),
        );
      } else {
        await DataService.addSubscription(newSub);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('เพิ่ม ${newSub.name} สำเร็จ')),
        );
      }

      Navigator.pop(context, true); 
    }
  }

  void _deleteSub() async {
    if (!isEditing) return;

    await DataService.removeSubscription(widget.subToEdit!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ลบรายการ ${widget.subToEdit!.name} แล้ว')),
    );
    Navigator.pop(context, true); 
  }

  Widget _imagePreview(ColorScheme cs) {
    final url = _selectedIconUrl;

    return Padding(
  padding: const EdgeInsets.only(top: 10, bottom: 20),
  child: Center(
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.subscriptions),
            )
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title : Text(isEditing ? 'แก้ไขรายการสมาชิก' : 'เพิ่มรายการใหม่'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSub,
            ),
        ],
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
                  hintText: 'เช่น Netflix',
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
              const SizedBox(height: 20),
              
              Text('เลือกไอคอน', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8.0,
                children: _iconChoices.map((url) {
                  final isSelected = url == _selectedIconUrl;
                  return ChoiceChip(
                    label: Text(url),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedIconUrl = url;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              _imagePreview(cs),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: cs.inversePrimary,
                ),
                child: Text(isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ'),
              ),
              
              if (isEditing) 
                TextButton(
                  onPressed: _deleteSub,
                  child: const Text('ลบรายการนี้', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
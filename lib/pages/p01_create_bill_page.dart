import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/pages/p07_add_item_dialog.dart';
import 'package:khungold/services/constants.dart';
import 'package:khungold/services/data_service.dart';
import 'package:uuid/uuid.dart';


class CreateBill extends StatefulWidget {
  const CreateBill({super.key});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  
  List<Contact> _availableContacts = []; 
  List<Contact> _selectedParticipants = []; 
  
  final TextEditingController _billNameController = TextEditingController();
  final TextEditingController _newParticipant = TextEditingController();
  
  String _selectedCategory = billCategories.first;
  String _myContactId = '';
  List<BillItem> _billItems = []; 
  
  late Future<void> _loadingFuture; 

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadInitialData(); 
  }
  
  Future<void> _loadInitialData() async {
    final me = await DataService.getMe();
    final contacts = await DataService.getContacts();
    
    setState(() {
      _myContactId = me.id; 
      _availableContacts = contacts;
      if (!_selectedParticipants.contains(me)) {
        _selectedParticipants.add(me);
      }
    });
  }

  double get _totalBill => _billItems.fold(0.0, (sum, item) => sum + item.price);

  void _handleNewName(String name) async {
    if (name.trim().isEmpty) return;
    final trimmedName = name.trim();
    
    final existingContact = await DataService.findContactByName(trimmedName);

    if (existingContact != null) {
        _addParticipant(existingContact);
        _newParticipant.clear();
    } else {
        _showNameMatchingDialog(trimmedName);
    }
  }

  void _addParticipant(Contact contact) {
    if (!_selectedParticipants.contains(contact)) {
        setState(() {
            _selectedParticipants.add(contact);
        });
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${contact.mainName} ถูกเลือกแล้ว')),
        );
    }
  }

  void _removeParticipant(String contactId) {
     if (contactId == _myContactId) return;
     setState(() {
        _selectedParticipants.removeWhere((p) => p.id == contactId);
        _billItems.forEach((item) {
          item.participantContactIds.remove(contactId);
        });
        _billItems.removeWhere((item) => item.participantContactIds.isEmpty);
      });
  }

  Future<void> _showNameMatchingDialog(String newName) async {
    final cs = Theme.of(context).colorScheme;
    final potentialMatches = _availableContacts
      .where((c) => c.id != _myContactId) 
      .toList();
      
    Contact? selectedContactToBind;
    
    await showDialog<void> (
        context: context,
        builder: (context) {
            return AlertDialog(
                title: const Text('ไม่พบรายชื่อ!'),
                content: SingleChildScrollView(
                    child: ListBody(
                        children: <Widget>[
                            Text('ชื่อ "$newName" ไม่ตรงกับรายชื่อหลักในสมุด'),
                            const SizedBox(height: 10),
                            
                            ElevatedButton.icon(
                                onPressed: () async {
                                    Navigator.pop(context); 
                                    const uuid = Uuid();
                                    final newContact = Contact(id: uuid.v4(), mainName: newName);
                                    await DataService.addContact(newContact);
                                    final updatedContacts = await DataService.getContacts();
                                    setState(() { _availableContacts = updatedContacts; });
                                    _addParticipant(newContact);
                                    _newParticipant.clear();
                                },
                                icon: const Icon(Icons.person_add),
                                label: const Text('บันทึกเป็นรายชื่อใหม่'),
                            ),
                            
                            const Divider(height: 30),
                            const Text('หรือผูกเป็น "ชื่ออื่นๆ" (Other Name) ของใคร?'),
                            const SizedBox(height: 10),
                            
                            DropdownButtonFormField<Contact>(
                                decoration: const InputDecoration(labelText: 'เลือกรายชื่อหลัก'),
                                value: null,
                                items: potentialMatches.map((contact) => DropdownMenuItem(
                                    value: contact,
                                    child: Text(contact.mainName),
                                )).toList(),
                                onChanged: (Contact? contact) {
                                    selectedContactToBind = contact;
                                },
                            ),
                            
                            const SizedBox(height: 15),
                            
                            ElevatedButton(
                                onPressed: () async {
                                    if (selectedContactToBind != null) {
                                        final updatedNames = List<String>.from(selectedContactToBind!.otherNames)..add(newName);
                                        final updatedContact = selectedContactToBind!.copyWith(otherNames: updatedNames);
                                        await DataService.updateContact(updatedContact);
                                        final updatedContacts = await DataService.getContacts();
                                        setState(() { _availableContacts = updatedContacts; });
                                        _addParticipant(updatedContact);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('ผูก "$newName" กับ ${updatedContact.mainName} แล้ว')),
                                        );
                                        Navigator.pop(context); 
                                        _newParticipant.clear();
                                    }
                                },
                                child: const Text('ผูกชื่อและเพิ่มเข้าร่วม'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.secondaryContainer
                                ),
                            ),
                        ],
                    ),
                ),
            );
        },
    );
  }

  void _showSummary() async {
    if (_billNameController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดตั้งชื่อบิล')),
      );
      return;
    }
    
    if (_billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเพิ่มรายการอาหารก่อน')),
      );
      return;
    }
    
    final summary = _calculateSummary();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillSummary(
          summary: summary,
          billName: _billNameController.text,
          category: _selectedCategory,
          selectedContacts: _selectedParticipants,
          billItems: _billItems,
        ),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context); 
    }
  }
  

  BillCalculation _calculateSummary() {
    Map<String, double> cost = {};
    for (var p in _selectedParticipants) {
      cost[p.mainName] = 0.0;
    }
    
    double total = 0.0;
    
    for (var item in _billItems) {
      final double costPerPerson = item.pricePerPerson;
      total += item.price;
      
      for (var contactId in item.participantContactIds) {
        final participant = _selectedParticipants.firstWhere((p) => p.id == contactId);
        cost[participant.mainName] = (cost[participant.mainName] ?? 0.0) + costPerPerson;
      }
    }
       
    return BillCalculation (participantCost: cost, total: total);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('บิลของฉัน'), 
        backgroundColor: cs.inversePrimary,
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลเริ่มต้น'));
          }
          return Column(
            children: [
              _BillHeader(cs),
              _ParticipantsList(cs),
              
              Expanded(child: _ItemsList()),
              
              _Summary(cs),
            ],
          );
        },
      ),
    );
  }
  
  Widget _BillHeader(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      color: cs.surfaceContainerHighest,
      child: Column(
        children: [
          TextFormField(
            controller: _billNameController,
            decoration: const InputDecoration(
              labelText: 'ชื่อบิล',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'หมวดหมู่',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: billCategories.map((String cat) {
              return DropdownMenuItem<String>(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _ParticipantsList(ColorScheme cs) {
    final unselectedContacts = _availableContacts
      .where((c) => !_selectedParticipants.contains(c))
      .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cs.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('รายชื่อคนที่ต้องหาร:'),
          Wrap(
            spacing: 10.0,
            children: _selectedParticipants.map((p) => Chip(
              label: Text(p.isMe ? '${p.mainName} (ฉัน)' : p.mainName),
              onDeleted: p.isMe ? null : () => _removeParticipant(p.id), 
              deleteIcon: p.isMe ? null : const Icon(Icons.close, size: 18),
            )).toList(),
          ),
          
          TextFormField(
              controller: _newParticipant,
              decoration: InputDecoration(
                  hintText: 'พิมพ์ชื่อเพื่อน/เลือกจากรายชื่อ',
                  isDense: true,
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _handleNewName(_newParticipant.text),
                  )
              ),
              onFieldSubmitted: _handleNewName,
          ),

          if (unselectedContacts.isNotEmpty) 
            TextButton.icon(
              onPressed: () async {
                final selectedContact = await showDialog<Contact>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('เลือกรายชื่อหลักที่เหลือ'),
                    children: unselectedContacts.map((contact) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, contact),
                      child: Text(contact.mainName),
                    )).toList(),
                  ),
                );
                if (selectedContact != null) {
                  _addParticipant(selectedContact);
                }
              }, 
              icon: const Icon(Icons.list_alt), 
              label: Text('เลือกจากรายชื่อหลักที่เหลือ (${unselectedContacts.length} คน)'),
            ),
        ],
      ),
    );
  }
  
  Widget _ItemsList() {
    return ListView.builder(
      itemCount: _billItems.length,
      itemBuilder: (context, index) {
        final item = _billItems[index];
        final participantsCount = item.participantContactIds.length;
        return ListTile(
          leading: const Icon(Icons.star),
          title: Text(item.name),
          subtitle: Text('${item.price.toStringAsFixed(2)} ฿ / หาร $participantsCount คน'),
          trailing: Text('${item.pricePerPerson.toStringAsFixed(2)} ฿/คน'),
          onLongPress: () {
            setState(() {
              _billItems.removeAt(index);
            });
          },
        );
      },
    );
  }
  
  Widget _Summary(ColorScheme cs) {
    return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ยอดรวมบิล: ${_totalBill.toStringAsFixed(2)} ฿',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 15),

        ElevatedButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.fastfood),
          label: const Text('เพิ่มรายการอาหาร'),
          style: ElevatedButton.styleFrom(
             backgroundColor: cs.secondaryContainer, 
             padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: _showSummary,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('สรุปและคำนวณยอด'),
        ),
      ],
    )
  );
}

  void _addItem() async {
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเพิ่มรายชื่อผู้เข้าร่วมก่อน')),
      );
      return;
    }
    
    final tempParticipants = _selectedParticipants.map((c) => 
        Participant(
            contactId: c.id, 
            name: c.mainName, 
            baseShare: 0, 
            items: [],
            isYou: c.isMe,
        )
    ).toList();
    
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddItemPage(participants: tempParticipants);
      },
    );

    if (result != null && result is BillItem) {
      setState(() {
        _billItems.add(result);
      });
    }
  }
}
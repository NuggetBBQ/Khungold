import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/services/constants.dart';
import 'package:khungold/services/data_service.dart';


class CreateSubBill extends StatefulWidget {
  const CreateSubBill({super.key});

  @override
  State<CreateSubBill> createState() => _CreateSubBillState();
}

class _CreateSubBillState extends State<CreateSubBill> {
  
  List<Subscription> _availableSubs = [];
  List<Contact> _availableContacts = [];
  Set<Subscription> _selectedSubs = {};
  List<Contact> _selectedParticipants = [];

  final String _billCategory = billCategories[1];
  String _myContactId = '';

  late Future<void> _loadingFuture; 

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadInitialData(); 
  }
  
  Future<void> _loadInitialData() async {
    final me = await DataService.getMe();
    final contacts = await DataService.getContacts();
    final subs = await DataService.getSubscriptions();
    final availableForDropdown = contacts.where((c) => c.id != me.id).toList();

    setState(() {
      _myContactId = me.id;
      _availableContacts = availableForDropdown;;
      _availableSubs = subs;
      _selectedParticipants = [me]; 
    });
  }

  double get _totalSelectedAmount {
    return _selectedSubs.fold(0.0, (sum, sub) => sum + sub.price);
  }
  
  double get _costPerPerson {
    if (_selectedParticipants.isEmpty) return 0.0;
    return _totalSelectedAmount / _selectedParticipants.length;
  }
  
  void _addParticipant(Contact contact) {
    if (!_selectedParticipants.contains(contact)) {
      setState(() {
        _selectedParticipants.add(contact);
      });
    }
  }

  void _removeParticipant(String contactId) {
     if (contactId == _myContactId) return;
     setState(() {
        _selectedParticipants.removeWhere((p) => p.id == contactId);
      });
  }

  void _showSummary() async {
    if (_selectedSubs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเลือกรายการสมาชิกก่อน')),
      );
      return;
    }

    final costPer = _costPerPerson;
    Map<String, double> costs = {};
    
    final allSubNames = _selectedSubs.map((s) => s.name).join(', ');
    final contactIds = _selectedParticipants.map((c) => c.id).toList();
    
    List<BillItem> billItems = [
      BillItem(
        name: allSubNames,
        price: _totalSelectedAmount,
        participantContactIds: contactIds,
      )
    ];

    for(var contact in _selectedParticipants){
      costs[contact.mainName] = costPer;
    }
    
    final summary = BillCalculation(
      participantCost: costs,
      total: _totalSelectedAmount,
    );
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillSummary(
          summary: summary,
          billName: 'หารค่าสมาชิก: ${allSubNames}',
          category: _billCategory,
          selectedContacts: _selectedParticipants,
          billItems: billItems,
        ),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('หารค่าสมาชิก'),
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
              _ParticipantsList(cs),
              
              Expanded(child: _SubscriptionList()),
              
              _Summary(cs),
            ],
          );
        },
      ),
    );
  }
 
  Widget _ParticipantsList(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cs.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('หมวดหมู่: $_billCategory', style: Theme.of(context).textTheme.titleSmall),
          const Divider(height: 10),
          const Text('รายชื่อคนที่หาร:'),
          Wrap(
            spacing: 10.0,
            children: _selectedParticipants.map((p) => Chip(
              label: Text(p.isMe ? '${p.mainName} (ฉัน)' : p.mainName),
              onDeleted: p.isMe ? null : () => _removeParticipant(p.id),
              deleteIcon: p.isMe ? null : const Icon(Icons.close, size: 18),
            )).toList(),
          ),
          
          DropdownButton<Contact>(
            hint: const Text('เพิ่มชื่อผู้เข้าร่วม'),
            value: null,
            items: _availableContacts 
              .where((c) => !_selectedParticipants.contains(c))
              .map((contact) => DropdownMenuItem(
                value: contact,
                child: Text(contact.mainName),
              )).toList(),
            onChanged: (Contact? newContact) {
              if (newContact != null) {
                _addParticipant(newContact);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _SubscriptionList() {
    return ListView.builder(
      itemCount: _availableSubs.length,
      itemBuilder: (context, index) {
        final sub = _availableSubs[index];
        final isSelected = _selectedSubs.contains(sub);
        
        return CheckboxListTile(
          title: Text(sub.name),
          subtitle: Text('ราคาเต็ม: ${sub.price.toStringAsFixed(2)} ฿'),
          secondary: Image.network(sub.imageUrl, width: 40, height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.subscriptions)),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedSubs.add(sub);
              } else {
                _selectedSubs.remove(sub);
              }
            });
          },
        );
      },
    );
  }

  Widget _Summary(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ยอดรวมที่เลือก: ${_totalSelectedAmount.toStringAsFixed(2)} ฿',
            textAlign: TextAlign.right,
          ),
          Text(
            'หาร ${_selectedParticipants.length} คน',
            textAlign: TextAlign.right,
          ),
          const Divider(),
          Text(
            'ยอดที่ต้องจ่ายต่อคน: ${_costPerPerson.toStringAsFixed(2)} ฿',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
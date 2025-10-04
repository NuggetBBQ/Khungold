import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/pages/p07_add_item_dialog.dart';

class CreateBill extends StatefulWidget {
  const CreateBill({super.key});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  
  List<Participant> _participants = [ 
    Participant(name: 'A', id: 'A', baseShare: 0, items: []),
    Participant(name: 'B', id: 'B', baseShare: 0, items: []),
    Participant(name: 'C', id: 'C', baseShare: 0, items: []),
  ];
 
  List<BillItem> _billItems = []; 
  
  final TextEditingController _newParticipant = TextEditingController();

  double get _totalBill => _billItems.fold(0.0, (sum, item) => sum + item.price);

  void _addParticipant(String name) {
    if (name.isEmpty) return;
    setState(() {
      _participants.add(Participant(name: name, id: name, baseShare: 0, items: []));
      _newParticipant.clear();
    });
  }

  void _removeParticipant(String id) {
     setState(() {
        _participants.removeWhere((p) => p.id == id);
        _billItems.forEach((item) {
          item.participantIds.remove(id);
        });
        _billItems.removeWhere((item) => item.participantIds.isEmpty);
      });
  }

  void _showSummary() async {
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
        builder: (context) => BillSummary(summary: summary),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context); 
    }
  }
  

  BillCalculation _calculateSummary() {
    Map<String, double> cost = {};
    for (var p in _participants) {
      cost[p.name] = 0.0;
    }
    
    double total = 0.0;
    
    for (var item in _billItems) {
      final double costPerPerson = item.pricePerPerson;
      total += item.price;
      
      for (var id in item.participantIds) {
        final participant = _participants.firstWhere((p) => p.id == id);
        cost[participant.name] = (cost[participant.name] ?? 0.0) + costPerPerson;
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
      body: Column(
        children: [
          _ParticipantsList(cs),
          
          Expanded(child: _ItemsList()),
          
          _Summary(cs),
        ],
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
          const Text('รายชื่อคนที่ต้องหาร:'),
          Wrap(
            spacing: 10.0,
            children: _participants.map((p) => Chip(
              label: Text(p.name),
              onDeleted: () => _removeParticipant(p.id),
            )).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newParticipant,
                  decoration: const InputDecoration(hintText: 'เพิ่มชื่อผู้เข้าร่วม'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _addParticipant(_newParticipant.text),
              ),
            ],
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
        final participantsCount = item.participantIds.length;
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
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเพิ่มรายชื่อผู้เข้าร่วมก่อน')),
      );
      return;
    }
    
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(participants: _participants);
      },
    );

    if (result != null && result is BillItem) {
      setState(() {
        _billItems.add(result);
      });
    }
  }
}
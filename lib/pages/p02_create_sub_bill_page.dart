import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/services/data_service.dart';


class CreateSubBill extends StatefulWidget {

  const CreateSubBill({super.key});

  @override
  State<CreateSubBill> createState() => _CreateSubBillState();
}

class _CreateSubBillState extends State<CreateSubBill> {
  final List<Subscription> _availableSubs = DataService.getSubscriptions();

  Set<Subscription> _selectedSubs = {}; 
  int _splitCount = 2; 

  double get _totalSelectedAmount {
    return _selectedSubs.fold(0.0, (sum, sub) => sum + sub.price);
  }
 
  double get _costPerPerson {
    if (_splitCount <= 0) return 0.0;
    return _totalSelectedAmount / _splitCount;
  }

  void _showSummary() async {
     if (_selectedSubs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเลือกรายการสมาชิกก่อน')),
      );
      return;
    }
    
    Map<String, double> costs = {};
    for(int i = 1; i <= _splitCount; i++){
      costs['คน $i'] = _costPerPerson;
    }
    
    final summary = BillCalculation(
      participantCost: costs,

      
      total: _totalSelectedAmount,
    );
    
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('หารค่าสมาชิก'),
        backgroundColor: cs.inversePrimary,
      ),
      body: Column(
        children: [
           _CountInput(cs),
          
           Expanded(child: _SubscriptionList()),
          
           _Summary(cs),
        ],
      ),
    );
  }
 
  Widget  _CountInput(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('จำนวนคนที่หาร:'),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: cs.error),
                onPressed: () {
                  if (_splitCount > 1) {
                    setState(() => _splitCount--);
                  }
                },
              ),
              Text('$_splitCount คน', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: cs.primary),
                onPressed: () {
                  setState(() => _splitCount++);
                },
              ),
            ],
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
          secondary: Image.network(sub.imageUrl, width: 40, height: 40),
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
import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/services/data_service.dart';

class BillSummary extends StatelessWidget {
  final BillCalculation summary;

  final String billName; 
  final String category; 
  final List<Contact> selectedContacts; 
  final List<BillItem> billItems;

  const BillSummary({
    super.key,
    required this.summary,
    required this.billName, 
    required this.category,
    required this.selectedContacts,
    required this.billItems,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปบิล'),
        backgroundColor: const Color.fromARGB(255, 132, 199, 136),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('รวมแล้วบิลนี้:', style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${summary.total.toStringAsFixed(2)} ฿',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 30),
            
            const Text('ต้องเก็บเงิน:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            
            Expanded(
              child: ListView(
                children: summary.participantCost.entries.map((entry) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                        child: Text(
                          entry.key.substring(0, 1), 
                        ),
                      ),
                      title: Text(entry.key),
                      trailing: Text('${entry.value.toStringAsFixed(2)} ฿'),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            ElevatedButton.icon(
              onPressed: () async {
                final me = await DataService.getMe();

                final bill = Bill.fromCreation(
                  title: billName,
                  owner: me,
                  selectedContacts: selectedContacts,
                  summary: summary,
                  items: billItems,
                  category: category,
                );

                await DataService.saveBill(bill, billItems);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกบิลสำเร็จแล้ว')),
                );
                Navigator.pop(context, true); 
              },
              icon: const Icon(Icons.save),
              label: const Text('บันทึก'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 165, 235, 169),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
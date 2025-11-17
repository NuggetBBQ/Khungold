import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/pages/p00_home_page.dart';
import 'package:khungold/services/data_service.dart';
import 'package:lottie/lottie.dart';

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
            const Text(
              'รวมแล้วบิลนี้:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${summary.total.toStringAsFixed(2)} ฿',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 30),

            const Text(
              'ต้องเก็บเงิน:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: summary.participantCost.entries.map((entry) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.inversePrimary,
                        child: Text(entry.key.substring(0, 1)),
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

                await DataService.addBill(bill);

                if (!context.mounted) return;

                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    });
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.network(
                            'https://lottie.host/15b5296b-e7bf-431c-9814-e39c991d5fc7/o0vBvWBFC3.json',
                            height: 120,
                            width: 120,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'บันทึกบิลเรียบร้อย!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'ระบบได้บันทึกบิลของคุณแล้ว',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).then((_) {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                });
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'บันทึกบิล',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 114, 182, 118),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

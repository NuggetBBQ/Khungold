import 'package:flutter/material.dart';
import 'package:khungold/components/billcard.dart';
import 'package:khungold/components/ui/empty_state.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/data_service.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late List<Bill> _bills;

  @override
  void initState() {
    super.initState();
    _bills = [DataService.getOwnerBill(), DataService.getPayerBill()];
  }

  double get _sumOwe => DataService.sumOwe(_bills);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('บิลทั้งหมด'),
      ),
      body: Column(
        children: [
          BillCard(
            totalAmount: _sumOwe,
            onTap: () {},
            isSummary: true,
          ),
          Expanded(
            child: _bills.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long,
                    text: 'ยังไม่มีบิล',
                  )
                : ListView.builder(
                    itemCount: _bills.length,
                    itemBuilder: (context, i) {
                      final b = _bills[i];
                      return BillCard(
                        title: b.title,
                        totalAmount: b.total,
                        yourOwe: b.yourOweDisplay(),
                        paidByYou: b.paidByYou,
                        onTap: () async {
                          final updated =
                              await Navigator.pushNamed(
                                    context,
                                    '/bill/detail',
                                    arguments: b,
                                  )
                                  as Bill?;
                          
                          if (updated != null) {
                            setState(() => _bills[i] = updated);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
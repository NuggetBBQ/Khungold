import 'package:flutter/material.dart';
import 'package:khungold/components/billcard.dart';
import 'package:khungold/components/ui/empty_state.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/data_service.dart';
import 'package:khungold/services/constants.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late Future<List<Bill>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = DataService.getBills();
  }

  Future<List<Bill>> _loadBills() async {
    final liveBills = await DataService.getBills();
    return liveBills.toList().reversed.toList();
  }

  double _getSumExpenditure(List<Bill> bills) =>
      bills.fold(0.0, (sum, b) => sum + b.myExpenditure);
  double _getSumCollect(List<Bill> bills) => bills
      .where((b) => b.ownerIsYou)
      .fold(0.0, (sum, b) => sum + b.totalToCollect);

  List<Bill> _getAllBills(List<Bill> allBills) {
    return allBills;
  }

  Widget _buildBillList(List<Bill> bills) {
    if (bills.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        text: 'ยังไม่มีบิลที่ถูกสร้าง',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: bills.length,
      itemBuilder: (context, i) {
        final b = bills[i];
        return BillCard(
          title: b.title,
          totalAmount: b.total,
          yourOwe: b.ownerIsYou ? b.totalToCollect : b.yourOweDisplay(),
          paidByYou: b.paidByYou,
          category: b.category,
          onTap: () async {
            final updated =
                await Navigator.pushNamed(context, '/bill/detail', arguments: b)
                    as Bill?;

            if (updated != null) {
              setState(() {
                _billsFuture = _loadBills();
              });
            }
          },
        );
      },
    );
  }

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
          Expanded(
            child: FutureBuilder<List<Bill>>(
              future: _billsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const EmptyState(
                    icon: Icons.error,
                    text: 'เกิดข้อผิดพลาดในการโหลดบิล',
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long,
                    text: 'ยังไม่มีบิลที่ถูกสร้าง',
                  );
                }

                final allLoadedBills = snapshot.data!;
                final sumCollect = _getSumCollect(allLoadedBills);
                final sumExpenditure = _getSumExpenditure(allLoadedBills);

                return Column(
                  children: [
                    BillCard(
                      title: 'ยอดเงินสุทธิทั้งหมด',
                      totalAmount: sumCollect,
                      yourOwe: sumCollect - sumExpenditure,
                      paidByYou: sumCollect >= sumExpenditure,
                      isSummary: true,
                      onTap: () {},
                    ),
                    Expanded(
                      child: _buildBillList(_getAllBills(allLoadedBills)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:khungold/components/billcard.dart';
import 'package:khungold/components/ui/empty_state.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/data_service.dart';
import 'package:khungold/services/constants.dart';

class PieChartMock extends StatelessWidget {
  final Map<String, double> data;
  const PieChartMock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ภาพรวมยอดเงิน (Mock Pie Chart)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...data.entries
              .where((e) => e.value > 0)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      Text('${e.value.toStringAsFixed(2)} ฿'),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 10),
          const Text(
            '*แสดงยอดที่ควรได้รับ/จ่าย แยกตามหมวดหมู่',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late Future<List<Bill>> _billsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  String _searchMode = 'Bill Title';

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

  String _getCategoryDisplay(BillCategory category) {
    final enumString = category.toString().split('.').last;
    final index = BillCategory.values.indexWhere(
      (e) => e.toString().split('.').last == enumString,
    );
    return index != -1 && index < billCategories.length
        ? billCategories[index]
        : 'อื่นๆ';
  }

  List<Bill> _getFilteredBills(List<Bill> allBills) {
    if (_currentSearchQuery.isEmpty) return allBills;

    final query = _currentSearchQuery.toLowerCase();

    return allBills.where((bill) {
      if (_searchMode == 'Bill Title') {
        return bill.title.contains(query);
      } else {
        return bill.participants.any((p) => p.name.contains(query));
      }
    }).toList();
  }

  Map<String, double> _getCategorySummary(List<Bill> allBills) {
    Map<String, double> summary = {};

    for (var bill in allBills.where((b) => b.myExpenditure > 0)) {
      final categoryName = _getCategoryDisplay(bill.category);
      summary['จ่าย (${categoryName})'] =
          (summary['จ่าย (${categoryName})'] ?? 0.0) + bill.myExpenditure;
    }

    for (var bill in allBills.where((b) => b.ownerIsYou)) {
      final categoryName = _getCategoryDisplay(bill.category);
      summary['ได้รับ (${categoryName})'] =
          (summary['ได้รับ (${categoryName})'] ?? 0.0) + bill.totalToCollect;
    }

    return summary;
  }

  Widget _buildBillList(List<Bill> bills) {
    if (bills.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        text: 'ไม่พบบิลที่ตรงตามเงื่อนไข',
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาจากชื่อบิล หรือ ชื่อคนติดเงิน',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _currentSearchQuery = '');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() => _currentSearchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: Icon(
                    _searchMode == 'Bill Title'
                        ? Icons.receipt_long
                        : Icons.person_search,
                    color: cs.primary,
                  ),
                  label: Text(
                    _searchMode == 'Bill Title' ? 'ชื่อบิล' : 'ชื่อคน',
                  ),
                  onPressed: () {
                    setState(() {
                      _searchMode = _searchMode == 'Bill Title'
                          ? 'Contact Name'
                          : 'Bill Title';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'เปลี่ยนโหมดค้นหา: ค้นจาก ${_searchMode == 'Bill Title' ? 'ชื่อบิล' : 'ชื่อคนที่เกี่ยวข้อง'}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

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
                      child: _buildBillList(_getFilteredBills(allLoadedBills)),
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

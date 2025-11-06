import 'package:flutter/material.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/services/data_service.dart';
import 'package:khungold/pages/p06_add_sub_page.dart';


class MySubList extends StatefulWidget {
  const MySubList({super.key});

  @override
  State<MySubList> createState() => _MySubListState();
}

class _MySubListState extends State<MySubList> {
  late Future<List<Subscription>> _subscriptionsFuture; 

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = DataService.getSubscriptions(); 
  }

  void _refreshData() {
    setState(() {
      _subscriptionsFuture = DataService.getSubscriptions();
    });
  }

  void _navigateToAddEditSub({Subscription? subToEdit}) async {
     final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddSub(subToEdit: subToEdit),
        ),
     );
    
    if (result == true) {
       _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสมาชิก'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Subscription>>(
        future: _subscriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายการสมาชิก'));
          }
          
          final subscriptions = snapshot.data!;
          
          return ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return SummaryItemCard(
                type: 'subscription',
                name: sub.name,
                amount: sub.price,
                imageUrl: sub.imageUrl,
                onTap: () {
                  _navigateToAddEditSub(subToEdit: sub);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditSub(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
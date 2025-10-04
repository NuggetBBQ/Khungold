import 'package:flutter/material.dart';
import 'package:khungold/components/item/summary_item_card.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/services/data_service.dart';


class MySubList extends StatefulWidget {
  const MySubList({super.key});

  @override
  State<MySubList> createState() => _MySubListState();
}

class _MySubListState extends State<MySubList> {
  List<Subscription> _subscriptions = []; 

  @override
  void initState() {
    super.initState();
    _subscriptions = DataService.getSubscriptions(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสมาชิก'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _subscriptions.length,
        itemBuilder: (context, index) {
          final sub = _subscriptions[index];
          return SummaryItemCard(
            type: 'subscription',
            name: sub.name,
            amount: sub.price,
            imageUrl: sub.imageUrl,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('แสดงรายละเอียดของ ${sub.name}')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result = await Navigator.of(context).pushNamed('/sub/add');
          
          if (result != null && result is Subscription) {
            setState(() {
              DataService.addSubscription(result);
              _subscriptions = DataService.getSubscriptions();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
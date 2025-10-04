import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/pages/p00_home_page.dart';
import 'package:khungold/pages/p01_create_bill_page.dart';
import 'package:khungold/pages/p02_create_sub_bill_page.dart';
import 'package:khungold/pages/p03_bills_list_page.dart';
import 'package:khungold/pages/p04_my_sub_list_page.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/pages/p06_add_sub_page.dart';
import 'package:khungold/pages/p08_bill_detail_owner_page.dart';
import 'package:khungold/pages/p09_bill_detail_payer_page.dart';
import 'package:khungold/pages/p99_blank_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khunthong Mini',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      
      routes: {
        '/': (_) => const HomeScreen(), 
        '/bill/new': (_) => const CreateBill(), 
        '/sub/create': (_) => const CreateSubBill(), 
        '/bills/all': (_) => const BillsPage(),
        '/subs/list': (_) => const MySubList(),
        '/sub/add': (_) => const AddSub(),     
        '/p99': (_) => const BlankPage(),
      },
      
      onGenerateRoute: (settings) {
        if (settings.name == '/bill/detail') {
          final bill = settings.arguments as Bill;
          
          if (bill.ownerIsYou) {
            return MaterialPageRoute(
              builder: (_) => BillDetailOwnerPage(bill: bill),
            );
          } else {
            return MaterialPageRoute(
              builder: (_) => BillDetailPayerPage(bill: bill),
            );
          }
        }
        
        if (settings.name == '/bill/summary') {
        }

        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}
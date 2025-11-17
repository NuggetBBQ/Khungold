import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/pages/P12_login_pages.dart';
import 'package:khungold/pages/p08_edit_contact_page.dart';
import 'package:khungold/pages/p09_bill_detail_payer_page.dart';
import 'package:khungold/pages/p13_signup_page.dart';
import 'firebase_options.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/pages/p00_home_page.dart';
import 'package:khungold/pages/p01_create_bill_page.dart';
import 'package:khungold/pages/p02_create_sub_bill_page.dart';
import 'package:khungold/pages/p03_bills_list_page.dart';
import 'package:khungold/pages/p04_my_sub_list_page.dart';
import 'package:khungold/pages/p05_bill_summary_page.dart';
import 'package:khungold/pages/p06_add_sub_page.dart';
import 'package:khungold/pages/p10_contact_list_page.dart';
import 'package:khungold/pages/p11_add_contact_page.dart';
import 'package:khungold/pages/p99_blank_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khungold/components/auth_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
      // do sign out steps in your app
    } else {
      print('User is signed in!');
      // do sign in steps in your app
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khunthong Mini',
      theme: ThemeData(
        textTheme: GoogleFonts.ibmPlexSansThaiLoopedTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/bill/new': (_) => const CreateBill(),
        '/sub/create': (_) => const CreateSubBill(),
        '/bills/all': (_) => const BillsPage(),
        '/subs/list': (_) => const MySubList(),
        '/sub/add': (_) => const AddSub(),
        '/contacts/list': (_) => const ContactListPage(),
        '/contacts/add': (_) => const AddContactPage(),
        '/signin': (_) => LoginPage(),
        '/signup': (_) => SignupPage(),
        '/p99': (_) => const BlankPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/contacts/edit') {
          final contact = settings.arguments;

          if (contact is Contact) {
            return MaterialPageRoute(
              builder: (_) => EditContactPage(contactToEdit: contact),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('ไม่พบข้อมูล Contact ที่จะแก้ไข')),
            ),
          );
        }

        if (settings.name == '/bill/detail') {
          final bill = settings.arguments as Bill;

          return MaterialPageRoute(
            builder: (_) => BillDetailPayerPage(bill: bill),
          );
        }
        return null;
      },
    );
  }
}

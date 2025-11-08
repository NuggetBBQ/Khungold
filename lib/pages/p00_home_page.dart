import 'package:flutter/material.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/services/data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> menuItems = const [
    {'label': 'สร้างบิลใหม่', 'icon': Icons.create, 'route': '/bill/new'},
    {
      'label': 'หารแอพ (Subscription)',
      'icon': Icons.rocket_launch,
      'route': '/sub/create',
    },
    {'label': 'บิลทั้งหมด', 'icon': Icons.receipt_long, 'route': '/bills/all'},
    {
      'label': 'รายการ Subscriptions',
      'icon': Icons.apps,
      'route': '/subs/list',
    },
    {
      'label': 'รายชื่อเพื่อน',
      'icon': Icons.person_2,
      'route': '/contacts/list',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: const Text('Home'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        padding: const EdgeInsets.all(12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _MenuCard(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            onTap: () => _handleNavigation(context, item['route'] as String),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Logout'),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (route == '/subs/list') {
      final subscriptionsData = DataService.getSubscriptions();
      Navigator.pushNamed(context, route, arguments: subscriptionsData);
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.inversePrimary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/services/data_service.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Future<List<Contact>> _contactsFuture; 

  @override
  void initState() {
    super.initState();
    _contactsFuture = DataService.getContacts(); 
  }

  void _loadContacts() {
    setState(() {
      _contactsFuture = DataService.getContacts(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมุดรายชื่อ'),
        backgroundColor: cs.inversePrimary,
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายชื่อ'));
          }

          final contacts = snapshot.data!;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: contact.isMe ? cs.tertiary : cs.primary,
                  foregroundColor: cs.onPrimary,
                  child: Text(contact.mainName[0]),
                ),
                title: Text(
                  contact.isMe 
                    ? '${contact.mainName} (ฉัน)'
                    : contact.mainName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: contact.otherNames.isNotEmpty 
                  ? Text('ชื่ออื่นๆ: ${contact.otherNames.join(', ')}') 
                  : null,
                
                trailing: contact.isMe 
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () async {
                        final result = await Navigator.of(context).pushNamed(
                          '/contacts/edit', 
                          arguments: contact
                        );
                        if (result == true) _loadContacts();
                      },
                    ),
                
                onTap: null, 
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/contacts/add');
          if (result == true) _loadContacts();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
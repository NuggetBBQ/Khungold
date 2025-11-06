import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  Future<List<Contact>> getContacts() async {
    final snapshot = await _db.collection('contacts').get();
    return snapshot.docs.map((doc) => Contact.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Contact> getContactById(String id) async {
    final doc = await _db.collection('contacts').doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return const Contact(id: 'Err', mainName: 'Error Contact'); 
    }
    return Contact.fromMap(doc.data()!, doc.id);
  }
  
  Future<void> addContact(Contact contact) async {
    final docId = contact.id.isEmpty ? _uuid.v4() : contact.id;
    await _db.collection('contacts').doc(docId).set(contact.copyWith(id: docId).toMap()); 
  }
  
  Future<void> updateContact(Contact updatedContact) async {
    await _db.collection('contacts').doc(updatedContact.id).update(updatedContact.toMap());
  }

  Future<List<Subscription>> getSubscriptions() async {
    final snapshot = await _db.collection('subscriptions').get();
    return snapshot.docs.map((doc) => Subscription.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<void> addSubscription(Subscription sub) async {
    final docId = sub.id.isEmpty ? _uuid.v4() : sub.id;
    await _db.collection('subscriptions').doc(docId).set(sub.toMap());
  }

  Future<void> updateSubscription(Subscription updatedSub) async {
    await _db.collection('subscriptions').doc(updatedSub.id).update(updatedSub.toMap());
  }

  Future<void> removeSubscription(String subId) async {
    await _db.collection('subscriptions').doc(subId).delete();
  }

  Future<List<Bill>> getBills() async {
    final snapshot = await _db.collection('bills').orderBy('date', descending: true).get();
    print(snapshot.docs.map((doc) => Bill.fromMap(doc.data(), doc.id)).toList());
    return snapshot.docs.map((doc) => Bill.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveBill(Bill bill, List<BillItem> items) async {
    final docId = bill.id.isEmpty ? _uuid.v4() : bill.id;
    final billToSave = bill.copyWith(id: docId, date: DateTime.now());
    
    await _db.collection('bills').doc(docId).set(billToSave.toMap());

    final batch = _db.batch();
    for (var item in items) {
      final itemDoc = _db.collection('bills').doc(docId).collection('items').doc(_uuid.v4());
      batch.set(itemDoc, item.toMap());
    }
    await batch.commit();
  }
}
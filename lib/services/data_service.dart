import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/models/subscription_models.dart';

class DataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No Firebase user is currently signed in.',
      );
    }
    return user.uid;
  }

  static DocumentReference get _userDoc => _db.collection('users').doc(_uid);

  // Contact
  static Future<List<Contact>> getContacts() async {
    final snap = await _userDoc.collection('contacts').get();
    return snap.docs
        .map((d) => Contact.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<void> addContact(Contact contact) async {
    await _userDoc.collection('contacts').add(contact.toMap());
  }

  static Future<void> updateContact(Contact updatedContact) async {
    await _userDoc
        .collection('contacts')
        .doc(updatedContact.id)
        .update(updatedContact.toMap());
  }

  static Future<Contact?> findContactByName(String name) async {
    final normalized = name.trim().toLowerCase();
    final snap = await _userDoc.collection('contacts').get();
    for (final d in snap.docs) {
      final data = d.data();
      final n = (data['mainName'] ?? data['name'] ?? '')
          .toString()
          .toLowerCase();
      final otherNames = (data['otherNames'] as List<dynamic>?)
          ?.map((e) => e.toString().toLowerCase())
          .toList();
      if (n == normalized || (otherNames?.contains(normalized) ?? false)) {
        return Contact.fromMap(data as Map<String, dynamic>, d.id);
      }
    }
    return null;
  }

  static Future<Contact> getMe() async {
    final docById = await _userDoc.collection('contacts').doc(_uid).get();
    if (docById.exists)
      return Contact.fromMap(
        docById.data()! as Map<String, dynamic>,
        docById.id,
      );

    final snap = await _userDoc.collection('contacts').get();
    for (final d in snap.docs) {
      final data = d.data() as Map<String, dynamic>;
      if (data['isMe'] == true) return Contact.fromMap(data, d.id);
    }

    if (snap.docs.isNotEmpty) {
      final d = snap.docs.first;
      return Contact.fromMap(d.data() as Map<String, dynamic>, d.id);
    }

    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email ?? '';
    final nickname = email.contains('@')
        ? email.split('@')[0]
        : (user.displayName ?? '');
    final fallback = {
      'id': _uid,
      'mainName': user.displayName ?? nickname,
      'email': email,
      'isMe': true,
    };
    return Contact.fromMap(fallback, _uid);
  }

  // Bill
  static Future<List<Bill>> getBills() async {
    final snap = await _userDoc.collection('bills').get();
    return snap.docs
        .map((d) => Bill.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<void> addBill(Bill bill) async {
    await _userDoc.collection('bills').add(bill.toMap());
  }

  static Future<void> updateBill(Bill bill) async {
    if (bill.id == null || bill.id!.isEmpty) {
      throw ArgumentError('Bill.id is required to update a bill');
    }
    await _userDoc
        .collection('bills')
        .doc(bill.id)
        .set(bill.toMap(), SetOptions(merge: true));
  }

  // Subscription
  static Future<List<Subscription>> getSubscriptions() async {
    final snap = await _userDoc.collection('subscriptions').get();
    return snap.docs
        .map(
          (d) => Subscription.fromMap(d.data() as Map<String, dynamic>, d.id),
        )
        .toList();
  }

  static Future<void> addSubscription(Subscription sub) async {
    await _userDoc.collection('subscriptions').add(sub.toMap());
  }

  static Future<void> updateSubscription(Subscription updatedSub) async {
    await _userDoc
        .collection('subscriptions')
        .doc(updatedSub.id)
        .update(updatedSub.toMap());
  }

  static Future<void> removeSubscription(String subId) async {
    await _userDoc.collection('subscriptions').doc(subId).delete();
  }
}

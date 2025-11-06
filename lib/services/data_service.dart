import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/contact_model.dart';
import 'package:khungold/models/subscription_models.dart';
import 'package:khungold/services/firestore_service.dart';

class DataService {

  static final _firestoreService = FirestoreService();
  static Future<List<Contact>> getContacts() async => await _firestoreService.getContacts();
  
  static Future<Contact> getMe() async {
    return await _firestoreService.getContactById('2cdaf39b-41a5-40bc-ab27-4b7961bc6992'); 
  }
  
  static Future<Contact?> findContactByName(String name) async {
      final lowerName = name.toLowerCase();
      final contacts = await _firestoreService.getContacts(); 
      for (final c in contacts) {
        if (c.mainName.toLowerCase() == lowerName || 
            c.otherNames.any((o) => o.toLowerCase() == lowerName)) {
            return c;
        }
      }
      return null;
  }

  static Future<List<Contact>> findPotentialContacts(String name) async {
      final contacts = await _firestoreService.getContacts();
      return contacts
          .where((c) => !c.isMe)
          .where((c) => c.mainName.toLowerCase().contains(name.toLowerCase())) 
          .toList();
  } 
  
  static Future<void> addContact(Contact contact) async => await _firestoreService.addContact(contact);
  static Future<void> updateContact(Contact updatedContact) async => await _firestoreService.updateContact(updatedContact);

  static Future<List<Subscription>> getSubscriptions() async => await _firestoreService.getSubscriptions();
  static Future<void> addSubscription(Subscription sub) async => await _firestoreService.addSubscription(sub);
  static Future<void> updateSubscription(Subscription updatedSub) async => await _firestoreService.updateSubscription(updatedSub);
  static Future<void> removeSubscription(String subId) async => await _firestoreService.removeSubscription(subId);

  static Future<List<Bill>> getBills() async => await _firestoreService.getBills();
  static Future<void> saveBill(Bill bill, List<BillItem> items) async => await _firestoreService.saveBill(bill, items);


  static double sumOwe(List<Bill> bills) {
    double s = 0.0;
    for (final b in bills) {
      if (b.ownerIsYou) continue;
      if (b.paidByYou) continue;
      s += b.yourOweDisplay();
    }
    return s;
  }
}
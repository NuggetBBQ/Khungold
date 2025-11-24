import 'package:khungold/models/contact_model.dart';
import 'package:uuid/uuid.dart';

enum BillCategory {
  food,
  subscription,
  travel,
  accommodation,
  shopping,
  others,
}

BillCategory billCategoryFromString(String value) {
  final index = [
    'food',
    'subscription',
    'travel',
    'accommodation',
    'shopping',
    'others',
  ].indexOf(value.toLowerCase());
  if (index == -1) return BillCategory.others;
  return BillCategory.values[index];
}

class Participant {
  Participant({
    required this.contactId,
    required this.name,
    required this.baseShare,
    required this.items,
    this.paid = false,
    this.isYou = false,
  });

  String contactId;
  String name;
  double baseShare;
  List<String> items;
  bool paid;
  bool isYou;

  Participant copyWith({
    String? contactId,
    String? name,
    double? baseShare,
    List<String>? items,
    bool? paid,
    bool? isYou,
  }) {
    return Participant(
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      baseShare: baseShare ?? this.baseShare,
      items: items ?? this.items,
      paid: paid ?? this.paid,
      isYou: isYou ?? this.isYou,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'name': name,
      'baseShare': baseShare,
      'items': items,
      'paid': paid,
      'isYou': isYou,
    };
  }

  factory Participant.fromMap(Map<String, dynamic> data) {
    return Participant(
      contactId: data['contactId'] as String,
      name: data['name'] as String,
      baseShare: (data['baseShare'] as num).toDouble(),
      items: List<String>.from(data['items'] ?? []),
      paid: data['paid'] as bool? ?? false,
      isYou: data['isYou'] as bool? ?? false,
    );
  }
}

class BillItem {
  final String name;
  final double price;
  final List<String> participantContactIds;

  BillItem({
    required this.name,
    required this.price,
    required this.participantContactIds,
  });

  double get pricePerPerson => participantContactIds.isEmpty
      ? 0.0
      : price / participantContactIds.length;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'participantContactIds': participantContactIds,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> data) {
    return BillItem(
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      participantContactIds: List<String>.from(
        data['participantContactIds'] ?? [],
      ),
    );
  }
}

class Bill {
  Bill({
    required this.id,
    required this.title,
    required this.date,
    required this.ownerId,
    required this.ownerName,
    required this.ownerIsYou,
    required this.participants,
    required this.participantEmails,
    required this.category,
    this.status = 'กำลังเก็บ',
    this.note,
    this.yourTip = 0.0,
  });

  String id;
  String title;
  DateTime date;
  String ownerId;
  String ownerName;
  bool ownerIsYou;
  List<Participant> participants;
  List<String> participantEmails;
  BillCategory category;
  String status;
  String? note;
  double yourTip;

  double get baseTotal => participants.fold(0.0, (p, e) => p + e.baseShare);
  double get total => baseTotal;

  double get yourBaseShare {
    final me = participants.where((e) => e.isYou).toList();
    if (me.isEmpty) return 0.0;
    return me.first.baseShare;
  }

  double get myExpenditure {
    final myParticipation = participants.firstWhere(
      (p) => p.isYou,
      orElse: () =>
          Participant(contactId: '', name: 'N/A', baseShare: 0, items: []),
    );
    if (myParticipation.paid) {
      return myParticipation.baseShare;
    }
    return 0.0;
  }

  bool get paidByYou {
    final me = participants.where((e) => e.isYou).toList();
    if (me.isEmpty) return false;
    return me.first.paid;
  }

  double yourOweDisplay() {
    if (ownerIsYou) return 0.0;
    if (paidByYou) return 0.0;
    return yourBaseShare + yourTip;
  }

  double get totalToCollect => participants
      .where((p) => !p.isYou && ownerIsYou && !p.paid)
      .fold(0.0, (sum, p) => sum + p.baseShare);

  double get totalToOwe => participants
      .where((p) => p.isYou && !ownerIsYou && !p.paid)
      .fold(0.0, (sum, p) => sum + p.baseShare);

  factory Bill.fromCreation({
    required String title,
    required Contact owner,
    required List<Contact> selectedContacts,
    required BillCalculation summary,
    required List<BillItem> items,
    required String category,
  }) {
    final List<String> emails = selectedContacts
        .map((c) => c.email)
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toList();

    final List<Participant> participants = selectedContacts.map((c) {
      final isMe = c.isMe;
      return Participant(
        contactId: c.id,
        name: c.mainName,
        baseShare: summary.participantCost[c.mainName] ?? 0.0,
        items: items
            .where((item) => item.participantContactIds.contains(c.id))
            .map((e) => e.name)
            .toList(),
        paid: false,
        isYou: isMe,
      );
    }).toList();

    return Bill(
      id: const Uuid().v4(),
      title: title,
      date: DateTime.now(),
      ownerId: owner.id,
      ownerName: owner.mainName,
      ownerIsYou: owner.isMe,
      participants: participants,
      participantEmails: emails,
      category: billCategoryFromString(category),
      status: 'กำลังเก็บ',
      note: null,
      yourTip: 0.0,
    );
  }

  Bill copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? ownerId,
    String? ownerName,
    bool? ownerIsYou,
    List<Participant>? participants,
    List<String>? participantEmails,
    BillCategory? category,
    String? status,
    String? note,
    double? yourTip,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerIsYou: ownerIsYou ?? this.ownerIsYou,
      participants: participants ?? this.participants,
      participantEmails: participantEmails ?? this.participantEmails,
      category: category ?? this.category,
      status: status ?? this.status,
      note: note ?? this.note,
      yourTip: yourTip ?? this.yourTip,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerIsYou': ownerIsYou,
      'participants': participants.map((p) => p.toMap()).toList(),
      'participantEmails': participantEmails,
      'category': category.toString().split('.').last,
      'status': status,
      'note': note,
      'yourTip': yourTip,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> data, String docId) {
    return Bill(
      id: docId,
      title: data['title'] as String,
      date: DateTime.parse(data['date'] as String),
      ownerId: data['ownerId'] as String,
      ownerName: data['ownerName'] as String,
      ownerIsYou: data['ownerIsYou'] as bool,
      participants: (data['participants'] as List<dynamic>)
          .map((p) => Participant.fromMap(p as Map<String, dynamic>))
          .toList(),
      participantEmails: List<String>.from(data['participantEmails'] ?? []),
      category: billCategoryFromString(data['category'] as String? ?? 'others'),
      status: data['status'] as String? ?? 'กำลังเก็บ',
      note: data['note'] as String?,
      yourTip: (data['yourTip'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BillCalculation {
  final Map<String, double> participantCost;
  final double total;

  BillCalculation({required this.participantCost, required this.total});
}

class Participant {
  Participant({
    required this.id, 
    required this.name,
    required this.baseShare,
    required this.items,
    this.paid = false,
    this.isYou = false,
  });
  String id;
  String name;
  double baseShare;
  List<String> items; 
  bool paid;
  bool isYou;
}

class Bill {
  Bill({
    required this.title,
    required this.date,
    required this.ownerId,
    required this.ownerName,
    required this.ownerIsYou,
    required this.participants,
    this.status = 'กำลังเก็บ',
    this.note,
    this.yourTip = 0.0,
  });
  String title;
  DateTime date;
  String ownerId;
  String ownerName;
  bool ownerIsYou;
  List<Participant> participants;
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
}

class BillItem {
  final String name;
  final double price;
  final List<String> participantIds;

  BillItem ({required this.name, required this.price, required this.participantIds});

  double get pricePerPerson => participantIds.isEmpty ? 0.0 : price / participantIds.length;
}

class BillCalculation {
  final Map<String, double> participantCost;
  final double total;

  BillCalculation({required this.participantCost, required this.total});
}
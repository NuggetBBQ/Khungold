import 'package:khungold/models/bill_models.dart';
import 'package:khungold/models/subscription_models.dart';


class DataService {
  static final Bill _ownerBill = Bill(
    title: 'ปาร์ตี้วันศุกร์',
    date: DateTime.now(),
    ownerId: 'ME',
    ownerName: 'ฉัน',
    ownerIsYou: true,
    participants: [
      Participant(id: 'ME', name: 'ฉัน', baseShare: 220.0, items: ['พิซซ่า', 'ค่าน้ำ', 'ค่าบริการ'], isYou: true),
      Participant(id: 'OM', name: 'โอม', baseShare: 340.0, items: ['พิซซ่า', 'ค่าน้ำ', 'ค่าบริการ', 'ไก่ทอด']),
      Participant(id: 'PAE', name: 'แพร', baseShare: 300.0, items: ['พิซซ่า', 'ค่าน้ำ', 'ค่าบริการ', 'ชีสเค้ก']),
    ],
  );

  static final Bill _payerBill = Bill(
    title: 'ทริปหัวหิน',
    date: DateTime.now().subtract(const Duration(days: 2)),
    ownerId: 'BAS',
    ownerName: 'บาส',
    ownerIsYou: false,
    participants: [
      Participant(id: 'ME', name: 'ฉัน', baseShare: 700.0, items: ['ที่พัก', 'ค่าน้ำมัน', 'ค่าทางด่วน'], isYou: true),
      Participant(id: 'BAS', name: 'บาส', baseShare: 1150.0, items: ['ที่พัก', 'ค่าน้ำมัน', 'ค่าทางด่วน', 'อาหารทะเล']),
      Participant(id: 'MAY', name: 'เมย์', baseShare: 1150.0, items: ['ที่พัก', 'ค่าน้ำมัน', 'ค่าทางด่วน', 'อาหารทะเล']),
    ],
  );

  static final List<Subscription> _subscriptions = [
    const Subscription(name: 'Netflix', price: 419.0, imageUrl: 'https://cdn-icons-png.flaticon.com/128/2504/2504929.png'),
    const Subscription(name: 'YouTube Premium', price: 159.0, imageUrl: 'https://cdn-icons-png.flaticon.com/128/2504/2504965.png'),
    const Subscription(name: 'Spotify Family', price: 209.0, imageUrl: 'https://cdn-icons-png.flaticon.com/128/2504/2504940.png'),
  ];
  
  static Bill getOwnerBill() => _ownerBill;
  static Bill getPayerBill() => _payerBill;
  
  static List<Subscription> getSubscriptions() => _subscriptions;
  static void addSubscription(Subscription sub) => _subscriptions.add(sub);
  
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
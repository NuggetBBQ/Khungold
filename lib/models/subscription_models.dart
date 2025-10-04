class Subscription {
  const Subscription ({
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  final String name;
  final double price;
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}
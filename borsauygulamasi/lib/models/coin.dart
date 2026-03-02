class Coin {
  final String symbol;
  final double price;
  final double change;

  Coin({required this.symbol, required this.price, required this.change});

  factory Coin.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Coin(symbol: 'Yükleniyor...', price: 0.0, change: 0.0);
    }
    return Coin(
      symbol: (json['s'] ?? '').toString(),
      price: double.tryParse(json['c'].toString()) ?? 0.0,
      change: double.tryParse(json['P'].toString()) ?? 0.0,
    );
  }
}

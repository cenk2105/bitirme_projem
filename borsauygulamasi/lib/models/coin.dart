class Coin {
  final String symbol;
  final double price;
  final double change;
  final double high;
  final double low;
  final double volume;

  // CoinGecko'dan gelecek ek alanlar (nullable - yani başta boş olabilir)
  final double? marketCap;
  final double? circulatingSupply;
  final double? ath;
  final double? atl;

  Coin({
    required this.symbol,
    required this.price,
    required this.change,
    required this.high,
    required this.low,
    required this.volume,
    this.marketCap,
    this.circulatingSupply,
    this.ath,
    this.atl,
  });

  // Binance'ten gelen veriler için mevcut factory
  factory Coin.fromJson(Map<String, dynamic>? json) {
    if (json == null)
      return Coin(symbol: '', price: 0, change: 0, high: 0, low: 0, volume: 0);
    return Coin(
      symbol: (json['s'] ?? '').toString(),
      price: double.tryParse(json['c'].toString()) ?? 0.0,
      change: double.tryParse(json['P'].toString()) ?? 0.0,
      high: double.tryParse(json['h'].toString()) ?? 0.0,
      low: double.tryParse(json['l'].toString()) ?? 0.0,
      volume: double.tryParse(json['v'].toString()) ?? 0.0,
    );
  }

  // CoinGecko verileriyle mevcut modeli kopyalayıp güncellemek için yardımcı metot
  Coin copyWith({
    double? marketCap,
    double? circulatingSupply,
    double? ath,
    double? atl,
  }) {
    return Coin(
      symbol: symbol,
      price: price,
      change: change,
      high: high,
      low: low,
      volume: volume,
      marketCap: marketCap ?? this.marketCap,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      ath: ath ?? this.ath,
      atl: atl ?? this.atl,
    );
  }
}

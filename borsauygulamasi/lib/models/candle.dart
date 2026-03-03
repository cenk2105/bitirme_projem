class CandleModel {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleModel({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // Binance API'den gelen liste formatını modele çeviriyoruz
  factory CandleModel.fromList(List<dynamic> list) {
    return CandleModel(
      date: DateTime.fromMillisecondsSinceEpoch(list[0]),
      open: double.parse(list[1].toString()),
      high: double.parse(list[2].toString()),
      low: double.parse(list[3].toString()),
      close: double.parse(list[4].toString()),
      volume: double.parse(list[5].toString()),
    );
  }
}

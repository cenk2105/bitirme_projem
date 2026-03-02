import 'dart:convert';
import 'package:borsauygulamasi/models/coin.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CoinService {
  WebSocketChannel? _channel;

  final List<String> mySelectedCoins = [
    'btcusdt',
    'ethusdt',
    'solusdt',
    'bnbusdt',
    'suiusdt',
    'xrpusdt',
    'adausdt',
    'avaxusdt',
    'linkusdt',
    'ltcusdt',
    'aptusdt',
    'trxusdt',
  ];

  Stream<List<Coin>> getStream() {
    final String streams = mySelectedCoins
        .map((coin) => '$coin@ticker')
        .join('/');

    // Web için portu kaldırıp standart adresi deniyoruz
    final String url = 'wss://stream.binance.com/stream?streams=$streams';

    _channel = WebSocketChannel.connect(Uri.parse(url));

    final Map<String, Coin> coinMap = {};

    return _channel!.stream
        .map((data) {
          final jsonResponse = jsonDecode(data.toString());

          // KRİTİK KONTROL: Eğer gelen veri 'data' içermiyorsa (onay mesajıysa) işlem yapma
          if (jsonResponse['data'] == null) {
            return coinMap.values.toList();
          }

          final coinData = jsonResponse['data'];
          final newCoin = Coin.fromJson(coinData);

          coinMap[newCoin.symbol] = newCoin;

          return coinMap.values.toList();
        })
        .handleError((error) {
          print("Stream Hatası: $error");
        })
        .asBroadcastStream();
  }

  void dispose() {
    _channel?.sink.close();
  }
}

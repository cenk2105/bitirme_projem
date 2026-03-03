import 'dart:convert';
import 'package:borsauygulamasi/models/candle.dart';
import 'package:borsauygulamasi/models/coin.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class CoinService {
  WebSocketChannel? _channel;

  // Binance sembollerini CoinGecko ID'lerine bağlayan harita (Bilgiler sekmesi için)
  final Map<String, String> _coinIdMap = {
    'BTCUSDT': 'bitcoin',
    'ETHUSDT': 'ethereum',
    'SOLUSDT': 'solana',
    'BNBUSDT': 'binancecoin',
    'SUIUSDT': 'sui',
    'XRPUSDT': 'ripple',
    'ADAUSDT': 'cardano',
    'AVAXUSDT': 'avalanche-2',
    'LINKUSDT': 'chainlink',
    'LTCUSDT': 'litecoin',
    'APTUSDT': 'aptos',
    'TRXUSDT': 'tron',
  };

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

  /// BİNANCE: Canlı Fiyat Akışı (Ticker)
  Stream<List<Coin>> getStream() {
    final String streams = mySelectedCoins
        .map((coin) => '$coin@ticker')
        .join('/');
    final String url = 'wss://stream.binance.com/stream?streams=$streams';

    _channel = WebSocketChannel.connect(Uri.parse(url));
    final Map<String, Coin> coinMap = {};

    return _channel!.stream
        .map((data) {
          final jsonResponse = jsonDecode(data.toString());

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

  /// BİNANCE: Geçmiş Mum Verileri (Grafik için)
  Future<List<CandleModel>> fetchCandles({
    required String symbol,
    required String interval,
  }) async {
    final String url =
        'https://api.binance.com/api/v3/klines?symbol=${symbol.toUpperCase()}&interval=$interval&limit=100';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => CandleModel.fromList(item))
          .toList()
          .reversed
          .toList();
    } else {
      throw Exception("Mum verileri yüklenemedi");
    }
  }

  /// COINGECKO: Piyasa Detayları (Market Cap, ATH, ATL, Arz)
  Future<Map<String, dynamic>> fetchCoinMarketData(String binanceSymbol) async {
    // Sembolü CoinGecko'nun anladığı ID'ye çeviriyoruz (Örn: BTCUSDT -> bitcoin)
    final String? coinId = _coinIdMap[binanceSymbol.toUpperCase()];

    if (coinId == null) {
      throw Exception("Bu sembol için CoinGecko ID eşleşmesi bulunamadı.");
    }

    // CoinGecko Markets API
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$coinId&order=market_cap_desc&per_page=1&page=1&sparkline=false',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0]; // İlk sonucu Map olarak döndürür
        }
        throw Exception("CoinGecko'dan boş veri döndü.");
      } else {
        throw Exception("CoinGecko hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ek bilgiler yüklenirken hata oluştu: $e");
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}

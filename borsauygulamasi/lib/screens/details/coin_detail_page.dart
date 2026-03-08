import 'package:borsauygulamasi/screens/main_screen.dart';
import 'package:borsauygulamasi/screens/market/trade_page.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:borsauygulamasi/services/coin_service.dart';
import 'package:borsauygulamasi/models/coin.dart';
// TradePage dosyanızın yolunu buraya ekleyin:
// import 'package:borsauygulamasi/screens/trade_page.dart';

class CoinDetailPage extends StatefulWidget {
  final String symbol;
  const CoinDetailPage({super.key, required this.symbol});

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  final CoinService _coinService = CoinService();
  String activeTab = "Fiyat";
  String activeInterval = "1h";
  List<Candle> candles = [];
  bool isGraphLoading = true;

  @override
  void initState() {
    super.initState();
    loadCandleData();
  }

  Future<void> loadCandleData() async {
    setState(() => isGraphLoading = true);
    try {
      final data = await _coinService.fetchCandles(
        symbol: widget.symbol,
        interval: activeInterval,
      );
      setState(() {
        candles = data
            .map(
              (e) => Candle(
                date: e.date,
                high: e.high,
                low: e.low,
                open: e.open,
                close: e.close,
                volume: e.volume,
              ),
            )
            .toList();
        isGraphLoading = false;
      });
    } catch (e) {
      print("Grafik Hatası: $e");
      setState(() => isGraphLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cleanSymbol = widget.symbol.toLowerCase().replaceAll(
      'usdt',
      '',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.amber,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'images/coins_images/$cleanSymbol.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.symbol.toUpperCase().replaceAll('USDT', ''),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.amber),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: activeTab == "Fiyat"
                ? _buildPriceSection()
                : _buildInfoSection(cleanSymbol),
          ),
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: ["Fiyat", "Bilgiler"].map((tab) {
        bool isActive = activeTab == tab;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => activeTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? Colors.amber : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.amber : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      children: [
        _buildLivePriceHeader(),
        _buildIntervalSelector(),
        Expanded(
          child: isGraphLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              : Candlesticks(candles: candles),
        ),
      ],
    );
  }

  Widget _buildLivePriceHeader() {
    return StreamBuilder<List<Coin>>(
      stream: _coinService.getStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final coin = snapshot.data!.firstWhere(
          (c) => c.symbol.toLowerCase() == widget.symbol.toLowerCase(),
          orElse: () => Coin(
            symbol: widget.symbol,
            price: 0,
            change: 0,
            high: 0,
            low: 0,
            volume: 0,
          ),
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\$${coin.price.toStringAsFixed(coin.price < 1 ? 4 : 2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${coin.change >= 0 ? '+' : ''}${coin.change.toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: coin.change >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statRow("24s Yüksek", coin.high.toStringAsFixed(2)),
                  _statRow("24s Düşük", coin.low.toStringAsFixed(2)),
                  _statRow("24s Hacim", _formatNumber(coin.volume)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String cleanSymbol) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _coinService.fetchCoinMarketData(widget.symbol),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        if (snapshot.hasError)
          return Center(
            child: Text(
              "Hata: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'images/coins_images/$cleanSymbol.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 56,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['name'] ??
                        widget.symbol.toUpperCase().replaceAll('USDT', ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _infoRow("Piyasa Değeri", "\$${_formatNumber(data['market_cap'])}"),
            _infoRow(
              "Dolaşımdaki Arz",
              "${_formatNumber(data['circulating_supply'])}",
            ),
            _infoRow("Tüm Zamanların En Yüksek (ATH)", "\$${data['ath']}"),
            _infoRow("Tüm Zamanların En Düşük (ATL)", "\$${data['atl']}"),
            _infoRow("Market Cap Sıralaması", "#${data['market_cap_rank']}"),
          ],
        );
      },
    );
  }

  Widget _buildIntervalSelector() {
    final intervals = ["1m", "5m", "15m", "1h", "4h", "1d", "1w"];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: intervals
            .map(
              (interval) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: activeInterval == interval
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  onPressed: () {
                    setState(() => activeInterval = interval);
                    loadCandleData();
                  },
                  child: Text(
                    interval,
                    style: TextStyle(
                      fontWeight: activeInterval == interval
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: activeInterval == interval
                          ? Colors.amber
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF181A20),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.amber),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(child: _actionButton("AL", Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _actionButton("SAT", Colors.red)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Text(
      "$label: $value",
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );

  Widget _actionButton(String text, Color color) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onPressed: () {
      // YÖNLENDİRME BURADA YAPILIYOR
      Navigator.pop(context, {
        "action": "navigate_to_trade",
        "symbol": widget.symbol,
        "type": text,
      });

      // 2. MainScreen'deki navigate metodunu tetikle
      // Bu işlem bir sonraki frame'de yapılmalıdır (UI çakışmaması için)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MainScreen.navigateToTrade(context, widget.symbol, text);
      });
    },
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
  );

  String _formatNumber(dynamic number) {
    if (number == null) return "0";
    double num = double.parse(number.toString());
    if (num >= 1e9) return "${(num / 1e9).toStringAsFixed(2)}B";
    if (num >= 1e6) return "${(num / 1e6).toStringAsFixed(2)}M";
    if (num >= 1e3) return "${(num / 1e3).toStringAsFixed(2)}K";
    return num.toStringAsFixed(0);
  }
}

// TradePage'i henüz oluşturmadıysanız hata almamak için geçici bir placeholder:
/*class TradePage extends StatelessWidget {
  final String symbol;
  final String initialType;
  const TradePage({super.key, required this.symbol, required this.initialType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$symbol - $initialType")),
      body: Center(
        child: Text("Trade Sayfası: $symbol için $initialType işlemi"),
      ),
    );
  }
}*/

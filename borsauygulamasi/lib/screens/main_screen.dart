import 'package:borsauygulamasi/screens/market/coinlist_page.dart';
import 'package:borsauygulamasi/screens/market/home_page.dart';
import 'package:borsauygulamasi/screens/market/trade_page.dart';
import 'package:borsauygulamasi/screens/market/wallet_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Seçilen coini ve tipi gönderen metod
  static void navigateToTrade(
    BuildContext context,
    String symbol,
    String type,
  ) {
    final _MainScreenState? state = context
        .findAncestorStateOfType<_MainScreenState>();
    if (state != null) {
      state.updateTradeDetails(symbol, type);
    }
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Başlangıçta Piyasalar (CoinList) açık olsun

  // Seçilen coin bilgilerini tutan değişkenler
  String selectedSymbol = "BTCUSDT";
  String selectedType = "AL";

  void updateTradeDetails(String symbol, String type) {
    setState(() {
      selectedSymbol = symbol;
      selectedType = type;
      _selectedIndex = 2; // Al-Sat sekmesine geç
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sayfalar listesini build içinde tanımlıyoruz ki değişkenler değiştikçe sayfalar yenilensin
    final List<Widget> _pages = [
      const NewsPage(), // 0. İndis
      CoinListScreen(), // 1. İndis
      TradePage(
        key: ValueKey(
          selectedSymbol,
        ), // Bu key sayfanın yeni coinle sıfırlanmasını sağlar
        symbol: selectedSymbol,
        initialType: selectedType,
      ), // 2. İndis
      const WalletPage(), // 3. İndis
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Piyasalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horizontal_circle),
            label: 'Al-Sat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Cüzdan'),
        ],
      ),
    );
  }
}

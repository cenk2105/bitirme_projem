import 'package:borsauygulamasi/screens/market/coinlist_page.dart';
import 'package:borsauygulamasi/screens/market/home_page.dart';
import 'package:borsauygulamasi/screens/market/trade_page.dart';
import 'package:borsauygulamasi/screens/market/wallet_page.dart';
import 'package:flutter/material.dart';
// Örnek sayfaların

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void navigateToTrade(BuildContext context) {
    final _MainScreenState? state = context
        .findAncestorStateOfType<_MainScreenState>();
    state?.updateIndex(2); // Al-Sat sekmesi 2. indiste
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Seçili sekmeyi tutar

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Sekmelere tıklandığında gösterilecek sayfalar listesi
  final List<Widget> _pages = [
    NewsPage(), // 0. İndis
    CoinListScreen(), // 1. İndis (Coin listesinin olduğu yer)
    const TradePage(symbol: "BTCUSDT", initialType: "AL"), // 2. İndis
    WalletPage(), // 3. İndis
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body kısmı seçili olan sayfayı gösterir
      body: IndexedStack(
        index: _selectedIndex,
        children:
            _pages, // Sayfaların durumunu korumak için IndexedStack iyidir
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 4 sekme için bu tip daha stabil
        backgroundColor: const Color(0xFF121212), // Senin koyu teman
        selectedItemColor: Colors.amberAccent, // Seçili ikon rengi
        unselectedItemColor: Colors.grey, // Seçili olmayan ikon rengi
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

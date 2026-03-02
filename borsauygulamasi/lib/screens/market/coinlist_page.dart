import 'package:borsauygulamasi/models/coin.dart';
import 'package:borsauygulamasi/services/coin_service.dart';
import 'package:flutter/material.dart';

enum SortType {
  none,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  changeAsc,
  changeDesc,
}

class CoinListScreen extends StatefulWidget {
  @override
  _CoinListScreenState createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final CoinService _coinService = CoinService();
  late Stream<List<Coin>> _coinStream;
  SortType _currentSort = SortType.none;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _coinStream = _coinService.getStream();
  }

  // Sıralama mantığını yöneten fonksiyon
  List<Coin> _sortCoins(List<Coin> coins) {
    List<Coin> sortedList = List.from(coins);
    switch (_currentSort) {
      case SortType.nameAsc:
        sortedList.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case SortType.nameDesc:
        sortedList.sort((a, b) => b.symbol.compareTo(a.symbol));
        break;
      case SortType.priceAsc:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceDesc:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.changeAsc:
        sortedList.sort((a, b) => a.change.compareTo(b.change));
        break;
      case SortType.changeDesc:
        sortedList.sort((a, b) => b.change.compareTo(a.change));
        break;
      default:
        break;
    }
    return sortedList;
  }

  void _toggleSort(SortType asc, SortType desc) {
    setState(() {
      if (_currentSort == asc) {
        _currentSort = desc;
      } else if (_currentSort == desc) {
        _currentSort = SortType.none;
      } else {
        _currentSort = asc;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.amberAccent,
            size: 28,
          ),
          onPressed: () {
            print("Profile git");
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Varlık Ara',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.amberAccent,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = "";
                });
              },
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Coin>>(
              stream: _coinStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Hata: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.yellow),
                  );
                }

                // --- FİLTRELEME VE SIRALAMA MANTIĞI ---
                final allCoins = snapshot.data!;

                // 1. Arama sorgusuna göre filtrele (Sembol içindeki USDT'yi temizleyip bakıyoruz)
                final filteredCoins = allCoins.where((coin) {
                  final cleanName = coin.symbol
                      .replaceAll('USDT', '')
                      .toLowerCase();
                  return cleanName.contains(_searchQuery);
                }).toList();

                // 2. Filtrelenmiş listeyi seçili kritere göre sırala
                final sortedCoins = _sortCoins(filteredCoins);

                // Eğer arama sonucunda kimse kalmadıysa kullanıcıya bilgi ver
                if (sortedCoins.isEmpty) {
                  return const Center(
                    child: Text(
                      'Varlık bulunamadı',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sortedCoins.length,
                  itemBuilder: (context, index) {
                    return _buildCoinRow(sortedCoins[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _toggleSort(SortType.nameAsc, SortType.nameDesc),
              child: _headerText(
                "İsim",
                _currentSort == SortType.nameAsc,
                _currentSort == SortType.nameDesc,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _toggleSort(SortType.priceAsc, SortType.priceDesc),
              child: _headerText(
                "Fiyat",
                _currentSort == SortType.priceAsc,
                _currentSort == SortType.priceDesc,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _toggleSort(SortType.changeAsc, SortType.changeDesc),
              child: _headerText(
                "24s Değişim",
                _currentSort == SortType.changeAsc,
                _currentSort == SortType.changeDesc,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(
    String title,
    bool isAsc,
    bool isDesc, {
    TextAlign textAlign = TextAlign.left,
  }) {
    return Row(
      mainAxisAlignment: textAlign == TextAlign.right
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          isAsc
              ? Icons.arrow_drop_up
              : (isDesc ? Icons.arrow_drop_down : Icons.unfold_more),
          size: 16,
          color: (isAsc || isDesc) ? Colors.yellow : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildCoinRow(Coin coin) {
    final bool isPositive = coin.change >= 0;
    final String cleanSymbol = coin.symbol.replaceAll('USDT', '').toLowerCase();

    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'images/coins_images/$cleanSymbol.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            coin.symbol[0],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  coin.symbol.replaceAll('USDT', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${coin.price.toStringAsFixed(coin.price < 1 ? 4 : 2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${coin.change.toStringAsFixed(2)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _coinService.dispose();
    super.dispose();
  }
}

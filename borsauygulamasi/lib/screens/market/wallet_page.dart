import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:borsauygulamasi/services/coin_service.dart';
import 'package:borsauygulamasi/models/coin.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _balanceController = TextEditingController();
  final CoinService _coinService = CoinService();

  Future<void> _setInitialBalance() async {
    double? amount = double.tryParse(_balanceController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Geçerli bir miktar girin")));
      return;
    }

    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'balance': amount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text("Cüzdanım", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Hata oluştu"));
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          double balance = (userData?['balance'] ?? 0).toDouble();

          if (balance == 0) {
            return _buildInitialBalanceSetup();
          }

          return _buildPortfolioUI(balance);
        },
      ),
    );
  }

  Widget _buildInitialBalanceSetup() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),
          const Text(
            "Hoş Geldiniz!\nSimülasyona başlamak için başlangıç bakiyenizi belirleyin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Örn: 10000",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _setInitialBalance,
            child: const Text(
              "Bakiyeyi Tanımla",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioUI(double balance) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kullanılabilir Bakiye",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                "\$${balance.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                "Varlıklarım",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('portfolio')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              var docs = snapshot.data!.docs;

              if (docs.isEmpty)
                return const Center(
                  child: Text(
                    "Henüz varlığınız yok.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return _buildPortfolioItem(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioItem(Map<String, dynamic> data) {
    String symbol = data['symbol'];
    double amount = (data['amount'] ?? 0).toDouble();
    double buyPrice = (data['buyPrice'] ?? 0).toDouble();

    String ticker = symbol.replaceAll('USDT', '').toLowerCase();

    return StreamBuilder<List<Coin>>(
      stream: _coinService.getStream(),
      builder: (context, snapshot) {
        double currentPrice = 0;

        // --- HATA ÇÖZÜMÜ BURADA ---
        if (snapshot.hasData && snapshot.data != null) {
          // firstWhere yerine iterable'ı filtreleyip güvenli bir şekilde alıyoruz
          final matchingCoins = snapshot.data!.where((c) => c.symbol == symbol);
          if (matchingCoins.isNotEmpty) {
            currentPrice = matchingCoins.first.price;
          } else {
            // Eğer servis listesinde bu coin yoksa, maliyet fiyatını veya 0'ı kullanabiliriz
            currentPrice = 0;
          }
        }

        double pnl = (currentPrice - buyPrice) * amount;
        bool isProfit = pnl >= 0;

        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'images/coins_images/$ticker.png',
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text(
                    symbol[0],
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                );
              },
            ),
          ),
          title: Text(
            symbol,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "Miktar: ${amount.toStringAsFixed(4)}",
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${(amount * currentPrice).toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${isProfit ? '+' : ''}${pnl.toStringAsFixed(2)} \$",
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

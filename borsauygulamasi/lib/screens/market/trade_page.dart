import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:borsauygulamasi/services/coin_service.dart';
import 'package:borsauygulamasi/models/coin.dart';

class TradePage extends StatefulWidget {
  final String symbol;
  final String initialType;

  const TradePage({super.key, required this.symbol, required this.initialType});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final CoinService _coinService = CoinService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  late String activeType;
  double _currentPrice = 0;

  @override
  void initState() {
    super.initState();
    activeType = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  // Hesaplama: $Toplam = Miktar \times Fiyat$
  void _updateTotal(String value) {
    if (value.isEmpty) {
      _totalController.clear();
      return;
    }
    double? amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount != null && _currentPrice > 0) {
      setState(() {
        _totalController.text = (amount * _currentPrice).toStringAsFixed(2);
      });
    }
  }

  void _updateAmount(String value) {
    if (value.isEmpty) {
      _amountController.clear();
      return;
    }
    double? total = double.tryParse(value.replaceAll(',', '.'));
    if (total != null && _currentPrice > 0) {
      setState(() {
        _amountController.text = (total / _currentPrice).toStringAsFixed(6);
      });
    }
  }

  // --- DINAMIK ALIM SATIM FONKSIYONU ---
  Future<void> _processTrade() async {
    double? amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    double? total = double.tryParse(_totalController.text.replaceAll(',', '.'));

    if (amount == null || amount <= 0) {
      _showSnackBar("Geçerli bir miktar girin", Colors.orange);
      return;
    }

    String uid = _auth.currentUser!.uid;
    DocumentReference userRef = _firestore.collection('users').doc(uid);

    // İŞTE SİHİRLİ SATIR: doc(widget.symbol) sayesinde otomatik klasörleme yapar
    DocumentReference portfolioRef = userRef
        .collection('portfolio')
        .doc(widget.symbol);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnap = await transaction.get(userRef);
        double currentBalance =
            (userSnap.data() as Map<String, dynamic>)['balance']?.toDouble() ??
            0.0;

        if (activeType == "AL") {
          if (currentBalance >= total!) {
            // 1. Bakiyeyi Düş (Sayısal İşlem)
            transaction.update(userRef, {'balance': currentBalance - total});

            // 2. Portföyü Güncelle (Number Tiplerini Kullanarak)
            transaction.set(portfolioRef, {
              'symbol': widget.symbol,
              'amount': FieldValue.increment(amount), // Üstüne ekler (Sayı)
              'totalCost': FieldValue.increment(
                total,
              ), // Maliyeti toplar (Sayı)
              'buyPrice': _currentPrice, // O anki fiyat (Sayı)
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } else {
            throw Exception("Yetersiz Bakiye!");
          }
        } else {
          // SATIŞ MANTIĞI
          DocumentSnapshot portSnap = await transaction.get(portfolioRef);
          double ownedAmount =
              (portSnap.data() as Map?)?['amount']?.toDouble() ?? 0.0;

          if (ownedAmount >= amount) {
            transaction.update(userRef, {'balance': currentBalance + total!});
            if (ownedAmount == amount) {
              transaction.delete(portfolioRef); // Hepsi satıldıysa dökümanı sil
            } else {
              transaction.update(portfolioRef, {
                'amount': ownedAmount - amount,
              });
            }
          } else {
            throw Exception("Yetersiz Coin!");
          }
        }
      });
      _showSnackBar("İşlem Başarılı!", Colors.green);
      _amountController.clear();
      _totalController.clear();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Al-Sat İşlemi"),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<Coin>>(
        stream: _coinService.getStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final coin = snapshot.data!.firstWhere(
            (c) => c.symbol.toLowerCase() == widget.symbol.toLowerCase(),
          );
          _currentPrice = coin.price;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceHeader(coin),
                const SizedBox(height: 20),
                _buildLiveBalance(),
                const SizedBox(height: 30),
                _buildTradeToggles(),
                const SizedBox(height: 40),
                _buildLabel("Miktar (${widget.symbol.replaceAll('USDT', '')})"),
                _buildInputField(
                  _amountController,
                  "0.00",
                  widget.symbol.replaceAll('USDT', ''),
                  _updateTotal,
                ),
                const SizedBox(height: 20),
                _buildLabel("Toplam Tutar (USD)"),
                _buildInputField(
                  _totalController,
                  "0.00",
                  "USD",
                  _updateAmount,
                ),
                const SizedBox(height: 40),
                _buildActionButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Widgetları ---

  Widget _buildPriceHeader(Coin coin) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        widget.symbol.toUpperCase(),
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "\$${coin.price.toStringAsFixed(2)}",
        style: TextStyle(
          fontSize: 24,
          color: coin.change >= 0 ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
    ],
  );

  Widget _buildLiveBalance() => StreamBuilder<DocumentSnapshot>(
    stream: _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots(),
    builder: (context, snap) {
      double bal = (snap.data?.data() as Map?)?['balance']?.toDouble() ?? 0.0;
      return Text(
        "Bakiye: \$${bal.toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.amber),
      );
    },
  );

  Widget _buildTradeToggles() => Row(
    children: [
      Expanded(child: _buildBtn("AL", Colors.green, activeType == "AL")),
      const SizedBox(width: 10),
      Expanded(child: _buildBtn("SAT", Colors.red, activeType == "SAT")),
    ],
  );

  Widget _buildBtn(String label, Color color, bool sel) => GestureDetector(
    onTap: () => setState(() {
      activeType = label;
      _amountController.clear();
      _totalController.clear();
    }),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: sel ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: sel ? color : Colors.white12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
  );

  Widget _buildInputField(
    TextEditingController ctrl,
    String hint,
    String suffix,
    Function(String) onCh,
  ) => TextField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: Colors.white),
    onChanged: onCh,
    decoration: InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.amber),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildActionButton() => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: _processTrade,
      style: ElevatedButton.styleFrom(
        backgroundColor: activeType == "AL" ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        "$activeType GERÇEKLEŞTİR",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

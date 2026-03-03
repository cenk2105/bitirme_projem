import 'package:flutter/material.dart';

class TradePage extends StatefulWidget {
  // Bu iki satırı ekle:
  final String symbol;
  final String initialType;

  // Constructor'ı bu şekilde güncelle:
  const TradePage({super.key, required this.symbol, required this.initialType});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  // Sayfa içinde bu verilere erişmek için widget.symbol ve widget.initialType kullanacaksın
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.symbol} - ${widget.initialType}")),
      body: Center(child: Text("Coin: ${widget.symbol}")),
    );
  }
}

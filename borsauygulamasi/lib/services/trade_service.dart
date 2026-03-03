import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ALIM İŞLEMİ
  Future<String?> buyCoin(
    String symbol,
    double amountInUsdt,
    double currentPrice,
  ) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final portfolioRef = userRef
          .collection('portfolio')
          .doc(symbol.toLowerCase());

      // 1. Bakiyeyi kontrol et
      final userDoc = await userRef.get();
      double balance = userDoc['balance']?.toDouble() ?? 0.0;

      if (balance < amountInUsdt) return "Yetersiz bakiye!";

      // 2. İşlemi gerçekleştir (Batch ile güvenli kayıt)
      WriteBatch batch = _firestore.batch();

      // Bakiyeyi düşür
      batch.update(userRef, {'balance': balance - amountInUsdt});

      // Portföye ekle
      double coinAmount = amountInUsdt / currentPrice;
      batch.set(portfolioRef, {
        'symbol': symbol,
        'amount': FieldValue.increment(coinAmount), // Mevcut miktara ekle
        'buyPrice': currentPrice, // Son alış fiyatı (maliyet takibi için)
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      return null; // Başarılı
    } catch (e) {
      return e.toString();
    }
  }

  // SATIŞ İŞLEMİ
  Future<String?> sellCoin(String symbol, double currentPrice) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final portfolioRef = userRef
          .collection('portfolio')
          .doc(symbol.toLowerCase());

      final portDoc = await portfolioRef.get();
      if (!portDoc.exists) return "Elinizde bu varlık yok!";

      double amount = portDoc['amount'].toDouble();
      double returnUsdt = amount * currentPrice;

      WriteBatch batch = _firestore.batch();

      batch.update(userRef, {'balance': FieldValue.increment(returnUsdt)});
      batch.delete(portfolioRef); // Hepsini satıyoruz

      await batch.commit();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Giriş Yap
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e; // Hatayı UI kısmında yakalamak için fırlatıyoruz
    }
  }

  // Kayıt Ol
  Future<UserCredential?> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kayıt başarılıysa Firestore'da kullanıcı dokümanını oluştur
      await _firestore.collection('users').doc(res.user!.uid).set({
        'uid': res.user!.uid,
        'email': email,
        'username': username,
        'balance': 0, // Başlangıçta 0, WalletPage'de sorulacak
        'createdAt': FieldValue.serverTimestamp(),
      });

      return res;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Şifre Sıfırlama E-postası Gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

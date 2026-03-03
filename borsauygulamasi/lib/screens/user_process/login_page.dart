import 'package:borsauygulamasi/screens/main_screen.dart';
import 'package:borsauygulamasi/screens/user_process/changepassword_page.dart';
import 'package:borsauygulamasi/screens/user_process/signup_page.dart';
import 'package:borsauygulamasi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(155, 159, 163, 1.0),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Text(
                'Hoşgeldiniz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 40),

              // E-posta TextField
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E-posta',
                  hintStyle: TextStyle(color: Colors.grey[200]),
                  prefixIcon: Icon(Icons.email, color: Colors.amberAccent),
                  filled: true,
                  fillColor: Colors.black87,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Şifre TextField
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Şifre',
                  hintStyle: TextStyle(color: Colors.grey[200]),
                  prefixIcon: Icon(Icons.lock, color: Colors.amberAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.black87,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Şifremi unuttum
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(),
                      ),
                    );
                  },
                  child: Text(
                    'Şifremi unuttum?',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Giriş Yap Butonu
              ElevatedButton(
                onPressed: () async {
                  // Basit bir boşluk kontrolü
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
                    );
                    return;
                  }

                  try {
                    // Firebase girişi başlat
                    await _authService.signIn(
                      emailController.text,
                      passwordController.text,
                    );

                    // Başarılıysa yönlendir
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    // Hata durumunda kullanıcıya mesaj göster
                    String mesaj = "Giriş başarısız";
                    if (e.code == 'user-not-found')
                      mesaj = "Kullanıcı bulunamadı.";
                    else if (e.code == 'wrong-password')
                      mesaj = "Hatalı şifre.";
                    else if (e.code == 'invalid-email')
                      mesaj = "Geçersiz e-posta formatı.";

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(mesaj),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Hesabın yok mu? ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Kayıt Ol',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

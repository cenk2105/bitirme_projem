import 'package:borsauygulamasi/screens/main_screen.dart';
import 'package:borsauygulamasi/screens/user_process/changepassword_page.dart';
import 'package:borsauygulamasi/screens/user_process/login_page.dart';
import 'package:borsauygulamasi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState(); // İsimlendirme standardı için düzenlendi
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  // 1. Şifre doğrulama için AYRI bir kontrolcü ekledik
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  // 2. Şifre doğrulama görünürlüğü için AYRI bir değişken ekledik
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    // Kontrolcüleri bellekten temizlemek her zaman iyi bir pratiktir
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(155, 159, 163, 1.0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.amberAccent),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kayıt Ol',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                controller: usernameController,
                hintText: 'Kullanıcı Adı...',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              // E-posta Alanı
              _buildTextField(
                controller: emailController,
                hintText: 'E-posta...',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Şifre Alanı
              _buildPasswordField(
                controller: passwordController,
                hintText: 'Şifre...',
                isObscured: obscurePassword,
                onToggle: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Şifre Doğrulama Alanı (Düzeltilen Kısım)
              _buildPasswordField(
                controller: confirmPasswordController, // Ayrı kontrolcü
                hintText: 'Şifreyi Doğrula...',
                isObscured: obscureConfirmPassword, // Ayrı görünürlük durumu
                onToggle: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),

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
                  child: const Text(
                    'Şifremi unuttum?',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  // 1. Alanların boş olup olmadığını kontrol et
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lütfen tüm alanları doldurun!"),
                      ),
                    );
                    return;
                  }

                  // 2. Şifrelerin eşleştiğini kontrol et (Zaten eklemiştin, pekiştirelim)
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Şifreler uyuşmuyor!")),
                    );
                    return;
                  }

                  try {
                    // 3. Kayıt işlemini başlat
                    await _authService.signUp(
                      emailController.text.trim(), // Gereksiz boşlukları siler
                      passwordController.text,
                      usernameController.text.trim(),
                    );

                    // 4. Başarılıysa ana ekrana yönlendir
                    if (mounted) {
                      // Context hala geçerli mi kontrolü
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    // 5. Firebase'den gelen hataları kullanıcıya göster
                    String mesaj = "Kayıt sırasında bir hata oluştu.";

                    if (e.code == 'email-already-in-use') {
                      mesaj = "Bu e-posta adresi zaten kullanımda.";
                    } else if (e.code == 'weak-password') {
                      mesaj = "Şifre çok zayıf (en az 6 karakter olmalı).";
                    } else if (e.code == 'invalid-email') {
                      mesaj = "Geçersiz e-posta formatı.";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(mesaj),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    print(e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Kayıt Ol', // Giriş Yap metni Kayıt Ol ile değiştirildi
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kod tekrarını önlemek için TextField'ları fonksiyonlaştırdım
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[200]),
        prefixIcon: Icon(icon, color: Colors.amberAccent),
        filled: true,
        fillColor: Colors.black87,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[200]),
        prefixIcon: const Icon(Icons.lock, color: Colors.amberAccent),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[400],
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

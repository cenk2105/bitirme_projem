import 'package:flutter/material.dart';
import 'package:borsauygulamasi/services/auth_service.dart'; // AuthService dosyanı import et

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService(); // Servis nesnesi oluşturuldu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: const Color.fromRGBO(155, 159, 163, 1.0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              const Text(
                'Şifreyi Sıfırla',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "E-posta adresinize şifre yenileme bağlantısı gönderilecektir. Lütfen e-postanızı kontrol edin.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // E-posta TextField
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E-posta',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.amberAccent,
                  ),
                  filled: true,
                  fillColor: Colors.black87,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bağlantı Gönder Butonu
              ElevatedButton(
                onPressed: () async {
                  String email = emailController.text.trim();

                  if (email.isEmpty) {
                    _showMessage(
                      "Lütfen e-posta adresinizi girin.",
                      isError: true,
                    );
                    return;
                  }

                  try {
                    // Firebase servisini çağır
                    await _authService.sendPasswordResetEmail(email);

                    if (!mounted) return;

                    _showMessage("Sıfırlama bağlantısı gönderildi!");

                    // İşlem başarılıysa 2 saniye sonra sayfadan çık
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) Navigator.pop(context);
                    });
                  } catch (e) {
                    _showMessage("Hata oluştu: ${e.toString()}", isError: true);
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
                  'Bağlantı Gönder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kullanıcıya geri bildirim veren SnackBar metodu
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

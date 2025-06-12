import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '2.1.0.1_CekiciBireyselGiris_Sayfasi.dart';

class CekiciGirisBireyselSifreYenileme extends StatefulWidget {
  const CekiciGirisBireyselSifreYenileme({super.key});

  @override
  State<CekiciGirisBireyselSifreYenileme> createState() => _SifreYenilemeState();
}

class _SifreYenilemeState extends State<CekiciGirisBireyselSifreYenileme> {
  final _ePostaController = TextEditingController();
  final _kodController = TextEditingController();
  final _plakaNoController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  final _yeniSifreTekrarController = TextEditingController();

  bool _kodGonderildi = false;
  bool _kodDogrulandi = false;
  bool _sifreGizli = true;

  void _toggleSifreGizle() {
    setState(() => _sifreGizli = !_sifreGizli);
  }

  Future<void> _kodGonder() async {
    if (_ePostaController.text.isEmpty) {
      _showSnackBar('Lütfen bireysel e-posta adresinizi giriniz');
      return;
    }

    final response = await http.post(
      Uri.parse('https://localhost:7187/api/Kullanici/kodgondergiris'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ePosta': _ePostaController.text}),
    );

    if (response.statusCode == 200) {
      setState(() => _kodGonderildi = true);
      _showSnackBar('Doğrulama kodu e-posta adresinize gönderildi');
    } else {
      _showSnackBar('Kod gönderilemedi. Lütfen e-posta adresinizi kontrol edin.');
    }
  }

  Future<void> _koduDogrula() async {
    if (_kodController.text.isEmpty) {
      _showSnackBar('Lütfen doğrulama kodunu giriniz');
      return;
    }

    final response = await http.post(
      Uri.parse('https://localhost:7187/api/Kullanici/koddogrulagiris'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ePosta': _ePostaController.text,
        'kod': _kodController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() => _kodDogrulandi = true);
      _showSnackBar('Kod doğrulandı. Lütfen plaka ve yeni şifrenizi giriniz.');
    } else {
      _showSnackBar('Kod yanlış veya süresi dolmuş. Lütfen tekrar deneyin.');
    }
  }

  Future<void> _sifreyiYenile() async {
    if (_plakaNoController.text.isEmpty) {
      _showSnackBar('Lütfen plaka numaranızı giriniz');
      return;
    }

    if (_yeniSifreController.text != _yeniSifreTekrarController.text) {
      _showSnackBar('Şifreler uyuşmuyor');
      return;
    }

    if (_yeniSifreController.text.length < 6) {
      _showSnackBar('Şifre en az 6 karakter olmalıdır');
      return;
    }

    final response = await http.post(
      Uri.parse('https://localhost:7187/api/Cekici/sifreyiYenileBireysel'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ePosta': _ePostaController.text,
        'plakaNo': _plakaNoController.text,
        'yeniSifre': _yeniSifreController.text,
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar('Şifreniz başarıyla güncellendi');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CekiciGirisBireysel()),
      );
    } else {
      _showSnackBar('Şifre güncellenemedi. Plaka bilgisini kontrol ediniz.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Çekici Bireysel Şifre Yenile', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/ACeTa_Logo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Bireysel Şifre Yenileme",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_ePostaController, "Bireysel E-Posta", Icons.business),
                  const SizedBox(height: 16),
                  
                  if (!_kodGonderildi)
                    _buildActionButton("Kod Gönder", _kodGonder, icon: Icons.send)
                  else if (!_kodDogrulandi) ...[
                    _buildTextField(_kodController, "Doğrulama Kodu", Icons.verified_user),
                    const SizedBox(height: 16),
                    _buildActionButton("Kodu Doğrula", _koduDogrula, icon: Icons.verified),
                  ] else ...[
                    _buildTextField(_plakaNoController, "Plaka No", Icons.directions_car),
                    const SizedBox(height: 16),
                    _buildPasswordField(_yeniSifreController, "Yeni Şifre", Icons.lock),
                    const SizedBox(height: 16),
                    _buildPasswordField(_yeniSifreTekrarController, "Şifre Tekrar", Icons.lock_outline),
                    const SizedBox(height: 24),
                    _buildActionButton("Şifreyi Güncelle", _sifreyiYenile, icon: Icons.refresh),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      obscureText: _sifreGizli,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        suffixIcon: IconButton(
          icon: Icon(
            _sifreGizli ? Icons.visibility : Icons.visibility_off,
            color: Colors.blueGrey,
          ),
          onPressed: _toggleSifreGizle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 20),
            if (icon != null) const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ePostaController.dispose();
    _kodController.dispose();
    _plakaNoController.dispose();
    _yeniSifreController.dispose();
    _yeniSifreTekrarController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '2.1.0.2.1_CekiciFirmaSifreYenile_Sayfasi.dart';
import '2.1.1.2_CekiciFirmaKayit_Sayfasi.dart';
import '2.1.0.3_CekiciAna_Sayfasi.dart';

class CekiciGirisFirma extends StatefulWidget {
  final String? ePosta;

  const CekiciGirisFirma({super.key, this.ePosta});

  @override
  _CekiciGirisFirmaState createState() => _CekiciGirisFirmaState();
}

class _CekiciGirisFirmaState extends State<CekiciGirisFirma> {
  final _formKey = GlobalKey<FormState>();
  final _plakaNoController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://localhost:7187/api/Cekici/girisfirma'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plakaNo': _plakaNoController.text,
          'sifre': _sifreController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CekiciAnaSayfasi(
              cekiciData: data,
              ePosta: widget.ePosta,
            ),
          ),
        );
        _showSnackBar('Başarıyla giriş yapıldı!', Colors.green);
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? 'Giriş başarısız', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Bağlantı hatası: ${e.toString()}', Colors.orange);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.deepPurple[400]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Firma Çekici Giriş', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ve Başlık
              Column(
                children: [
                  const Icon(Icons.local_shipping, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 20),
                  Text(
                    'Firma Çekici Girişi',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  Text(
                    'Firma hesabınıza giriş yapın',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Giriş Formu
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Plaka No
                    _buildInputField(
                      controller: _plakaNoController,
                      label: 'Plaka No',
                      icon: Icons.car_rental,
                      validator: (v) => v == null || v.isEmpty ? 'Lütfen plakanızı giriniz' : null,
                    ),

                    // Şifre
                    _buildInputField(
                      controller: _sifreController,
                      label: 'Şifre',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      validator: (v) => v == null || v.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[500],
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    // Şifremi Unuttum
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CekiciGirisFirmaSifreYenileme(),
                          ),
                        ),
                        child: Text(
                          'Şifremi unuttum?',
                          style: GoogleFonts.poppins(
                            color: Colors.deepPurple[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Giriş Yap Butonu
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _girisYap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'GİRİŞ YAP',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Kayıt Ol Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hesabınız yok mu?',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CekiciKayitFirma(),
                      ),
                    ),
                    child: Text(
                      'Kayıt Ol',
                      style: GoogleFonts.poppins(
                        color: Colors.deepPurple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plakaNoController.dispose();
    _sifreController.dispose();
    super.dispose();
  }
}
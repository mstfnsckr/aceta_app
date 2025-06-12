import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '1.1_KullaniciKayit_Sayfasi.dart';
import '1.2_KullaniciGiris_Sayfasi.dart';

class KullaniciKGPage extends StatelessWidget {
  const KullaniciKGPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/ACeTa_Logo.jpg',
                  height: 140,
                ),
                const SizedBox(height: 30),

                // Uygulama İsmi
                Text(
                  'ACeTa',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aracını güvenle emanet et.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GirisPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Giriş Yap',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KayitPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.deepPurple[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kayıt Ol',
                      style: GoogleFonts.poppins(
                        color: Colors.deepPurple[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

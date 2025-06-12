import 'package:flutter/material.dart';
import 'pages/1.0_Kullanici_KG.dart'; // Sayfaları pages klasöründen import ediyoruz

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AÇeTa Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const KullaniciKGPage(), // Doğrudan giriş sayfasını kullanıyoruz
    );
  }
}
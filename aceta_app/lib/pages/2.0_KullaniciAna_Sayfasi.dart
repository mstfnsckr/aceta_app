import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '2.1.0.1_CekiciBireyselGiris_Sayfasi.dart';
import '2.1.0.2_CekiciFirmaGiris_Sayfasi.dart';
import '2.1.1.1_CekiciBireyselKayit_Sayfasi.dart';
import '2.1.1.2_CekiciFirmaKayit_Sayfasi.dart';
import '2.1.2_CekiciBul_Sayfasi.dart';
import '2.2.0.1_TamirciBireyselGiris_Sayfasi.dart';
import '2.2.0.2_TamirciFirmaGiris_Sayfasi.dart';
import '2.2.1.1_TamirciBireyselKayit_Sayfasi.dart';
import '2.2.1.2_TamirciFirmaKayit_Sayfasi.dart';
import '2.2.2_TamirciBul_Sayfasi.dart';
import '2.1.3_KullaniciAracKayit_Sayfasi.dart';
import '2.2.3_KullaniciAracListe_Sayfasi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AnaSayfa extends StatefulWidget {
  final String? ePosta;
  final int? kullaniciId;

  const AnaSayfa({super.key, this.ePosta, this.kullaniciId});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int? _kullaniciId;
  List<dynamic> _yorumBekleyenRandevular = [];
  bool _yorumDialogGoster = false;
  int? _aktifRandevuId;
  String? _aktifRandevuTipi;
  String? _aktifRandevuAdi;
  final TextEditingController _yorumController = TextEditingController();
  double _secilenPuan = 0;

  @override
  void initState() {
    super.initState();
    _kullaniciId = widget.kullaniciId;
    if (widget.ePosta != null && _kullaniciId == null) {
      _fetchKullaniciId(widget.ePosta!);
    } else {
      _checkYorumBekleyenRandevular();
    }
  }

  Future<void> _fetchKullaniciId(String ePosta) async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Kullanici/GetByePosta?EPosta=$ePosta'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _kullaniciId = data['id'];
        });
        await _checkYorumBekleyenRandevular();
      }
    } catch (e) {
      print('Kullanıcı ID alınırken hata: $e');
    }
  }

  Future<void> _checkYorumBekleyenRandevular() async {
    if (_kullaniciId == null) return;

    try {
      final cekiciResponse = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/yorum-bekleyen-randevular/$_kullaniciId'),
      );
      final tamirciResponse = await http.get(
        Uri.parse('https://localhost:7187/api/Tamirci/yorum-bekleyen-randevular/$_kullaniciId'),
      );

      List<dynamic> tumRandevular = [];
      
      if (cekiciResponse.statusCode == 200) {
        tumRandevular.addAll(json.decode(cekiciResponse.body));
      }
      if (tamirciResponse.statusCode == 200) {
        tumRandevular.addAll(json.decode(tamirciResponse.body));
      }

      setState(() {
        _yorumBekleyenRandevular = tumRandevular;
        if (tumRandevular.isNotEmpty) {
          _showYorumDialog(tumRandevular.first);
        }
      });
    } catch (e) {
      print('Yorum bekleyen randevular alınamadı: $e');
    }
  }

  void _showYorumDialog(Map<String, dynamic> randevu) {
    setState(() {
      _aktifRandevuId = randevu['id'];
      _aktifRandevuTipi = randevu['tip'];
      _aktifRandevuAdi = randevu['ad'];
      _yorumDialogGoster = true;
      _secilenPuan = 0;
    });
  }

  Future<void> _yorumGonder() async {
    if (_aktifRandevuId == null || _yorumController.text.isEmpty || _secilenPuan == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yorumunuzu yazın ve puan verin!')),
      );
      return;
    }

    try {
      final String url;
      if (_aktifRandevuTipi == "Bireysel" || _aktifRandevuTipi == "Firma") {
        url = 'https://localhost:7187/api/Randevu/yorum-ekle/$_aktifRandevuId';
      } else if (_aktifRandevuTipi == "TamirciBireysel" || _aktifRandevuTipi == "TamirciFirma") {
        url = 'https://localhost:7187/api/Tamirci/yorum-ekle/$_aktifRandevuId';
      } else {
        throw Exception("Geçersiz randevu tipi");
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'yorum': _yorumController.text,
          'puan': _secilenPuan.toInt(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumunuz ve puanınız başarıyla gönderildi!')),
        );
        setState(() {
          _yorumBekleyenRandevular.removeWhere((r) => r['id'] == _aktifRandevuId);
          _yorumDialogGoster = false;
          _yorumController.clear();
          _secilenPuan = 0;
        });
        
        if (_yorumBekleyenRandevular.isNotEmpty) {
          _showYorumDialog(_yorumBekleyenRandevular.first);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teknik bir sorun oluştu: $e')),
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required Function onPressed,
    double size = 50,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: size, color: color),
          onPressed: () => onPressed(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSecimEkrani(String title, List<Map<String, dynamic>> options, Color primaryColor) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black54,
                    offset: const Offset(4, 4),),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => option['page']),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(option['icon'] ?? Icons.person, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        option['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('ACETA', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan (Sol turuncu, sağ mavi)
          Row(
            children: [
              Expanded(child: Container(color: Colors.orange.shade300)),
              Expanded(child: Container(color: Colors.cyan.shade300)),
            ],
          ),

          // Merkez Daire (Yukarı kaydırıldı)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(5, 5),),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logo
                    Positioned(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/ACeTa_Logo.jpg',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Çekici Kayıt (Üst Sol)
                    Positioned(
                      top: 30,
                      left: 70,
                      child: _buildIconButton(
                        icon: Icons.person_add,
                        label: 'Çekici Kayıt',
                        color: Colors.orange.shade700,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildSecimEkrani(
                              'Çekici Kayıt Türü Seçin',
                              [
                                {
                                  'title': 'Bireysel Kayıt',
                                  'page': const CekiciKayitBireysel(),
                                  'icon': Icons.person,
                                },
                                {
                                  'title': 'Firma Kayıt',
                                  'page': const CekiciKayitFirma(),
                                  'icon': Icons.business,
                                },
                              ],
                              Colors.orange.shade700,
                            ),
                          );
                        },
                      ),
                    ),

                    // Tamirci Kayıt (Üst Sağ)
                    Positioned(
                      top: 30,
                      right: 70,
                      child: _buildIconButton(
                        icon: Icons.person_add,
                        label: 'Tamirci Kayıt',
                        color: Colors.cyan.shade700,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildSecimEkrani(
                              'Tamirci Kayıt Türü Seçin',
                              [
                                {
                                  'title': 'Bireysel Kayıt',
                                  'page': const TamirciKayitBireysel(),
                                  'icon': Icons.person,
                                },
                                {
                                  'title': 'Firma Kayıt',
                                  'page': const TamirciKayitFirma(),
                                  'icon': Icons.business,
                                },
                              ],
                              Colors.cyan.shade700,
                            ),
                          );
                        },
                      ),
                    ),

                    // Çekici Giriş (Sol Orta)
                    Positioned(
                      left: 15,
                      child: _buildIconButton(
                        icon: Icons.car_repair,
                        label: 'Çekici Giriş',
                        color: Colors.orange.shade700,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildSecimEkrani(
                              'Çekici Giriş Türü Seçin',
                              [
                                {
                                  'title': 'Bireysel Giriş',
                                  'page': CekiciGirisBireysel(ePosta: widget.ePosta),
                                  'icon': Icons.person,
                                },
                                {
                                  'title': 'Firma Giriş',
                                  'page': CekiciGirisFirma(ePosta: widget.ePosta),
                                  'icon': Icons.business,
                                },
                              ],
                              Colors.orange.shade700,
                            ),
                          );
                        },
                      ),
                    ),

                    // Tamirci Giriş (Sağ Orta)
                    Positioned(
                      right: 15,
                      child: _buildIconButton(
                        icon: Icons.build,
                        label: 'Tamirci Giriş',
                        color: Colors.cyan.shade700,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildSecimEkrani(
                              'Tamirci Giriş Türü Seçin',
                              [
                                {
                                  'title': 'Bireysel Giriş',
                                  'page': TamirciGirisBireysel(ePosta: widget.ePosta),
                                  'icon': Icons.person,
                                },
                                {
                                  'title': 'Firma Giriş',
                                  'page': TamirciGirisFirma(ePosta: widget.ePosta),
                                  'icon': Icons.business,
                                },
                              ],
                              Colors.cyan.shade700,
                            ),
                          );
                        },
                      ),
                    ),

                    // Araç Kayıt (Alt Sol)
                    Positioned(
                      bottom: 35,
                      left: 70,
                      child: _buildIconButton(
                        icon: Icons.directions_car,
                        label: 'Araç Kayıt',
                        color: Colors.orange.shade700,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AracKayit(),
                            ),
                          );
                        },
                      ),
                    ),

                    // Araç Listem (Alt Sağ)
                    Positioned(
                      bottom: 35,
                      right: 70,
                      child: _buildIconButton(
                        icon: Icons.list_alt,
                        label: 'Araç Listem',
                        color: Colors.cyan.shade700,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AracListem(ePosta: widget.ePosta),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Alt Butonlar (Büyük Çekici Bul ve Tamirci Bul butonları)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Çekici Bul Butonu (Sola yaslı ve büyük)
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: _buildIconButton(
                    icon: Icons.map,
                    label: 'Çekici Bul',
                    color: Colors.white, // Beyaz renk
                    size: 84,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CekiciBul(
                            kullaniciId: _kullaniciId,
                            ePosta: widget.ePosta,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tamirci Bul Butonu (Sağa yaslı ve büyük)
                Padding(
                  padding: const EdgeInsets.only(right: 45),
                  child: _buildIconButton(
                    icon: Icons.map,
                    label: 'Tamirci Bul',
                    color: Colors.white, // Beyaz renk
                    size: 84,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TamirciBul(
                            kullaniciId: _kullaniciId,
                            ePosta: widget.ePosta,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Yorum Dialog'u
          if (_yorumDialogGoster && _aktifRandevuAdi != null)
            AlertDialog(
              title: Text("$_aktifRandevuAdi Hakkında Yorumunuz"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Lütfen hizmet kalitesini değerlendirin:"),
                  const SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 40,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _secilenPuan = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Yorumunuz:"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _yorumController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Yorumunuzu buraya yazın...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _yorumDialogGoster = false),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  onPressed: _yorumGonder,
                  child: const Text('Gönder'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
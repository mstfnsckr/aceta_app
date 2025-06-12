import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class Cekici {
  final int id;
  final String adSoyad;
  final String tip;
  final LatLng konum;
  final double mesafe;
  final double ucretKm;
  final String plakaNo;
  final String telefon;
  String randevuDurumu;
  int? randevuId;
  final double puanOrtalamasi;
  List<Yorum> yorumlar;

  Cekici({
    required this.id,
    required this.adSoyad,
    required this.tip,
    required this.konum,
    required this.mesafe,
    required this.ucretKm,
    required this.plakaNo,
    required this.telefon,
    this.randevuDurumu = 'Yok',
    this.randevuId,
    required this.puanOrtalamasi,
    this.yorumlar = const [],
  });
}

class Yorum {
  final String kullaniciAdi;
  final String yorum;
  final int puan;
  final DateTime tarih;

  Yorum({
    required this.kullaniciAdi,
    required this.yorum,
    required this.puan,
    required this.tarih,
  });
}

class Arac {
  final int id;
  final String plakaNo;
  final String aracTuru;
  final String aracMarkasi;
  final String aracModeli;
  final String aracYili;

  Arac({
    required this.id,
    required this.plakaNo,
    required this.aracTuru,
    required this.aracMarkasi,
    required this.aracModeli,
    required this.aracYili,
  });

  @override
  String toString() {
    return '$aracMarkasi $aracModeli ($plakaNo)';
  }
}

class CekiciBul extends StatefulWidget {
  final int? kullaniciId;
  final String? ePosta;

  const CekiciBul({Key? key, this.kullaniciId, this.ePosta}) : super(key: key);

  @override
  _CekiciBulState createState() => _CekiciBulState();
}

class _CekiciBulState extends State<CekiciBul> {
  Position? _currentPosition;
  List<Cekici> _cekiciler = [];
  List<Arac> _araclar = [];
  bool _loading = true;
  final MapController _mapController = MapController();
  bool _showList = false;
  Cekici? _selectedCekici;
  Arac? _selectedArac;
  String? _tc;
  int _currentStep = 0;
  String _siralamaKriteri = 'mesafe';
  
  bool _isTracking = false;
  Timer? _trackingTimer;
  LatLng? _cekiciKonum;
  int? _activeRandevuId;
  Timer? _randevuStatusTimer;

  // Color scheme
  final Color _primaryColor = Color(0xFF2A6F97);
  final Color _primaryLight = Color(0xFF61A5C2);
  final Color _secondaryColor = Color(0xFF6C757D);
  final Color _accentColor = Color(0xFF5E60CE);
  final Color _successColor = Color(0xFF4CC9F0);
  final Color _dangerColor = Color(0xFFF72585);
  final Color _warningColor = Color(0xFFF8961E);
  final Color _lightBackground = Color(0xFFF8F9FA);
  final Color _darkText = Color(0xFF212529);
  final Color _lightText = Color(0xFFADB5BD);
  final Color _cardBackground = Colors.white;
  final Color _mapButtonColor = Colors.white;

  // Text styles
  final TextStyle _titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.white.withOpacity(0.9),
  );
  
  final TextStyle _cardTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  final TextStyle _cardSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey.shade600,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.ePosta != null) {
      _getUserInfo(widget.ePosta!);
    }
    _checkActiveAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _isMobile = _screenWidth < 600;
    _isTablet = _screenWidth >= 600 && _screenWidth < 1200;
    _isDesktop = _screenWidth >= 1200;
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _randevuStatusTimer?.cancel();
    super.dispose();
  }

  late bool _isMobile;
  late bool _isTablet;
  late bool _isDesktop;
  late double _screenWidth;
  late double _screenHeight;

  Future<void> _checkActiveAppointments() async {
    if (widget.kullaniciId == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/kullanici-randevular?kullaniciId=${widget.kullaniciId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> randevular = json.decode(response.body);
        final activeAppointment = randevular.firstWhere(
          (randevu) => randevu['durum'] == 'HareketeGeçildi',
          orElse: () => null,
        );

        if (activeAppointment != null) {
          setState(() {
            _activeRandevuId = activeAppointment['id'];
          });
          _startTracking(_activeRandevuId!);
        }
      }
    } catch (e) {
      debugPrint('Aktif randevu kontrol hatası: $e');
    }
  }

  void _startTracking(int randevuId) {
    _stopTracking();
    setState(() {
      _isTracking = true;
      _activeRandevuId = randevuId;
    });
    
    _trackingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('https://localhost:7187/api/Randevu/takip-bilgisi/$randevuId'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final konumStr = data['cekiciKonum']?.toString();
          if (konumStr != null) {
            final parts = konumStr.split(',');
            if (parts.length == 2) {
              setState(() {
                _cekiciKonum = LatLng(
                  double.parse(parts[0]),
                  double.parse(parts[1]),
                );
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Takip hatası: $e');
      }
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    setState(() {
      _isTracking = false;
      _cekiciKonum = null;
      _activeRandevuId = null;
    });
  }

  Future<void> _getUserInfo(String ePosta) async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Kullanici/GetByEPosta?EPosta=$ePosta'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tc = data['TC'] ?? data['tc'];
        });
        if (_tc != null) {
          await _getAraclar(_tc!);
        }
      } else {
        debugPrint('Kullanıcı bilgisi alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Kullanıcı bilgisi alınamadı: $e');
    }
  }

  Future<void> _getAraclar(String tc) async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Arac/GetByTC?TC=$tc'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _araclar = data.map((arac) => Arac(
            id: arac['id'],
            plakaNo: arac['plakaNo'],
            aracTuru: arac['aracTuru'],
            aracMarkasi: arac['aracMarkasi'],
            aracModeli: arac['aracModeli'],
            aracYili: arac['aracYili'],
          )).toList();
          _loading = false;
        });
      } else {
        debugPrint('Araçlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Araçlar alınamadı: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _currentStep = 1;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Konum alınamadı: $e');
    }
  }

  Future<double> _getPuanOrtalamasi(int? bireyselId, int? firmaId) async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/puan-ortalamasi?'
          '${bireyselId != null ? 'bireyselId=$bireyselId' : 'firmaId=$firmaId'}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['ortalama'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Puan ortalaması alınamadı: $e');
      return 0.0;
    }
  }

  Future<List<Yorum>> _getYorumlar(int? bireyselId, int? firmaId) async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/yorumlar?'
          '${bireyselId != null ? 'bireyselId=$bireyselId' : 'firmaId=$firmaId'}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((yorum) => Yorum(
          kullaniciAdi: yorum['kullaniciAdi'] ?? 'Anonim',
          yorum: yorum['yorum'] ?? '',
          puan: yorum['puan'] ?? 0,
          tarih: DateTime.parse(yorum['tarih']),),
        ).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Yorumlar alınamadı: $e');
      return [];
    }
  }

  Future<void> _fetchCekiciler() async {
    try {
      String url = 'https://localhost:7187/api/Cekici/aktif-cekiciler';
      
      if (_selectedArac != null) {
        final aracResponse = await http.get(
          Uri.parse('https://localhost:7187/api/Arac/GetAracTuru/${_selectedArac!.id}'),
        );

        if (aracResponse.statusCode == 200) {
          final aracData = json.decode(aracResponse.body);
          final aracTuru = aracData['aracTuru'];
          if (aracTuru != null) {
            url += '?aracTuru=$aracTuru';
          }
        }
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        List<Cekici> cekiciler = [];
        for (var cekici in data) {
          double puanOrtalamasi = await _getPuanOrtalamasi(
            cekici['tip'] == 'Bireysel' ? cekici['id'] : null,
            cekici['tip'] == 'Firma' ? cekici['id'] : null,
          );

          List<Yorum> yorumlar = await _getYorumlar(
            cekici['tip'] == 'Bireysel' ? cekici['id'] : null,
            cekici['tip'] == 'Firma' ? cekici['id'] : null,
          );

          if (_selectedArac == null) {
            cekiciler.add(Cekici(
              id: cekici['id'] ?? 0,
              adSoyad: cekici['adSoyad'] ?? 'İsimsiz Çekici',
              tip: cekici['tip'] ?? 'Belirsiz Tip',
              konum: LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              ),
              mesafe: _calculateDistance(LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              )),
              ucretKm: (cekici['ucretKm'] as num?)?.toDouble() ?? 0.0,
              plakaNo: cekici['plakaNo'] ?? 'Plaka Yok',
              telefon: cekici['telefon'] ?? 'Telefon Yok',
              puanOrtalamasi: puanOrtalamasi,
              yorumlar: yorumlar,
            ));
            continue;
          }

          final statusResponse = await http.get(
            Uri.parse('https://localhost:7187/api/Randevu/randevu-durumu/${cekici['id']}/${cekici['tip']}/${_selectedArac!.id}'),
          );

          if (statusResponse.statusCode == 200) {
            final statusData = json.decode(statusResponse.body);
            cekiciler.add(Cekici(
              id: cekici['id'] ?? 0,
              adSoyad: cekici['adSoyad'] ?? 'İsimsiz Çekici',
              tip: cekici['tip'] ?? 'Belirsiz Tip',
              konum: LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              ),
              mesafe: _calculateDistance(LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              )),
              ucretKm: (cekici['ucretKm'] as num?)?.toDouble() ?? 0.0,
              plakaNo: cekici['plakaNo'] ?? 'Plaka Yok',
              telefon: cekici['telefon'] ?? 'Telefon Yok',
              randevuDurumu: statusData['durum'] ?? 'Yok',
              randevuId: statusData['randevuId'],
              puanOrtalamasi: puanOrtalamasi,
              yorumlar: yorumlar,
            ));
          } else {
            cekiciler.add(Cekici(
              id: cekici['id'] ?? 0,
              adSoyad: cekici['adSoyad'] ?? 'İsimsiz Çekici',
              tip: cekici['tip'] ?? 'Belirsiz Tip',
              konum: LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              ),
              mesafe: _calculateDistance(LatLng(
                (cekici['enlem'] as num?)?.toDouble() ?? 0.0,
                (cekici['boylam'] as num?)?.toDouble() ?? 0.0,
              )),
              ucretKm: (cekici['ucretKm'] as num?)?.toDouble() ?? 0.0,
              plakaNo: cekici['plakaNo'] ?? 'Plaka Yok',
              telefon: cekici['telefon'] ?? 'Telefon Yok',
              puanOrtalamasi: puanOrtalamasi,
              yorumlar: yorumlar,
            ));
          }
        }

        setState(() {
          _cekiciler = _siralaCekiciler(cekiciler);
          _loading = false;
          _currentStep = 2;
        });

        _randevuStatusTimer?.cancel();
        _randevuStatusTimer = Timer.periodic(Duration(seconds: 15), (timer) {
          _fetchCekiciler();
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çekiciler yüklenirken hata oluştu: $e'),
          backgroundColor: _dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  List<Cekici> _siralaCekiciler(List<Cekici> cekiciler) {
    switch (_siralamaKriteri) {
      case 'ucret':
        return cekiciler..sort((a, b) => a.ucretKm.compareTo(b.ucretKm));
      case 'puan':
        return cekiciler..sort((a, b) => b.puanOrtalamasi.compareTo(a.puanOrtalamasi));
      case 'mesafe':
      default:
        return cekiciler..sort((a, b) => a.mesafe.compareTo(b.mesafe));
    }
  }

  double _calculateDistance(LatLng konum) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      konum.latitude,
      konum.longitude,
    ) / 1000;
  }

  Future<void> _cekiciCagir(Cekici cekici) async {
    if (widget.kullaniciId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı bilgisi bulunamadı. Lütfen giriş yapın.'),
          backgroundColor: _dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_selectedArac == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir araç seçin.'),
          backgroundColor: _warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://localhost:7187/api/Randevu/olustur'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cekiciId': cekici.id,
          'cekiciTipi': cekici.tip,
          'kullaniciId': widget.kullaniciId,
          'aracId': _selectedArac!.id,
          'kullaniciKonum': '${_currentPosition!.latitude},${_currentPosition!.longitude}',
          'cekiciKonum': '${cekici.konum.latitude},${cekici.konum.longitude}',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cekici.adSoyad} başarıyla çağrı isteği gönderildi'),
            backgroundColor: _successColor,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          _selectedCekici = null;
        });
        await _fetchCekiciler();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bu aracınız için bu çekiciye zaten bir çağrı isteğiniz var'),
            backgroundColor: _warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: _dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildYorumlarListesi(List<Yorum> yorumlar) {
    if (yorumlar.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Henüz yorum yapılmamış',
            style: TextStyle(
              color: _secondaryColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: yorumlar.length,
      itemBuilder: (context, index) {
        final yorum = yorumlar[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      yorum.kullaniciAdi,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          yorum.puan.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  yorum.yorum,
                  style: TextStyle(
                    fontSize: 15,
                    color: _darkText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${yorum.tarih.day}.${yorum.tarih.month}.${yorum.tarih.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _lightText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCekiciDetails(BuildContext context, Cekici cekici) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: _isMobile ? 16 : 24,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _isMobile ? _screenWidth * 0.9 : 500,
            maxHeight: _screenHeight * 0.8,
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık ve bilgi kısmı
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cekici.tip == 'Bireysel' ? Icons.person : Icons.business,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cekici.adSoyad,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  cekici.tip,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  cekici.puanOrtalamasi.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Sekmeler
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          tabs: [
                            Tab(text: 'Bilgiler'),
                            Tab(text: 'Yorumlar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // İçerik alanı
                Expanded(
                  child: TabBarView(
                    children: [
                      // Bilgiler sekmesi
                      SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.confirmation_number, 'Plaka: ${cekici.plakaNo}'),
                            _buildDetailRow(Icons.phone, 'Telefon: ${cekici.telefon}'),
                            _buildDetailRow(Icons.directions_car, 'Mesafe: ${cekici.mesafe.toStringAsFixed(1)} km'),
                            _buildDetailRow(Icons.attach_money, 'Ücret: ${cekici.ucretKm.toStringAsFixed(2)} ₺/km'),
                            SizedBox(height: 20),
                            Text(
                              'Seçilen Araç:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _lightBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _selectedArac?.toString() ?? 'Araç seçilmedi',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _darkText,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            if (cekici.randevuDurumu != 'Yok')
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(cekici.randevuDurumu).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(cekici.randevuDurumu),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getStatusIcon(cekici.randevuDurumu),
                                      color: _getStatusColor(cekici.randevuDurumu),
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      _getStatusText(cekici.randevuDurumu),
                                      style: TextStyle(
                                        color: _getStatusColor(cekici.randevuDurumu),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Yorumlar sekmesi
                      _buildYorumlarListesi(cekici.yorumlar),
                    ],
                  ),
                ),
                // Butonlar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Kapat',
                          style: TextStyle(
                            color: _secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: _secondaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      if (cekici.randevuDurumu == 'Yok')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cekiciCagir(cekici);
                          },
                          child: Text(
                            'Çağrı Gönder',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      if (cekici.randevuDurumu == 'HareketeGeçildi' && cekici.randevuId != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startTracking(cekici.randevuId!);
                          },
                          child: Text(
                            'Konumu İzle',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: _primaryColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: _darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OnayBekliyor':
        return _warningColor;
      case 'Onaylandı':
        return _primaryColor;
      case 'HareketeGeçildi':
        return _successColor;
      case 'Tamamlandı':
        return _accentColor;
      case 'Reddedildi':
        return _dangerColor;
      default:
        return _secondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OnayBekliyor':
        return Icons.access_time;
      case 'Onaylandı':
        return Icons.check_circle;
      case 'HareketeGeçildi':
        return Icons.directions_car;
      case 'Tamamlandı':
        return Icons.done_all;
      case 'Reddedildi':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OnayBekliyor':
        return 'Onay Bekliyor';
      case 'Onaylandı':
        return 'Onaylandı';
      case 'HareketeGeçildi':
        return 'Harekete Geçildi';
      case 'Tamamlandı':
        return 'Tamamlandı';
      case 'Reddedildi':
        return 'Reddedildi';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getMarkerColor(Cekici cekici) {
    return cekici.tip == 'Bireysel' ? _primaryColor : _accentColor;
  }

  Widget _buildAracSelectionStep() {
  return Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth > 600;

        return Column(
          children: [
            // Üst bilgi kartı
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 40,
                horizontal: isWide ? maxWidth * 0.2 : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 48,
                    color: _primaryColor,
                  ),
                  SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Araç Seçimi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Çekici çağrısı yapmak için bir araç seçin',
                          style: TextStyle(
                            fontSize: 16,
                            color: _primaryColor.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Araç listesi bölümü
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? maxWidth * 0.1 : 16,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 800,
                    ),
                    child: _araclar.isEmpty
                        ? _buildNoVehicleUI()
                        : Column(
                            children: [
                              if (_selectedArac != null)
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 16),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _primaryLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _primaryLight.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: _primaryColor),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Seçilen Araç',
                                            style: TextStyle(
                                              color: _primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _selectedArac!.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _araclar.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: _buildVehicleCard(_araclar[index]),
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // Buton bölümü
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? maxWidth * 0.2 : 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedArac != null ? _onCekiciBulPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Çekici Bul',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildNoVehicleUI() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Tüm içeriği ortala
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: _secondaryColor,
          ),
          SizedBox(height: 24),
          Text(
            'Kayıtlı aracınız bulunamadı',
            style: TextStyle(
              fontSize: 20, // Boyutu biraz büyüttük
              fontWeight: FontWeight.bold,
              color: _darkText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Profil sayfanızdan araç ekleyebilirsiniz',
            style: TextStyle(
              fontSize: 16,
              color: _lightText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Profili Görüntüle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: BorderSide(color: _primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildVehicleCard(Arac arac) {
  final isSelected = _selectedArac?.id == arac.id;
  
  return Card(
    elevation: isSelected ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedArac = arac),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: _primaryColor,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${arac.aracMarkasi} ${arac.aracModeli}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    arac.plakaNo,
                    style: TextStyle(
                      color: _lightText,
                    ),
                  ),
                ],
              ),
            ),
            Radio<Arac>(
              value: arac,
              groupValue: _selectedArac,
              activeColor: _primaryColor,
              onChanged: (value) => setState(() => _selectedArac = value),
            ),
          ],
        ),
      ),
    ),
  );
}

void _onCekiciBulPressed() {
  setState(() => _loading = true);
  _fetchCekiciler();
}

  Widget _buildSiralamaSecici() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sıralama Kriteri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _siralamaKriteri,
            items: [
              DropdownMenuItem(
                value: 'mesafe',
                child: Text('En Yakın'),
              ),
              DropdownMenuItem(
                value: 'ucret',
                child: Text('En Uygun Fiyat'),
              ),
              DropdownMenuItem(
                value: 'puan',
                child: Text('En Yüksek Puan'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _siralamaKriteri = value!;
                _cekiciler = _siralaCekiciler(_cekiciler);
              });
              Navigator.pop(context);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(
              fontSize: 16,
              color: _darkText,
            ),
          ),
          SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _secondaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: _secondaryColor,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCekiciSelectionStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        width: 60,
                        height: 60,
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_pin_circle,
                            color: _primaryColor,
                            size: 48,
                          ),
                        ),
                      ),
                    if (_cekiciKonum != null && _isTracking)
                      Marker(
                        point: _cekiciKonum!,
                        width: 60,
                        height: 60,
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            color: _accentColor,
                            size: 48,
                          ),
                        ),
                      ),
                    ..._cekiciler.map((cekici) => Marker(
                      point: cekici.konum,
                      width: 50,
                      height: 50,
                      builder: (ctx) => GestureDetector(
                        onTap: () => _showCekiciDetails(context, cekici),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            cekici.tip == 'Bireysel' ? Icons.person : Icons.business,
                            color: _getMarkerColor(cekici),
                            size: 30,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
            if ((_showList && _cekiciler.isNotEmpty) || isWide)
              Positioned(
                top: 16,
                left: isWide ? null : 16,
                right: isWide ? 16 : 16,
                width: isWide ? constraints.maxWidth * 0.35 : null,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Yakındaki Çekiciler',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_cekiciler.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!isWide)
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => setState(() => _showList = false),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sırala:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: _siralamaKriteri,
                              underline: Container(),
                              icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'mesafe',
                                  child: Text('En Yakın'),
                                ),
                                DropdownMenuItem(
                                  value: 'ucret',
                                  child: Text('En Uygun Fiyat'),
                                ),
                                DropdownMenuItem(
                                  value: 'puan',
                                  child: Text('En Yüksek Puan'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _siralamaKriteri = value!;
                                  _cekiciler = _siralaCekiciler(_cekiciler);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: isWide 
                              ? constraints.maxHeight * 0.8
                              : constraints.maxHeight * 0.6,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _cekiciler.length,
                          itemBuilder: (context, index) {
                            final cekici = _cekiciler[index];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _zoomToCekici(cekici);
                                  _showCekiciDetails(context, cekici);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getMarkerColor(cekici).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          cekici.tip == 'Bireysel' ? Icons.person : Icons.business,
                                          color: _getMarkerColor(cekici),
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cekici.adSoyad,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: _lightText,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${cekici.mesafe.toStringAsFixed(1)} km',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: _lightText,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  '• ${cekici.tip}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: _lightText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  cekici.puanOrtalamasi.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Icon(
                                                  Icons.attach_money,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${cekici.ucretKm.toStringAsFixed(2)} ₺/km',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: _primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                child: Icon(Icons.my_location, size: 28),
                backgroundColor: _mapButtonColor,
                foregroundColor: _primaryColor,
                elevation: 4,
                onPressed: () {
                  _mapController.move(
                    LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    12.0,
                  );
                },
              ),
            ),
            if (_selectedCekici != null)
              Positioned(
                bottom: 20,
                left: 20,
                child: FloatingActionButton(
                  child: Icon(Icons.call, size: 28),
                  backgroundColor: _successColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    _showCekiciDetails(context, _selectedCekici!);
                  },
                ),
              ),
            if (_activeRandevuId != null)
              Positioned(
                bottom: 90,
                left: 20,
                child: FloatingActionButton(
                  child: Icon(
                    _isTracking ? Icons.stop : Icons.track_changes,
                    size: 28,
                  ),
                  backgroundColor: _isTracking ? _dangerColor : _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    if (_isTracking) {
                      _stopTracking();
                    } else {
                      _startTracking(_activeRandevuId!);
                    }
                  },
                ),
              ),
            Positioned(
              bottom: 20,
              left: 90,
              child: FloatingActionButton(
                child: Icon(Icons.directions_car, size: 28),
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: () {
                  setState(() {
                    _selectedArac = null;
                    _currentStep = 1;
                    _randevuStatusTimer?.cancel();
                  });
                },
                tooltip: 'Aracı Değiştir',
              ),
            ),
            if (!_showList && !isWide)
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.list),
                  backgroundColor: _mapButtonColor,
                  foregroundColor: _primaryColor,
                  elevation: 4,
                  onPressed: () {
                    setState(() {
                      _showList = true;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _zoomToCekici(Cekici cekici) {
    _mapController.move(cekici.konum, 14.0);
    setState(() {
      _selectedCekici = cekici;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Çekici Bul', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: _primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Yükleniyor...',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : _currentPosition == null && _currentStep == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 60,
                        color: _secondaryColor,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Konum bilgisi alınamadı',
                        style: TextStyle(
                          color: _darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Konum izinlerini kontrol edin',
                        style: TextStyle(
                          color: _lightText,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text(
                          'Tekrar Dene',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _currentStep == 1
                  ? _buildAracSelectionStep()
                  : _buildCekiciSelectionStep(),
    );
  }
}
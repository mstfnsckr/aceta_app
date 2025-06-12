import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

class CekiciRandevuSayfasi extends StatefulWidget {
  final int cekiciId;
  final String cekiciTipi;

  const CekiciRandevuSayfasi({
    super.key,
    required this.cekiciId,
    required this.cekiciTipi,
  });

  @override
  State<CekiciRandevuSayfasi> createState() => _CekiciRandevuSayfasiState();
}

class _CekiciRandevuSayfasiState extends State<CekiciRandevuSayfasi> {
  static const String apiUrl = "https://localhost:7187/api/Randevu";
  List<dynamic> _randevular = [];
  bool _isLoading = true;
  bool _hasError = false;
  Map<int, String> _tamirciKonumlari = {};
  Map<int, bool> _konumYukleniyor = {};

  // Updated primary color to orange
  final Color _primaryColor = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    _fetchRandevular();
  }

  Future<void> _fetchRandevular() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final response = await http.get(
        Uri.parse('$apiUrl/cekici-randevular?cekiciId=${widget.cekiciId}&cekiciTipi=${widget.cekiciTipi}'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            _randevular = decodedResponse;
            _isLoading = false;
          });
          // Her randevu için tamirci konumunu çek
          for (var randevu in _randevular) {
            _fetchTamirciKonum(
              randevu['id'],
              randevu['kullaniciId'],
              randevu['arac']['id'],
            );
          }
        } else {
          throw Exception('Beklenmeyen veri formatı');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showError('Randevular yüklenirken hata oluştu: $e');
      debugPrint('Hata detayı: $e');
    }
  }

  Future<void> _fetchTamirciKonum(int randevuId, int? kullaniciId, int? aracId) async {
  if (kullaniciId == null || aracId == null) return;

  setState(() => _konumYukleniyor[randevuId] = true);
  try {
    final response = await http.get(Uri.parse(
      'https://localhost:7187/api/Randevu/tamirci-konum/$kullaniciId/$aracId',
    ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _tamirciKonumlari[randevuId] = data['tamirciKonum']);
      }
    } catch (e) {
      debugPrint('Tamirci konumu alınamadı: $e');
    } finally {
      setState(() => _konumYukleniyor[randevuId] = false);
    }
  }

  Future<void> _onaylaRandevu(int randevuId) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/onayla/$randevuId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'onayTarihi': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Randevu onaylandı');
        await _fetchRandevular();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Onaylama başarısız: $e');
      debugPrint('Onaylama hatası: $e');
    }
  }

  Future<void> _reddetRandevu(int randevuId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/sil/$randevuId'),
      );

      if (response.statusCode == 200) {
        _showSuccess('Randevu reddedildi');
        await _fetchRandevular();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Reddetme başarısız: $e');
      debugPrint('Reddetme hatası: $e');
    }
  }

  Future<void> _baslatRandevu(int randevuId) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/baslat/$randevuId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'baslamaTarihi': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Harekete başlandı');
        await _fetchRandevular();
        
        final randevu = _randevular.firstWhere((r) => r['id'] == randevuId);
        final aracPlaka = randevu['arac']?['plakaNo'] ?? 'Aracınız';
        _showNotification(
          'Çekici Yola Çıktı',
          '$aracPlaka için çekici yola çıktı. Konumunu takip edebilirsiniz.',
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Başlatma başarısız: $e');
    }
  }

  Future<void> _openNavigationToUser(String konum) async {
    try {
      final parts = konum.split(',');
      if (parts.length != 2) {
        _showError('Geçersiz konum formatı');
        return;
      }

      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());

      if (lat == null || lng == null) {
        _showError('Geçersiz konum koordinatları');
        return;
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final String mapsUrl = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${currentPosition.latitude},${currentPosition.longitude}'
          '&destination=$lat,$lng'
          '&travelmode=driving';

      if (kIsWeb) {
        html.window.open(mapsUrl, '_blank');
        return;
      }

      final Uri url = Uri.parse(mapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Harita uygulaması açılamadı';
      }
    } catch (e) {
      _showError('Navigasyon başlatılamadı: $e');
      debugPrint('Navigasyon hatası: $e');
    }
  }

  void _showNotification(String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(body),
          ],
        ),
        backgroundColor: Colors.blue[800],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _tamamlaRandevu(int randevuId) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/tamamla/$randevuId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tamamlanmaTarihi': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Randevu tamamlandı');
        await _fetchRandevular();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Tamamlama başarısız: $e');
      debugPrint('Tamamlama hatası: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çekici Randevu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor, // Updated to use orange
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRandevular,
        backgroundColor: _primaryColor, // Updated to use orange
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Randevular yüklenirken bir hata oluştu',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRandevular,
              child: Text('Tekrar Dene', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    if (_randevular.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Randevu bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRandevular,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _randevular.length,
        itemBuilder: (context, index) {
          final randevu = _randevular[index];
          return _buildRandevuCard(randevu);
        },
      ),
    );
  }

  Widget _buildRandevuCard(Map<String, dynamic> randevu) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final status = randevu['durum'];
    Color statusColor = Colors.grey;
    String statusText = status;

    switch (status) {
      case 'OnayBekliyor':
        statusColor = Colors.orange;
        statusText = 'Onay Bekliyor';
        break;
      case 'Onaylandı':
        statusColor = Colors.blue;
        statusText = 'Onaylandı';
        break;
      case 'HareketeGeçildi':
        statusColor = Colors.green;
        statusText = 'Harekete Geçildi';
        break;
      case 'Tamamlandı':
        statusColor = Colors.purple;
        statusText = 'Tamamlandı';
        break;
      case 'Reddedildi':
        statusColor = Colors.red;
        statusText = 'Reddedildi';
        break;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Randevu #${randevu['id']}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Araç Plakası', randevu['arac']?['plakaNo'] ?? 'Bilinmiyor'),
            _buildInfoRow('Kullanıcı Konumu', randevu['kullaniciBaslangıcKonumu'] ?? 'Bilinmiyor'),
            if (_tamirciKonumlari[randevu['id']] != null)
              _buildInfoRow('Tamirci Konumu', _tamirciKonumlari[randevu['id']]!),
            _buildInfoRow('Çağrı Tarihi', dateFormat.format(DateTime.parse(randevu['randevuTarihi']))),
            if (randevu['onayTarihi'] != null)
              _buildInfoRow('Onay Tarihi', dateFormat.format(DateTime.parse(randevu['onayTarihi']))),
            if (randevu['baslamaTarihi'] != null)
              _buildInfoRow('Başlama Tarihi', dateFormat.format(DateTime.parse(randevu['baslamaTarihi']))),
            if (randevu['tamamlanmaTarihi'] != null)
              _buildInfoRow('Tamamlanma Tarihi', dateFormat.format(DateTime.parse(randevu['tamamlanmaTarihi']))),
            const SizedBox(height: 16),
            _buildActionButtons(randevu),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> randevu) {
    final status = randevu['durum'];
    final randevuId = randevu['id'];
    final kullaniciKonumu = randevu['kullaniciBaslangıcKonumu'];
    final tamirciKonum = _tamirciKonumlari[randevuId];
    final konumYukleniyor = _konumYukleniyor[randevuId] ?? false;

    if (status == 'OnayBekliyor') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onaylaRandevu(randevuId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
                ),
              ),
              child: Text(
                'Onayla',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _reddetRandevu(randevuId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
                ),
              ),
              child: Text(
                'Reddet',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'Onaylandı') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _baslatRandevu(randevuId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
                    ),
                  ),
                  child: Text(
                    'Harekete Başla',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _reddetRandevu(randevuId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
                    ),
                  ),
                  child: Text(
                    'İptal Et',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (kullaniciKonumu != null && kullaniciKonumu.isNotEmpty)
            _buildKonumButton(
              konum: kullaniciKonumu,
              label: 'Kullanıcı Konumuna Git',
              icon: Icons.person_pin_circle,
            ),
        ],
      );
    } else if (status == 'HareketeGeçildi') {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () => _tamamlaRandevu(randevuId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[50],
              foregroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.purple.withOpacity(0.5), width: 1),
              ),
            ),
            child: Text(
              'Tamamlandı Olarak İşaretle',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (konumYukleniyor)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CircularProgressIndicator(),
            )
          else ...[
            if (kullaniciKonumu != null)
              _buildKonumButton(
                konum: kullaniciKonumu,
                label: 'Kullanıcı Konumuna Git',
                icon: Icons.person_pin_circle,
              ),
            if (tamirciKonum != null)
              _buildKonumButton(
                konum: tamirciKonum,
                label: 'Tamirci Konumuna Git',
                icon: Icons.car_repair,
              ),
          ],
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildKonumButton({
    required String konum,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: () => _openNavigationToUser(konum),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.orange.withOpacity(0.5), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_picker/image_picker.dart';

class TamirciRandevuSayfasi extends StatefulWidget {
  final int tamirciId;
  final String tamirciTipi;

  const TamirciRandevuSayfasi({
    super.key,
    required this.tamirciId,
    required this.tamirciTipi,
  });

  @override
  State<TamirciRandevuSayfasi> createState() => _TamirciRandevuSayfasiState();
}

class _TamirciRandevuSayfasiState extends State<TamirciRandevuSayfasi> {
  static const String apiUrl = "https://localhost:7187/api/Tamirci";
  static const String fotoApiUrl = "https://localhost:7187/api/foto";
  List<dynamic> _randevular = [];
  bool _isLoading = true;
  bool _hasError = false;
  Map<int, String> _aracKonumlari = {};
  final ImagePicker _picker = ImagePicker();
  Map<int, List<String>> _oncesiFotograflar = {};
  Map<int, List<String>> _sonrasiFotograflar = {};
  Map<int, bool> _loadingOncesiFotos = {};
  Map<int, bool> _loadingSonrasiFotos = {};
  
  // Using the same orange color scheme as Çekici Randevu Sayfası
  final Color _primaryColor = Color(0xFF00ACC1);

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
        Uri.parse('$apiUrl/tamirci-randevular?tamirciId=${widget.tamirciId}&tamirciTipi=${widget.tamirciTipi}'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            _randevular = decodedResponse;
            _isLoading = false;
          });
          
          for (var randevu in _randevular) {
            final randevuId = randevu['id'];
            
            if (randevu['kullaniciBaslangıcKonumu'] != null) {
              _aracKonumlari[randevuId] = randevu['kullaniciBaslangıcKonumu'];
            }
            
            _loadingOncesiFotos[randevuId] = false;
            _loadingSonrasiFotos[randevuId] = false;

            final status = randevu['durum'];
            if (status == 'TamireBaşlandı' || status == 'Tamamlandı') {
              _fetchOncesiFotograflar(randevuId);
              _fetchSonrasiFotograflar(randevuId);
            }
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

  Future<void> _fetchOncesiFotograflar(int randevuId) async {
    try {
      setState(() {
        _loadingOncesiFotos[randevuId] = true;
      });

      final response = await http.get(
        Uri.parse('$fotoApiUrl/get-oncesi/$randevuId'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            _oncesiFotograflar[randevuId] = List<String>.from(decodedResponse);
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Öncesi fotoğraflar yüklenirken hata oluştu: $e');
    } finally {
      setState(() {
        _loadingOncesiFotos[randevuId] = false;
      });
    }
  }

  Future<void> _fetchSonrasiFotograflar(int randevuId) async {
    try {
      setState(() {
        _loadingSonrasiFotos[randevuId] = true;
      });

      final response = await http.get(
        Uri.parse('$fotoApiUrl/get-sonrasi/$randevuId'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            _sonrasiFotograflar[randevuId] = List<String>.from(decodedResponse);
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Sonrası fotoğraflar yüklenirken hata oluştu: $e');
    } finally {
      setState(() {
        _loadingSonrasiFotos[randevuId] = false;
      });
    }
  }

  Future<void> _onaylaRandevu(int randevuId) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/onayla/$randevuId'),
        headers: {'Content-Type': 'application/json'},
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
      );

      if (response.statusCode == 200) {
        _showSuccess('Tamire başlandı');
        await _fetchRandevular();
        
        final randevu = _randevular.firstWhere((r) => r['id'] == randevuId);
        final aracPlaka = randevu['arac']?['plakaNo'] ?? 'Aracınız';
        _showNotification(
          'Tamirci Tamire Başladı',
          '$aracPlaka için tamirci başladı. Bitince tamamlandı olarak bildirim alıcaksınız.',
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Başlatma başarısız: $e');
    }
  }

  Future<void> _openNavigationToArac(String aracKonumu) async {
    try {
      final parts = aracKonumu.split(',');
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

  Future<void> _uploadPhotos(int randevuId, bool isOncesi) async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles == null || pickedFiles.isEmpty) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$fotoApiUrl/upload-${isOncesi ? "oncesi" : "sonrasi"}/$randevuId'),
      );

      for (var file in pickedFiles) {
        if (kIsWeb) {
          var fileBytes = await file.readAsBytes();
          var fileMultipart = http.MultipartFile.fromBytes(
            'files',
            fileBytes,
            filename: file.name,
          );
          request.files.add(fileMultipart);
        } else {
          request.files.add(await http.MultipartFile.fromPath('files', file.path));
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        _showSuccess('Fotoğraflar başarıyla yüklendi');
        if (isOncesi) {
          await _fetchOncesiFotograflar(randevuId);
        } else {
          await _fetchSonrasiFotograflar(randevuId);
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Fotoğraf yükleme başarısız: $e');
    }
  }

  Future<void> _deletePhoto(int randevuId, String url, bool isOncesi) async {
    try {
      final response = await http.delete(
        Uri.parse('$fotoApiUrl/sil-foto/$randevuId?fotoUrl=${Uri.encodeComponent(url)}&isOncesi=$isOncesi'),
      );

      if (response.statusCode == 200) {
        _showSuccess('Fotoğraf silindi');
        if (isOncesi) {
          await _fetchOncesiFotograflar(randevuId);
        } else {
          await _fetchSonrasiFotograflar(randevuId);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Silme işlemi başarısız: $e');
    }
  }

  Widget _buildPhotoGrid(List<String> photos, int randevuId, bool isOncesi) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '$fotoApiUrl/proxy-image?url=${Uri.encodeComponent(photos[index])}',
              headers: {
                "Access-Control-Allow-Origin": "*",
                "Accept": "image/jpeg, image/png",
              },
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint("Image load error: $error");
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.grey),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _deletePhoto(randevuId, photos[index], isOncesi),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String title, List<String> photos, int randevuId, bool isOncesi, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(20),),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => _uploadPhotos(randevuId, isOncesi),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator()),
        if (!isLoading && photos.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Henüz fotoğraf eklenmedi',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ),
        if (!isLoading && photos.isNotEmpty)
          _buildPhotoGrid(photos, randevuId, isOncesi),
        const SizedBox(height: 16),
      ],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
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
    final randevuId = randevu['id'];
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
      case 'TamireBaşlandı':
        statusColor = Colors.green;
        statusText = 'Tamire Başlandı';
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
            _buildInfoRow('Araç Konumu', _aracKonumlari[randevuId] ?? 'Konum bilinmiyor'),
            _buildInfoRow('Çağrı Tarihi', dateFormat.format(DateTime.parse(randevu['randevuTarihi']))),
            if (randevu['onayTarihi'] != null)
              _buildInfoRow('Onay Tarihi', dateFormat.format(DateTime.parse(randevu['onayTarihi']))),
            if (randevu['baslamaTarihi'] != null)
              _buildInfoRow('Başlama Tarihi', dateFormat.format(DateTime.parse(randevu['baslamaTarihi']))),
            if (randevu['tamamlanmaTarihi'] != null)
              _buildInfoRow('Tamamlanma Tarihi', dateFormat.format(DateTime.parse(randevu['tamamlanmaTarihi']))),
            const SizedBox(height: 16),

            if (status == 'TamireBaşlandı' || status == 'Tamamlandı') ...[
              _buildPhotoSection(
                'Öncesi Fotoğraflar', 
                _oncesiFotograflar[randevuId] ?? [],
                randevuId, 
                true,
                _loadingOncesiFotos[randevuId] ?? false,
              ),
              _buildPhotoSection(
                'Sonrası Fotoğraflar', 
                _sonrasiFotograflar[randevuId] ?? [],
                randevuId, 
                false,
                _loadingSonrasiFotos[randevuId] ?? false,
              ),
            ],

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
    final aracKonumu = _aracKonumlari[randevuId];

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
                    'Tamire Başla',
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
          if (aracKonumu != null && aracKonumu.isNotEmpty)
            _buildKonumButton(
              konum: aracKonumu,
              label: 'Araç Konumuna Git',
              icon: Icons.directions_car,
            ),
        ],
      );
    } else if (status == 'TamireBaşlandı') {
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
        onPressed: () => _openNavigationToArac(konum),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tamirci Randevuları',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRandevular,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
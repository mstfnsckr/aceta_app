import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class AracListem extends StatefulWidget {
  final String? ePosta;

  const AracListem({super.key, this.ePosta});

  @override
  State<AracListem> createState() => _AracListemState();
}

class _AracListemState extends State<AracListem> {
  String? tc;
  String? hata;
  List<dynamic> araclar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.ePosta != null) {
      kullaniciBilgileriniGetir(widget.ePosta!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> kullaniciBilgileriniGetir(String ePosta) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://localhost:7187/api/Kullanici/GetByEPosta?ePosta=$ePosta');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => tc = data['tc']);
        if (tc != null) {
          await araclariGetir(tc!);
        }
      } else {
        _showError('Kullanıcı bilgileri alınamadı');
      }
    } catch (e) {
      _showError('Sunucu bağlantı hatası');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> araclariGetir(String tc) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://localhost:7187/api/Arac/GetByTC?tc=$tc');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() => araclar = data);
      } else {
        _showError('Araç listesi alınamadı');
      }
    } catch (e) {
      _showError('Veri yüklenirken hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> aracSil(int id) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://localhost:7187/api/Arac/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() => araclar.removeWhere((arac) => arac['id'] == id));
        _showSuccess('Araç başarıyla silindi');
      } else {
        _showError('Araç silinemedi');
      }
    } catch (e) {
      _showError('Silme işlemi başarısız');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Aracı Sil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Bu aracı silmek istediğinize emin misiniz?', 
                     style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: GoogleFonts.poppins(color: Colors.deepPurple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sil', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Kullanıcı Araç Liste', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : hata != null
              ? Center(
                  child: Text(
                    hata!,
                    style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 16),
                  ),
                )
              : araclar.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined, 
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Kayıtlı aracınız bulunmamaktadır',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => tc != null ? araclariGetir(tc!) : Future.value(),
                      color: Colors.deepPurple,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: araclar.length,
                        itemBuilder: (context, index) {
                          final arac = araclar[index];
                          return _buildAracCard(arac);
                        },
                      ),
                    ),
    );
  }

  Widget _buildAracCard(Map<String, dynamic> arac) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Arac detay sayfasına yönlendirme eklenebilir
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${arac['plakaNo']}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: () async {
                      final confirm = await _confirmDelete(context);
                      if (confirm) await aracSil(arac['id']);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${arac['aracMarkasi']} ${arac['aracModeli']}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${arac['aracTuru']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${arac['aracYili']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.deepPurple,
        strokeWidth: 3,
      ),
    );
  }
}
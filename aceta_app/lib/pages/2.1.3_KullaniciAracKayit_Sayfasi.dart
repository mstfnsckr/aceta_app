import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class AracKayit extends StatefulWidget {
  @override
  _AracKayitFormuState createState() => _AracKayitFormuState();
}

class _AracKayitFormuState extends State<AracKayit> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  List<dynamic> tumVeriler = [];
  List<String> aracTurleri = [];
  List<String> aracMarkalari = [];
  List<String> aracModelleri = [];

  String? seciliTur;
  String? seciliMarka;
  String? seciliModel;

  final _tCController = TextEditingController();
  final _plakaController = TextEditingController();
  final _yilController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  @override
  void dispose() {
    _tCController.dispose();
    _plakaController.dispose();
    _yilController.dispose();
    super.dispose();
  }

  Future<void> _verileriGetir() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Arac/tum-veriler'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tumVeriler = json.decode(response.body);
          aracTurleri = tumVeriler.map<String>((e) => e['turAdi'] as String).toList();
          if (aracTurleri.isNotEmpty) {
            seciliTur = aracTurleri.first;
            _markalariGuncelle();
          }
        });
      } else {
        _showError('Veri alınamadı. Lütfen tekrar deneyin');
      }
    } catch (e) {
      _showError('Sunucu bağlantı hatası');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markalariGuncelle() {
    final tur = tumVeriler.firstWhere(
      (e) => e['turAdi'] == seciliTur,
      orElse: () => null,
    );
    if (tur != null) {
      aracMarkalari = (tur['markalar'] as List).map<String>((m) => m['markaAdi'] as String).toList();
      seciliMarka = aracMarkalari.isNotEmpty ? aracMarkalari.first : null;
      _modelleriGuncelle();
    }
  }

  void _modelleriGuncelle() {
    final tur = tumVeriler.firstWhere(
      (e) => e['turAdi'] == seciliTur,
      orElse: () => null,
    );
    if (tur != null) {
      final marka = (tur['markalar'] as List).firstWhere(
        (m) => m['markaAdi'] == seciliMarka,
        orElse: () => null,
      );
      if (marka != null) {
        aracModelleri = (marka['modeller'] as List).map<String>((m) => m['modelAdi'] as String).toList();
        seciliModel = aracModelleri.isNotEmpty ? aracModelleri.first : null;
      } else {
        aracModelleri = [];
        seciliModel = null;
      }
    }
    setState(() {});
  }

  Future<void> _aracKaydet() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://localhost:7187/api/Arac/kayit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'TC': _tCController.text.trim(),
          'PlakaNo': _plakaController.text.trim(),
          'AracTuru': seciliTur,
          'AracMarkasi': seciliMarka,
          'AracModeli': seciliModel,
          'AracYili': _yilController.text.trim(),
          'cekiciRandevular' : [],
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Araç başarıyla kaydedildi');
        _formKey.currentState!.reset();
      } else {
        _showError('Kayıt sırasında hata oluştu');
      }
    } catch (e) {
      _showError('Sunucu bağlantı hatası');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Kullanıcı Araç Kayıt', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && tumVeriler.isEmpty
          ? _buildLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _tCController,
                      label: 'TC Kimlik No',
                      icon: Icons.credit_card,
                      validator: (val) => val!.length != 11 ? '11 haneli olmalı' : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _plakaController,
                      label: 'Plaka No',
                      icon: Icons.directions_car,
                      validator: (val) => val!.isEmpty ? 'Plaka gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Araç Türü',
                      value: seciliTur,
                      items: aracTurleri,
                      icon: Icons.category,
                      onChanged: (val) {
                        setState(() {
                          seciliTur = val;
                          _markalariGuncelle();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Araç Markası',
                      value: seciliMarka,
                      items: aracMarkalari,
                      icon: Icons.branding_watermark,
                      onChanged: (val) {
                        setState(() {
                          seciliMarka = val;
                          _modelleriGuncelle();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Araç Modeli',
                      value: seciliModel,
                      items: aracModelleri,
                      icon: Icons.model_training,
                      onChanged: (val) => setState(() => seciliModel = val),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _yilController,
                      label: 'Araç Yılı',
                      icon: Icons.calendar_today,
                      validator: (val) => val!.isEmpty ? 'Yıl gerekli' : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple[700]!,
                            Colors.deepPurple[500]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),)
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _aracKaydet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
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
                              'KAYDET',
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
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.deepPurple[400]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: GoogleFonts.poppins()),
        )).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? '$label seçiniz' : null,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.deepPurple[400]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
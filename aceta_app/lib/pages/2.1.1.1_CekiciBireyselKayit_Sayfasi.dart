import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';

class CekiciKayitBireysel extends StatefulWidget {
  const CekiciKayitBireysel({super.key});

  @override
  _CekiciKayitBireyselState createState() => _CekiciKayitBireyselState();
}

class _CekiciKayitBireyselState extends State<CekiciKayitBireysel> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _tcController = TextEditingController();
  final _telefonController = TextEditingController();
  final _ePostaController = TextEditingController();
  final _plakaNoController = TextEditingController();
  final _kmBasiUcretController = TextEditingController();
  final _sifreController = TextEditingController();
  final _kodController = TextEditingController();

  bool _sifreGizle = true;
  bool _emailVerified = false;
  bool _codeSent = false;
  bool _isLoading = false;
  bool _dataLoading = true;

  // API'den gelen listeler
  List<String> _cekebilecegiAraclar = [];
  List<String> _tasimaSistemleri = [];
  List<String> _destekEkipmanlari = [];
  List<String> _teknikEkipmanlar = [];

  // Seçimler
  List<String> _selectedCekebilecegiAraclar = [];
  List<String> _selectedTasimaSistemleri = [];
  List<String> _selectedDestekEkipmanlari = [];
  List<String> _selectedTeknikEkipmanlar = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://localhost:7187/api/Cekici/CekebilecegiAraclar')),
        http.get(Uri.parse('https://localhost:7187/api/Cekici/TasimaSistemleri')),
        http.get(Uri.parse('https://localhost:7187/api/Cekici/DestekEkipmanlari')),
        http.get(Uri.parse('https://localhost:7187/api/Cekici/TeknikEkipmanlari')),
      ]);

      setState(() {
        _cekebilecegiAraclar = _parseResponse(responses[0]);
        _tasimaSistemleri = _parseResponse(responses[1]);
        _destekEkipmanlari = _parseResponse(responses[2]);
        _teknikEkipmanlar = _parseResponse(responses[3]);
        _dataLoading = false;
      });
    } catch (e) {
      _showError('Veriler alınamadı. Lütfen internet bağlantınızı kontrol edin');
      setState(() => _dataLoading = false);
    }
  }

  List<String> _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onSelected,
  }) {
    final tempSelected = List<String>.from(selectedItems);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title, style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              children: items.map((item) => CheckboxListTile(
                title: Text(item, style: GoogleFonts.poppins()),
                value: tempSelected.contains(item),
                activeColor: Colors.deepPurple,
                onChanged: (value) => setState(() {
                  value! ? tempSelected.add(item) : tempSelected.remove(item);
                }),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                onSelected(tempSelected);
                Navigator.pop(context);
              },
              child: Text('Tamam', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    if (!EmailValidator.validate(_ePostaController.text)) {
      _showError('Lütfen geçerli bir e‑posta girin');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('https://localhost:7187/api/cekici/kodgonderbireysel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ePosta': _ePostaController.text}),
      );

      if (res.statusCode == 200) {
        setState(() => _codeSent = true);
        _showSuccess('Doğrulama kodu gönderildi');
      } else {
        _showError(json.decode(res.body)['message'] ?? 'Hata oluştu');
      }
    } catch (e) {
      _showError('Sunucu ile bağlantı kurulamadı');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_kodController.text.length != 6) {
      _showError('6 haneli kod girin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('https://localhost:7187/api/cekici/koddogrulabireysel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ePosta': _ePostaController.text,
          'kod': _kodController.text,
        }),
      );

      if (res.statusCode == 200) {
        setState(() => _emailVerified = true);
        _showSuccess('E‑posta doğrulandı ✅');
      } else {
        _showError(json.decode(res.body)['message'] ?? 'Kod hatalı');
      }
    } catch (e) {
      _showError('Doğrulama işlemi başarısız');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate() || !_emailVerified) return;
    if (_selectedCekebilecegiAraclar.isEmpty) {
      _showError('En az bir araç tipi seçin');
      return;
    }
    if (_selectedTasimaSistemleri.isEmpty) {
      _showError('En az bir taşıma sistemi seçin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://localhost:7187/api/Cekici/kayitbireysel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ad': _adController.text.trim(),
          'soyad': _soyadController.text.trim(),
          'tc': _tcController.text.trim(),
          'telefon': _telefonController.text.trim(),
          'ePosta': _ePostaController.text.trim(),
          'plakaNo': _plakaNoController.text.trim(),
          'cekebilecegiAraclar': _selectedCekebilecegiAraclar,
          'tasimaSistemleri': _selectedTasimaSistemleri,
          'destekEkipmanlari': _selectedDestekEkipmanlari,
          'teknikEkipmanlari': _selectedTeknikEkipmanlar,
          'kmBasiUcret': double.parse(_kmBasiUcretController.text.trim()),
          'sifre': _sifreController.text.trim(),
          'durum': false,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _showSuccess('Kayıt başarılı ✅');
      } else {
        _showError(json.decode(response.body)['message'] ?? 'Kayıt başarısız');
      }
    } catch (e) {
      _showError('Kayıt sırasında bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> items,
    required ValueChanged<List<String>> onSelected,
    bool enabled = true,
    String? errorText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: GestureDetector(
        onTap: enabled ? () => _showMultiSelectDialog(
          context: context,
          title: label,
          items: items,
          selectedItems: selectedItems,
          onSelected: onSelected,
        ) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.arrow_drop_down,
              color: Colors.deepPurple[400],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          child: Wrap(
            spacing: 6,
            children: selectedItems.map((item) => Chip(
              label: Text(item, style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor: Colors.deepPurple[50],
              deleteIconColor: Colors.deepPurple,
              onDeleted: () {
                final newList = List<String>.from(selectedItems)..remove(item);
                onSelected(newList);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        onTap: onTap,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.deepPurple[400]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Çekici Bireysel Kayıt', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _dataLoading 
          ? _buildLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Ad Soyad
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _adController,
                            label: 'Ad',
                            icon: Icons.person,
                            validator: (v) => v!.isEmpty ? 'Ad girin' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _soyadController,
                            label: 'Soyad',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Soyad girin' : null,
                          ),
                        ),
                      ],
                    ),

                    // TC Kimlik No
                    _buildInputField(
                      controller: _tcController,
                      label: 'TC Kimlik No',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.length != 11 ? '11 haneli olmalı' : null,
                    ),

                    // Telefon
                    _buildInputField(
                      controller: _telefonController,
                      label: 'Telefon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 10 ? 'En az 10 haneli' : null,
                    ),

                    // E-posta ve Kod Gönder
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInputField(
                            controller: _ePostaController,
                            label: 'E-posta',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_emailVerified,
                            validator: (v) => !EmailValidator.validate(v!) ? 'Geçersiz e-posta' : null,
                            suffixIcon: _emailVerified
                                ? Icon(Icons.check_circle, color: Colors.green[400])
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 56,
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
                            child: ElevatedButton(
                              onPressed: (_codeSent || _emailVerified || _isLoading) 
                                  ? null 
                                  : _sendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Kod Gönder',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Kod Doğrulama
                    if (_codeSent && !_emailVerified) ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildInputField(
                              controller: _kodController,
                              label: 'Doğrulama Kodu',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 56,
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
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Doğrula',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Plaka No
                    _buildInputField(
                      controller: _plakaNoController,
                      label: 'Plaka No',
                      icon: Icons.car_repair,
                      validator: (v) => v!.isEmpty ? 'Plaka girin' : null,
                    ),

                    // Çekebileceği Araçlar
                    _buildMultiSelectField(
                      label: 'Çekebileceği Araçlar',
                      selectedItems: _selectedCekebilecegiAraclar,
                      items: _cekebilecegiAraclar,
                      onSelected: (selected) => setState(() => _selectedCekebilecegiAraclar = selected),
                      errorText: _selectedCekebilecegiAraclar.isEmpty ? 'En az bir araç tipi seçin' : null,
                    ),

                    // Taşıma Sistemleri
                    _buildMultiSelectField(
                      label: 'Taşıma Sistemleri',
                      selectedItems: _selectedTasimaSistemleri,
                      items: _tasimaSistemleri,
                      onSelected: (selected) => setState(() => _selectedTasimaSistemleri = selected),
                      errorText: _selectedTasimaSistemleri.isEmpty ? 'En az bir sistem seçin' : null,
                    ),

                    // Destek Ekipmanları
                    _buildMultiSelectField(
                      label: 'Destek Ekipmanları',
                      selectedItems: _selectedDestekEkipmanlari,
                      items: _destekEkipmanlari,
                      onSelected: (selected) => setState(() => _selectedDestekEkipmanlari = selected),
                    ),

                    // Teknik Ekipmanlar
                    _buildMultiSelectField(
                      label: 'Teknik Ekipmanlar',
                      selectedItems: _selectedTeknikEkipmanlar,
                      items: _teknikEkipmanlar,
                      onSelected: (selected) => setState(() => _selectedTeknikEkipmanlar = selected),
                    ),

                    // KM Başına Ücret
                    _buildInputField(
                      controller: _kmBasiUcretController,
                      label: 'KM Başına Ücret (₺)',
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    ),

                    // Şifre
                    _buildInputField(
                      controller: _sifreController,
                      label: 'Şifre',
                      icon: Icons.lock,
                      obscureText: _sifreGizle,
                      validator: (v) => v!.length < 6 ? 'En az 6 karakter' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _sifreGizle ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[500],
                        ),
                        onPressed: () => setState(() => _sifreGizle = !_sifreGizle),
                      ),
                    ),

                    // Kayıt Ol Butonu
                    Container(
                      height: 56,
                      margin: const EdgeInsets.only(top: 8),
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
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _kayitOl,
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
                                'KAYIT OL',
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
}
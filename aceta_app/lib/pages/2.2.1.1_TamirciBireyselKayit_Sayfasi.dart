import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(home: TamirciKayitBireysel()));
}

class TamirciKayitBireysel extends StatefulWidget {
  const TamirciKayitBireysel({super.key});

  @override
  _TamirciKayitBireyselState createState() => _TamirciKayitBireyselState();
}

class _TamirciKayitBireyselState extends State<TamirciKayitBireysel> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _tcController = TextEditingController();
  final _dukkanAdiController = TextEditingController();
  final _telefonController = TextEditingController();
  final _ePostaController = TextEditingController();
  final _konumController = TextEditingController();
  final _sifreController = TextEditingController();
  final _kodController = TextEditingController();

  bool _sifreGizle = true;
  bool _emailVerified = false;
  bool _codeSent = false;
  bool _isLoading = false;
  bool _isAracDataLoading = true;
  
  LatLng? _selectedLocation;
  Position? _currentPosition;
  List<dynamic> tumAracVerileri = [];
  List<String> aracTurleri = [];
  List<String> _selectedAracTurleri = [];
  List<String> _selectedMarkalar = [];
  List<String> _selectedModeller = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAracVerileri();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      _showError('Konum alınamadı. Lütfen tekrar deneyin');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Konum servisleri kapalı');
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _showError('Konum izinleri kalıcı olarak reddedildi');
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        return false;
      }
    }
    return true;
  }

  Future<void> _fetchAracVerileri() async {
    setState(() => _isAracDataLoading = true);
    try {
      final response = await http.get(Uri.parse('https://localhost:7187/api/Arac/tum-veriler'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tumAracVerileri = data;
          aracTurleri = data.map<String>((tur) => tur['turAdi'] as String).toList();
        });
      } else {
        _showError('Araç verileri alınamadı');
      }
    } catch (_) {
      _showError('Sunucu bağlantı hatası');
    } finally {
      setState(() => _isAracDataLoading = false);
    }
  }

  List<String> get availableMarkalar {
    final markalar = <String>[];
    for (final tur in tumAracVerileri) {
      if (_selectedAracTurleri.contains(tur['turAdi'])) {
        for (final marka in tur['markalar']) {
          markalar.add(marka['markaAdi'] as String);
        }
      }
    }
    return markalar.toSet().toList();
  }

  List<String> get availableModeller {
    final modeller = <String>[];
    for (final tur in tumAracVerileri) {
      if (_selectedAracTurleri.contains(tur['turAdi'])) {
        for (final marka in tur['markalar']) {
          if (_selectedMarkalar.contains(marka['markaAdi'])) {
            for (final model in marka['modeller']) {
              modeller.add(model['modelAdi'] as String);
            }
          }
        }
      }
    }
    return modeller.toSet().toList();
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

  void _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: _currentPosition != null 
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : const LatLng(41.0082, 28.9784),
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedLocation = result);
      _konumController.text = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
    }
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

  Future<void> _sendCode() async {
    if (!EmailValidator.validate(_ePostaController.text.trim())) {
      _showError('Lütfen geçerli bir e‑posta girin');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('https://localhost:7187/api/tamirci/kodgonderbireysel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ePosta': _ePostaController.text.trim()}),
      );
      if (res.statusCode == 200) {
        setState(() => _codeSent = true);
        _showSuccess('Doğrulama kodu gönderildi');
      } else {
        _showError(json.decode(res.body)['message'] ?? 'Hata oluştu');
      }
    } catch (_) {
      _showError('Sunucu ile bağlantı kurulamadı');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_kodController.text.trim().length != 6) {
      _showError('6 haneli kod girin');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('https://localhost:7187/api/tamirci/koddogrulabireysel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ePosta': _ePostaController.text.trim(),
          'kod': _kodController.text.trim(),
        }),
      );
      if (res.statusCode == 200) {
        setState(() => _emailVerified = true);
        _showSuccess('E‑posta doğrulandı ✅');
      } else {
        _showError(json.decode(res.body)['message'] ?? 'Kod hatalı');
      }
    } catch (_) {
      _showError('Doğrulama işlemi başarısız');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_emailVerified) {
      _showError('Lütfen e‑posta adresinizi doğrulayın');
      return;
    }
    if (_selectedAracTurleri.isEmpty) {
      _showError('En az bir araç türü seçin');
      return;
    }
    if (_selectedMarkalar.isEmpty) {
      _showError('En az bir marka seçin');
      return;
    }
    if (_selectedModeller.isEmpty) {
      _showError('En az bir model seçin');
      return;
    }

    setState(() => _isLoading = true);
    final data = {
      'ad': _adController.text.trim(),
      'soyad': _soyadController.text.trim(),
      'tc': _tcController.text.trim(),
      'dukkanAdi': _dukkanAdiController.text.trim(),
      'telefon': _telefonController.text.trim(),
      'ePosta': _ePostaController.text.trim(),
      'aracTuru': _selectedAracTurleri.join(','),
      'aracMarkasi': _selectedMarkalar.join(','),
      'aracModeli': _selectedModeller.join(','),
      'konum': _konumController.text.trim(),
      'sifre': _sifreController.text.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse('https://localhost:7187/api/Tamirci/kayitbireysel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        _showSuccess('Kayıt başarılı ✅');
        Navigator.pop(context);
      } else {
        _showError(json.decode(res.body)['message'] ?? 'Kayıt başarısız');
      }
    } catch (_) {
      _showError('Kayıt sırasında bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Tamirci Bireysel Kayıt', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isAracDataLoading 
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

                    // Dükkan Adı
                    _buildInputField(
                      controller: _dukkanAdiController,
                      label: 'Dükkan Adı',
                      icon: Icons.store,
                      validator: (v) => v!.isEmpty ? 'Dükkan adı girin' : null,
                    ),

                    // Telefon
                    _buildInputField(
                      controller: _telefonController,
                      label: 'Telefon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v!.isEmpty) return 'Telefon numarası girin';
                        if (v.length != 10) return '10 haneli olmalı';
                        if (!v.startsWith('5')) return '5 ile başlamalı';
                        return null;
                      },
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

                    // Araç Türü
                    _buildMultiSelectField(
                      label: 'Araç Türü',
                      selectedItems: _selectedAracTurleri,
                      items: aracTurleri,
                      onSelected: (selected) => setState(() {
                        _selectedAracTurleri = selected;
                        _selectedMarkalar = [];
                        _selectedModeller = [];
                      }),
                      errorText: _selectedAracTurleri.isEmpty ? 'En az bir tür seçin' : null,
                    ),

                    // Markalar
                    _buildMultiSelectField(
                      label: 'Markalar',
                      selectedItems: _selectedMarkalar,
                      items: availableMarkalar,
                      onSelected: (selected) => setState(() {
                        _selectedMarkalar = selected;
                        _selectedModeller = [];
                      }),
                      enabled: _selectedAracTurleri.isNotEmpty,
                      errorText: _selectedMarkalar.isEmpty ? 'En az bir marka seçin' : null,
                    ),

                    // Modeller
                    _buildMultiSelectField(
                      label: 'Modeller',
                      selectedItems: _selectedModeller,
                      items: availableModeller,
                      onSelected: (selected) => setState(() => _selectedModeller = selected),
                      enabled: _selectedMarkalar.isNotEmpty,
                      errorText: _selectedModeller.isEmpty ? 'En az bir model seçin' : null,
                    ),

                    // Konum
                    _buildInputField(
                      controller: _konumController,
                      label: 'Konum',
                      icon: Icons.location_on,
                      validator: (v) => _selectedLocation == null ? 'Konum seçin' : null,
                      onTap: _openMapPicker,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: _openMapPicker,
                      ),
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

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.deepPurple,
        strokeWidth: 3,
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLocation;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isSearching = true);
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _searchResults = data.map<Map<String, dynamic>>((item) => ({
            'displayName': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          })).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama hatası: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController.move(location, 15.0);
    setState(() => _selectedLocation = location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Konum Seçin',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.deepPurple[800]),
            onPressed: () => Navigator.pop(context, _selectedLocation),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Adres ara...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple[400]),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.deepPurple[400]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = []);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onSubmitted: (query) => _searchLocation(query),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: widget.initialLocation,
                    zoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() => _selectedLocation = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: _selectedLocation != null
                          ? [
                              Marker(
                                point: _selectedLocation!,
                                width: 40.0,
                                height: 40.0,
                                builder: (context) => Icon(
                                  Icons.location_pin,
                                  color: Colors.deepPurple,
                                  size: 40,
                                ),
                              )
                            ]
                          : [],
                    ),
                  ],
                ),
                if (_isSearching)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                if (_searchResults.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            title: Text(
                              result['displayName'],
                              style: GoogleFonts.poppins(),
                            ),
                            dense: true,
                            onTap: () {
                              final location = LatLng(
                                result['lat'],
                                result['lon'],
                              );
                              _moveToLocation(location);
                              setState(() => _searchResults = []);
                              _searchController.clear();
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:aceta_app/pages/2.2.0.3.1_TamirciRandevu_Sayfasi.dart' show TamirciRandevuSayfasi;
import 'package:aceta_app/pages/2.0_KullaniciAna_Sayfasi.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TamirciGirisSayfasi extends StatefulWidget {
  final Map<String, dynamic> tamirciData;
  final String? ePosta;
  
  const TamirciGirisSayfasi({
    super.key, 
    required this.tamirciData, 
    this.ePosta
  });

  @override
  State<TamirciGirisSayfasi> createState() => _TamirciGirisSayfasiState();
}

class _TamirciGirisSayfasiState extends State<TamirciGirisSayfasi> {
  static const String apiUrl = "https://localhost:7187/api/Tamirci";
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  
  late bool _isActive;
  Timer? _locationTimer;
  bool _isEditing = false;
  bool _isLoading = false;
  late Map<String, dynamic> _editedData;
  
  List<dynamic> tumAracVerileri = [];
  List<String> _aracTurleri = [];
  List<String> _aracMarkalari = [];
  List<String> _aracModelleri = [];
  
  // New rating and comment variables
  double _puanOrtalamasi = 0.0;
  List<Yorum> _yorumlar = [];
  bool _isLoadingYorumlar = false;
  
  // Color scheme
  final Color _primaryColor = const Color(0xFF00ACC1);
  final Color _primaryLight = const Color(0xFFB2EBF2);
  final Color _secondaryColor = const Color(0xFF6C757D);
  final Color _accentColor = const Color(0xFF5E60CE);
  final Color _dangerColor = const Color(0xFFF72585);
  final Color _lightBackground = const Color(0xFFE0F7FA);
  final Color _darkText = const Color(0xFF212529);
  final Color _lightText = const Color(0xFFADB5BD);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchAracVerileri();
    _fetchPuanOrtalamasi();
    _fetchYorumlar();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  bool get isBireysel => widget.tamirciData.containsKey('ad');

  void _initializeData() {
    _isActive = widget.tamirciData['durum'] == true;
    _editedData = Map.from(widget.tamirciData);
    
    _editedData['aracTuru'] ??= '';
    _editedData['aracMarkasi'] ??= '';
    _editedData['aracModeli'] ??= '';
    
    if (_isActive) {
      _startLocationTracking();
    }
  }

  Future<void> _fetchPuanOrtalamasi() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/puan-ortalamasi?${isBireysel ? 'bireyselId=${widget.tamirciData['id']}' : 'firmaId=${widget.tamirciData['id']}'}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _puanOrtalamasi = (data['ortalama'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } 
    catch (e) {
      debugPrint('Puan ortalaması alınamadı: $e');
    }
  }

  Future<void> _fetchYorumlar() async {
    setState(() => _isLoadingYorumlar = true);
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/yorumlar?${isBireysel ? 'bireyselId=${widget.tamirciData['id']}' : 'firmaId=${widget.tamirciData['id']}'}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _yorumlar = data.map((yorum) => Yorum(
            kullaniciAdi: yorum['kullaniciAdi'] ?? 'Anonim',
            yorum: yorum['yorum'] ?? '',
            puan: (yorum['puan'] as num?)?.toInt() ?? 0,
            tarih: DateTime.parse(yorum['tarih']),
          )).toList();
        });
      }
    } catch (e) {
      debugPrint('Yorumlar alınamadı: $e');
    } finally {
      setState(() => _isLoadingYorumlar = false);
    }
  }

  Future<void> _fetchAracVerileri() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/tum-veriler'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          tumAracVerileri = data;
          _aracTurleri = data.map<String>((tur) => tur['turAdi'].toString()).toList();
        });
      }
    } catch (e) {
      _showError('Araç verileri alınamadı. Lütfen internet bağlantınızı kontrol edin');
    }
  }

  List<String> get availableMarkalar {
    final markalar = <String>[];
    for (final tur in tumAracVerileri) {
      if (getSelectedItems(_editedData['aracTuru']).contains(tur['turAdi'])) {
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
      if (getSelectedItems(_editedData['aracTuru']).contains(tur['turAdi'])) {
        for (final marka in tur['markalar']) {
          if (getSelectedItems(_editedData['aracMarkasi']).contains(marka['markaAdi'])) {
            for (final model in marka['modeller']) {
              modeller.add(model['modelAdi'] as String);
            }
          }
        }
      }
    }
    return modeller.toSet().toList();
  }

  List<String> getSelectedItems(String? data) {
    return data?.split(',').where((e) => e.isNotEmpty).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme(
          primary: _primaryColor,
          primaryContainer: _primaryLight,
          secondary: _accentColor,
          secondaryContainer: _accentColor.withOpacity(0.2),
          surface: Colors.white,
          background: _lightBackground,
          error: _dangerColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: _darkText,
          onBackground: _darkText,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        cardTheme: const CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _primaryColor,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _lightBackground,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildRandevularButton(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 4,
      title: Text(
        isBireysel ? "Bireysel Tamirci Profili" : "Firma Tamirci Profili",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: _toggleEditMode,
          tooltip: _isEditing ? 'Düzenlemeyi Kapat' : 'Profili Düzenle',
        ),
      ],
    );
  }

  Widget _buildRandevularButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TamirciRandevuSayfasi(
              tamirciId: widget.tamirciData['id'],
              tamirciTipi: isBireysel ? "Bireysel" : "Firma",
            ),
          ),
        );
      },
      icon: const Icon(Icons.list_alt, color: Colors.white),
      label: Text(
        'Randevularım',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _primaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  ..._buildEditableFields(),
                  const SizedBox(height: 24),
                  _buildRatingSection(),
                ],
              ),
            ),
          ),
          if (_isEditing) _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _primaryColor.withOpacity(0.2), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 2),
              ),
              child: Icon(
                isBireysel ? Icons.person : Icons.business,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBireysel 
                        ? "${_editedData['ad']} ${_editedData['soyad']}"
                        : _editedData['firmaAdi'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _editedData['dukkanAdi'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: _secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isActive ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isActive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isActive ? Icons.check_circle : Icons.remove_circle,
                          color: _isActive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isActive ? "AKTİF" : "PASİF",
                          style: GoogleFonts.poppins(
                            color: _isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isActive,
                          onChanged: (value) => _toggleServiceStatus(value),
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          activeTrackColor: Colors.green[200],
                          inactiveTrackColor: Colors.red[200],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: _primaryColor),
                      onPressed: _toggleEditMode,
                      tooltip: 'Düzenle',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _confirmDelete,
                      tooltip: 'Sil',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEditableFields() {
    return isBireysel ? _buildBireyselFields() : _buildFirmaFields();
  }

  List<Widget> _buildBireyselFields() {
    return [
      _buildEditableField("Ad", 'ad', Icons.person_outline),
      _buildEditableField("Soyad", 'soyad', Icons.person),
      _buildEditableField("TC", 'tc', Icons.assignment_ind, editable: false),
      _buildEditableField("Dükkan Adı", 'dukkanAdi', Icons.store),
      _buildEditableField("Telefon", 'telefon', Icons.phone),
      _buildEditableField("E-Posta", 'ePosta', Icons.email, editable: false),
      _buildMultiSelectField(
        "Araç Türü", 
        'aracTuru', 
        Icons.directions_car,
        options: _aracTurleri,
      ),
      _buildMultiSelectField(
        "Marka Uzmanlığı", 
        'aracMarkasi', 
        Icons.branding_watermark,
        options: availableMarkalar,
      ),
      _buildMultiSelectField(
        "Model Uzmanlığı", 
        'aracModeli', 
        Icons.model_training,
        options: availableModeller,
      ),
      _buildLocationField(),
    ];
  }

  List<Widget> _buildFirmaFields() {
    return [
      _buildEditableField("Firma Adı", 'firmaAdi', Icons.business),
      _buildEditableField("Vergi No", 'vergiKimlikNo', Icons.credit_card, editable: false),
      _buildEditableField("Yetkili Kişi", 'yetkiliKisi', Icons.supervised_user_circle),
      _buildEditableField("Dükkan Adı", 'dukkanAdi', Icons.store),
      _buildEditableField("Telefon", 'telefon', Icons.phone),
      _buildEditableField("E-Posta", 'ePosta', Icons.email, editable: false),
      _buildMultiSelectField(
        "Araç Türü", 
        'aracTuru', 
        Icons.directions_car,
        options: _aracTurleri,
      ),
      _buildMultiSelectField(
        "Marka Uzmanlığı", 
        'aracMarkasi', 
        Icons.branding_watermark,
        options: availableMarkalar,
      ),
      _buildMultiSelectField(
        "Model Uzmanlığı", 
        'aracModeli', 
        Icons.model_training,
        options: availableModeller,
      ),
      _buildLocationField(),
    ];
  }

  Widget _buildEditableField(String label, String dataKey, IconData icon, {
    bool editable = true, 
    bool isNumber = false
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _isEditing && editable
                      ? TextFormField(
                          initialValue: _editedData[dataKey]?.toString() ?? '',
                          keyboardType: isNumber 
                              ? TextInputType.numberWithOptions(decimal: true)
                              : TextInputType.text,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: _darkText,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _editedData[dataKey] = isNumber 
                                  ? double.tryParse(value) ?? 0.0 
                                  : value;
                            });
                          },
                        )
                      : Text(
                          _editedData[dataKey]?.toString() ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: _darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectField(String label, String dataKey, IconData icon, {
    required List<String> options,
  }) {
    final currentItems = getSelectedItems(_editedData[dataKey]);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isEditing
                ? InkWell(
                    onTap: () => _showMultiSelectDialog(label, options, currentItems, dataKey),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentItems.isEmpty 
                                ? 'Seçim yapmak için tıklayın'
                                : '${currentItems.length} öğe seçildi',
                            style: GoogleFonts.poppins(
                              color: currentItems.isEmpty 
                                  ? Colors.grey[500] 
                                  : _darkText,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  )
                : currentItems.isEmpty
                    ? Text(
                        'Seçili öğe yok',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentItems.map((item) {
                          return Chip(
                            label: Text(
                              item,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            backgroundColor: _primaryLight,
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _isEditing ? () {
                              setState(() {
                                currentItems.remove(item);
                                _editedData[dataKey] = currentItems.join(',');
                              });
                            } : null,
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Konum",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              ElevatedButton(
                onPressed: _openMapPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Konumu Güncelle',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _editedData['konum']?.toString() ?? 'Konum bilgisi yok',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Değerlendirmeler',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: _darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puan Ortalaması',
                      style: GoogleFonts.poppins(
                        color: _secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _puanOrtalamasi.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: _puanOrtalamasi,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                Text(
                  '${_yorumlar.length} Değerlendirme',
                  style: GoogleFonts.poppins(
                    color: _secondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingYorumlar)
              const Center(child: CircularProgressIndicator())
            else if (_yorumlar.isEmpty)
              Text(
                'Henüz değerlendirme yapılmamış',
                style: GoogleFonts.poppins(
                  color: _secondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              ..._yorumlar.take(2).map((yorum) => _buildYorumItem(yorum)),
              if (_yorumlar.length > 2)
                TextButton(
                  onPressed: () => _showAllYorumlar(),
                  child: Text(
                    'Tüm Yorumları Gör',
                    style: GoogleFonts.poppins(
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildYorumItem(Yorum yorum) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                yorum.kullaniciAdi,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                ),
              ),
              RatingBarIndicator(
                rating: yorum.puan.toDouble(),
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 16,
                direction: Axis.horizontal,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            yorum.yorum,
            style: GoogleFonts.poppins(
              color: _secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${yorum.tarih.day}.${yorum.tarih.month}.${yorum.tarih.year}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _lightText,
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'Değişiklikleri Kaydet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showAllYorumlar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tüm Yorumlar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingYorumlar
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _yorumlar.length,
                        itemBuilder: (context, index) => _buildYorumItem(_yorumlar[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLocationTracking() {
    _locationTimer?.cancel();
    _updateLocation();
    _locationTimer = Timer.periodic(locationUpdateInterval, (timer) {
      if (_isActive) {
        _updateLocation();
      }
    });
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final id = widget.tamirciData['id'];
      final endpoint = isBireysel ? 'guncelleKonumTamirciBireysel' : 'guncelleKonumTamirciFirma';
      final url = Uri.parse('$apiUrl/$endpoint/$id');

      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enlem': position.latitude,
          'boylam': position.longitude,
        }),
      );
    } catch (e) {
      debugPrint('Konum güncelleme hatası: $e');
    }
  }

  Future<void> _openMapPicker() async {
    final initialLocation = _editedData['konum'] != null
        ? _parseLocation(_editedData['konum'])
        : const LatLng(41.0082, 28.9784);

    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialLocation: initialLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _editedData['konum'] = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
      });
    }
  }

  LatLng _parseLocation(String? location) {
    if (location == null) return const LatLng(41.0082, 28.9784);
    final parts = location.split(',');
    if (parts.length != 2) return const LatLng(41.0082, 28.9784);
    return LatLng(
      double.tryParse(parts[0].trim()) ?? 41.0082,
      double.tryParse(parts[1].trim()) ?? 28.9784,
    );
  }

  void _showMultiSelectDialog(String title, List<String> options, 
    List<String> selectedItems, String dataKey) {
    final tempSelected = List<String>.from(selectedItems);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.map((item) {
                            return CheckboxListTile(
                              title: Text(
                                item,
                                style: GoogleFonts.poppins(),
                              ),
                              value: tempSelected.contains(item),
                              onChanged: (bool? value) {
                                dialogSetState(() {
                                  if (value == true) {
                                    tempSelected.add(item);
                                  } else {
                                    tempSelected.remove(item);
                                  }
                                });
                              },
                              activeColor: _primaryColor,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'İptal',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _editedData[dataKey] = tempSelected.join(',');
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Tamam',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _editedData = Map.from(widget.tamirciData);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final id = widget.tamirciData['id'];
      final endpoint = isBireysel ? 'guncelleBireysel' : 'guncelleFirma';
      final url = Uri.parse('$apiUrl/$endpoint/$id');

      _editedData['tc'] = widget.tamirciData['tc'];
      _editedData['vergiKimlikNo'] = widget.tamirciData['vergiKimlikNo'];
      _editedData['ePosta'] = widget.tamirciData['ePosta'];
      
      if (_editedData['konum'] == null || _editedData['konum'].isEmpty) {
        _editedData['konum'] = widget.tamirciData['konum'];
      }
      
      if (_editedData['sifre'] == widget.tamirciData['sifre']) {
        _editedData['sifre'] = '';
      }

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_editedData),
      );

      if (!mounted) return;
      
      if (response.statusCode == 200) {
        _showSuccess('Bilgiler başarıyla güncellendi');
        setState(() {
          _isEditing = false;
          widget.tamirciData.clear();
          widget.tamirciData.addAll(_editedData);
        });
      } else {
        _showError('Güncelleme başarısız: ${response.body}');
      }
    } catch (e) {
      _showError('Hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Emin misiniz?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Bu işlem geri alınamaz. Hesabınızı silmek istediğinize emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sil', 
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final id = widget.tamirciData['id'];
    final endpoint = isBireysel ? 'silTamirciBireysel' : 'silTamirciFirma';
    final url = Uri.parse('$apiUrl/$endpoint/$id');

    final response = await http.delete(url);
    
    if (!mounted) return;
    
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnaSayfa(ePosta: widget.ePosta)),
      );
      _showSuccess('Hesap başarıyla silindi');
    } else {
      _showError('Silme işlemi başarısız: ${response.body}');
    }
  }

  Future<void> _toggleServiceStatus(bool newStatus) async {
    final id = widget.tamirciData['id'];
    final endpoint = isBireysel ? 'guncelleDurumTamirciBireysel' : 'guncelleDurumTamirciFirma';
    final url = Uri.parse('$apiUrl/$endpoint/$id');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'durum': newStatus}),
    );

    if (!mounted) return;
    
    if (response.statusCode == 200) {
      setState(() => _isActive = newStatus);
      if (newStatus) {
        _startLocationTracking();
      } else {
        _stopLocationTracking();
      }
      _showSuccess(newStatus ? "Hizmete açıldı 🛠️" : "Hizmet kapatıldı 🔒");
    } else {
      _showError('Durum güncellenemedi: ${response.body}');
    }
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
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

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
                  const Center(
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
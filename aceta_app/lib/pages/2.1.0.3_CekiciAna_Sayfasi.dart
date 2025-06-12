import 'package:aceta_app/pages/2.1.0.3.1_CekiciRandevu_Sayfasi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CekiciAnaSayfasi extends StatefulWidget {
  final Map<String, dynamic> cekiciData;
  final String? ePosta;
  
  const CekiciAnaSayfasi({
    super.key, 
    required this.cekiciData, 
    this.ePosta
  });

  @override
  State<CekiciAnaSayfasi> createState() => _CekiciAnaSayfasiState();
}

class _CekiciAnaSayfasiState extends State<CekiciAnaSayfasi> {
  // Updated color scheme to use orange as primary
  final Color _primaryColor = Color(0xFFF97316); // Orange
  final Color _primaryLight = Color(0xFFFDBA74); // Light orange
  final Color _secondaryColor = Color(0xFF6C757D);
  final Color _accentColor = Color(0xFF5E60CE);
  final Color _successColor = Color(0xFF4CC9F0);
  final Color _dangerColor = Color(0xFFF72585);
  final Color _warningColor = Color(0xFFF8961E);
  final Color _lightBackground = Color(0xFFF8F9FA);
  final Color _darkText = Color(0xFF212529);
  final Color _lightText = Color(0xFFADB5BD);
  
  // State variables
  bool _isActive = false;
  bool _isEditing = false;
  bool _isLoading = false;
  late Map<String, dynamic> _editedData;
  double _puanOrtalamasi = 0.0;
  List<Yorum> _yorumlar = [];
  
  // Dropdown options
  List<String> _vehicleTypes = [];
  List<String> _transportSystems = [];
  List<String> _supportEquipment = [];
  List<String> _technicalEquipment = [];

  @override
  void initState() {
    super.initState();
    _isActive = widget.cekiciData['durum'] == true;
    _editedData = Map.from(widget.cekiciData);
    _fetchPuanOrtalamasi();
    _fetchYorumlar();
    _fetchDropdownOptions();
  }

  Future<void> _fetchPuanOrtalamasi() async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/puan-ortalamasi?'
          '${isIndividual ? 'bireyselId=${widget.cekiciData['id']}' : 'firmaId=${widget.cekiciData['id']}'}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _puanOrtalamasi = (data['ortalama'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Puan ortalaması alınamadı: $e');
    }
  }

  Future<void> _fetchYorumlar() async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7187/api/Randevu/yorumlar?'
          '${isIndividual ? 'bireyselId=${widget.cekiciData['id']}' : 'firmaId=${widget.cekiciData['id']}'}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _yorumlar = data.map((yorum) => Yorum(
            kullaniciAdi: yorum['kullaniciAdi'] ?? 'Anonim',
            yorum: yorum['yorum'] ?? '',
            puan: yorum['puan'] ?? 0,
            tarih: DateTime.parse(yorum['tarih']),),
          ).toList();
        });
      }
    } catch (e) {
      debugPrint('Yorumlar alınamadı: $e');
    }
  }

  Future<void> _fetchDropdownOptions() async {
    try {
      final responses = await Future.wait([
        _fetchApiData('https://localhost:7187/api/Cekici/CekebilecegiAraclar'),
        _fetchApiData('https://localhost:7187/api/Cekici/TasimaSistemleri'),
        _fetchApiData('https://localhost:7187/api/Cekici/DestekEkipmanlari'),
        _fetchApiData('https://localhost:7187/api/Cekici/TeknikEkipmanlari'),
      ]);

      setState(() {
        _vehicleTypes = responses[0];
        _transportSystems = responses[1];
        _supportEquipment = responses[2];
        _technicalEquipment = responses[3];
      });
    } catch (e) {
      _showError('Veriler alınamadı. Lütfen internet bağlantınızı kontrol edin');
    }
  }

  Future<List<String>> _fetchApiData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        return List<String>.from(json.decode(response.body));
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Helper getters
  bool get isIndividual => widget.cekiciData.containsKey('ad');

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
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
        isIndividual ? "Bireysel Çekici Profili" : "Firma Çekici Profili",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),),
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
            builder: (context) => CekiciRandevuSayfasi(
              cekiciId: widget.cekiciData['id'],
              cekiciTipi: isIndividual ? "Bireysel" : "Firma",
            ),
          ),
        );
      },
      icon: Icon(Icons.list_alt, color: Colors.white),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil ikonu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 2),
              ),
              child: Icon(
                isIndividual ? Icons.person : Icons.business,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 16),

            // Kullanıcı bilgileri ve aktiflik durumu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndividual
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
                    _editedData['plakaNo'],
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

            // Durum değiştirme butonu
            Column(
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEditableFields() {
    return isIndividual ? _buildIndividualFields() : _buildCompanyFields();
  }

  List<Widget> _buildIndividualFields() {
    return [
      _buildEditableField("Ad", 'ad', Icons.person_outline),
      _buildEditableField("Soyad", 'soyad', Icons.person),
      _buildEditableField("TC", 'tc', Icons.assignment_ind, editable: false),
      _buildEditableField("Telefon", 'telefon', Icons.phone),
      _buildEditableField("E-Posta", 'ePosta', Icons.email, editable: false),
      _buildMultiSelectField(
        "Çekebileceği Araçlar", 
        'cekebilecegiAraclar', 
        Icons.directions_car,
        options: _vehicleTypes,
      ),
      _buildSingleSelectField(
        "Taşıma Sistemleri", 
        'tasimaSistemleri', 
        Icons.local_shipping,
        options: _transportSystems,
      ),
      _buildMultiSelectField(
        "Destek Ekipmanları", 
        'destekEkipmanlari', 
        Icons.settings,
        options: _supportEquipment,
      ),
      _buildMultiSelectField(
        "Teknik Ekipmanlar", 
        'teknikEkipmanlari', 
        Icons.build,
        options: _technicalEquipment,
      ),
      _buildEditableField(
        "KM Başına Ücret", 
        'kmBasiUcret', 
        Icons.attach_money,
        isNumber: true,
      ),
    ];
  }

  List<Widget> _buildCompanyFields() {
    return [
      _buildEditableField("Firma Adı", 'firmaAdi', Icons.business),
      _buildEditableField("Vergi Kimlik No", 'vergiKimlikNo', Icons.credit_card, editable: false),
      _buildEditableField("Yetkili Kişi", 'yetkiliKisi', Icons.supervised_user_circle),
      _buildEditableField("Telefon", 'telefon', Icons.phone),
      _buildEditableField("E-Posta", 'ePosta', Icons.email, editable: false),
      _buildMultiSelectField(
        "Çekebileceği Araçlar", 
        'cekebilecegiAraclar', 
        Icons.directions_car,
        options: _vehicleTypes,
      ),
      _buildSingleSelectField(
        "Taşıma Sistemleri", 
        'tasimaSistemleri', 
        Icons.local_shipping,
        options: _transportSystems,
      ),
      _buildMultiSelectField(
        "Destek Ekipmanları", 
        'destekEkipmanlari', 
        Icons.settings,
        options: _supportEquipment,
      ),
      _buildMultiSelectField(
        "Teknik Ekipmanlar", 
        'teknikEkipmanlari', 
        Icons.build,
        options: _technicalEquipment,
      ),
      _buildEditableField(
        "KM Başına Ücret", 
        'kmBasiUcret', 
        Icons.attach_money,
        isNumber: true,
      ),
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
                color: _primaryColor.withOpacity(0.1),
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
                              color: _lightText,
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
    final currentItems = (_editedData[dataKey] as List<dynamic>?)?.cast<String>() ?? [];
    
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
                    color: _primaryColor.withOpacity(0.1),
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
                        color: _lightBackground,
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
                                  ? _lightText 
                                  : _darkText,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: _secondaryColor),
                        ],
                      ),
                    ),
                  )
                : currentItems.isEmpty
                    ? Text(
                        'Seçili öğe yok',
                        style: GoogleFonts.poppins(
                          color: _lightText,
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
                            backgroundColor: _primaryColor.withOpacity(0.1),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _isEditing ? () {
                              setState(() {
                                currentItems.remove(item);
                                _editedData[dataKey] = currentItems;
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

  Widget _buildSingleSelectField(String label, String dataKey, IconData icon, {
    required List<String> options,
  }) {
    final currentValue = _editedData[dataKey]?.toString();
    
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
                    color: _primaryColor.withOpacity(0.1),
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
                    onTap: () => _showSingleSelectDialog(label, options, currentValue, dataKey),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                        color: _lightBackground,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentValue ?? 'Seçim yapmak için tıklayın',
                            style: GoogleFonts.poppins(
                              color: currentValue != null 
                                  ? _darkText 
                                  : _lightText,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: _secondaryColor),
                        ],
                      ),
                    ),
                  )
                : Text(
                    currentValue ?? 'Seçili öğe yok',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: currentValue != null ? _darkText : _lightText,
                      fontWeight: currentValue != null ? FontWeight.w500 : FontWeight.normal,
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
                Icon(Icons.star, color: Colors.amber),
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
                      itemBuilder: (context, index) => Icon(
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
            if (_yorumlar.isNotEmpty)
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
                itemBuilder: (context, index) => Icon(
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

  // Dialog Methods
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
                              color: _secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _editedData[dataKey] = List<String>.from(tempSelected);
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

  void _showSingleSelectDialog(String title, List<String> options, 
      String? selectedItem, String dataKey) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                height: MediaQuery.of(context).size.height * 0.3,
                child: SingleChildScrollView(
                  child: Column(
                    children: options.map((item) {
                      return RadioListTile<String>(
                        title: Text(
                          item,
                          style: GoogleFonts.poppins(),
                        ),
                        value: item,
                        groupValue: selectedItem,
                        onChanged: (value) {
                          setState(() {
                            _editedData[dataKey] = value;
                          });
                          Navigator.pop(context);
                        },
                        activeColor: _primaryColor,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
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

  // Business Logic Methods
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _editedData = Map.from(widget.cekiciData);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final id = widget.cekiciData['id'];
      final endpoint = isIndividual ? 'guncelleBireysel' : 'guncelleFirma';
      final url = Uri.parse('https://localhost:7187/api/Cekici/$endpoint/$id');

      // Protect immutable fields
      _editedData['tc'] = widget.cekiciData['tc'];
      _editedData['vergiKimlikNo'] = widget.cekiciData['vergiKimlikNo'];
      _editedData['ePosta'] = widget.cekiciData['ePosta'];
      
      // Only update password if it was changed
      if (_editedData['sifre'] == widget.cekiciData['sifre']) {
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
          widget.cekiciData.clear();
          widget.cekiciData.addAll(_editedData);
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

  Future<void> _toggleServiceStatus(bool newStatus) async {
    final id = widget.cekiciData['id'];
    final endpoint = isIndividual ? 'guncelleDurumBireysel' : 'guncelleDurumFirma';
    final url = Uri.parse('https://localhost:7187/api/Cekici/$endpoint/$id');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'durum': newStatus}),
    );

    if (!mounted) return;
    
    if (response.statusCode == 200) {
      setState(() => _isActive = newStatus);
      _showSuccess(newStatus ? "Hizmete açıldı 🚚" : "Hizmet kapatıldı 🔒");
    } else {
      _showError('Durum güncellenemedi: ${response.body}');
    }
  }

  // Helper Methods
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _dangerColor,
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
        backgroundColor: _successColor,
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
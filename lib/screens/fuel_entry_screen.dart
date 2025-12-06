import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sync_provider.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

/// شاشة إدخال الوقود - SAJCO Fuel Entry Screen
class FuelEntryScreen extends StatefulWidget {
  const FuelEntryScreen({super.key});

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  
  // Controllers
  final _assetNumberController = TextEditingController();
  final _assetDescriptionController = TextEditingController();
  final _projectNumberController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _fuelStationController = TextEditingController();
  final _operatorController = TextEditingController(); // اسم المشغل
  final _lastOdometerController = TextEditingController(); // آخر قراءة عداد
  final _fuelQuantityController = TextEditingController();
  final _odometerController = TextEditingController();
  
  // Timer for auto-search
  Timer? _searchTimer;
  
  // Selected values
  String? _selectedFuelType;
  String? _odometerImagePath;
  bool _isLoading = false;
  bool _isSearching = false;
  
  // Data from Excel
  List<Map<String, dynamic>> _excelAssets = [];
  List<Map<String, dynamic>> _excelProjects = [];
  List<Map<String, dynamic>> _excelStations = [];
  Map<String, dynamic>? _selectedAssetData;
  
  // Fuel types - including common Excel values
  final List<Map<String, String>> _fuelTypes = [
    {'code': 'FUEL-D1', 'nameAr': 'سولار D1', 'nameEn': 'Diesel D1'},
    {'code': 'FUEL-D2', 'nameAr': 'سولار D2', 'nameEn': 'Diesel D2'},
    {'code': 'DIESEL', 'nameAr': 'سولار', 'nameEn': 'Diesel'},
    {'code': 'PETROL92', 'nameAr': 'بنزين 92', 'nameEn': 'Petrol 92'},
    {'code': 'PETROL95', 'nameAr': 'بنزين 95', 'nameEn': 'Petrol 95'},
    {'code': 'GAS', 'nameAr': 'غاز', 'nameEn': 'Gas'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    
    // إضافة listener للبحث التلقائي
    _assetNumberController.addListener(_onAssetNumberChanged);
  }
  
  /// البحث التلقائي عند تغيير رقم الأصل
  void _onAssetNumberChanged() {
    // إلغاء Timer السابق
    _searchTimer?.cancel();
    
    final assetNumber = _assetNumberController.text.trim();
    
    // البحث فقط إذا كان الرقم طويل بما يكفي (4 أحرف على الأقل)
    if (assetNumber.length >= 4) {
      // تأخير البحث 500ms بعد التوقف عن الكتابة
      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        _searchAndFillAssetData(assetNumber);
      });
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _assetNumberController.removeListener(_onAssetNumberChanged);
    _assetNumberController.dispose();
    _assetDescriptionController.dispose();
    _projectNumberController.dispose();
    _projectNameController.dispose();
    _fuelStationController.dispose();
    _operatorController.dispose();
    _lastOdometerController.dispose();
    _fuelQuantityController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  /// تحميل البيانات من Excel API
  Future<void> _loadExcelData() async {
    try {
      final assetsResult = await _apiService.getAssets();
      final projectsResult = await _apiService.getProjects();
      final stationsResult = await _apiService.getFuelStations();
      
      if (mounted) {
        setState(() {
          if (assetsResult['success'] == true) {
            _excelAssets = List<Map<String, dynamic>>.from(assetsResult['data'] ?? []);
          }
          if (projectsResult['success'] == true) {
            _excelProjects = List<Map<String, dynamic>>.from(projectsResult['data'] ?? []);
          }
          if (stationsResult['success'] == true) {
            _excelStations = List<Map<String, dynamic>>.from(stationsResult['data'] ?? []);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading Excel data: $e');
    } finally {
       debugPrint('MASTER ASSETS LOADED: ${_excelAssets.length}');
       if (_excelAssets.isEmpty) {
          debugPrint('⚠️ WARNING: Master assets list is empty! Fallback search will fail.');
       }
    }
  }

  /// البحث عن الأصل وتعبئة البيانات تلقائياً
  Future<void> _searchAndFillAssetData(String assetNumber) async {
    if (assetNumber.isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      // البحث مباشرة في المعاملات للحصول على كل البيانات
      final transResult = await _apiService.getTransactions(
        assetNumber: assetNumber,
        limit: 1,
      );
      
      if (transResult['success'] == true && (transResult['data'] as List).isNotEmpty) {
        final transaction = (transResult['data'] as List).first;
        
        // طباعة تشخيصية
        debugPrint('=== Transaction Data ===');
        debugPrint('assetNumber: ${transaction['assetNumber']}');
        debugPrint('projectNumber: ${transaction['projectNumber']}');
        debugPrint('projectName: ${transaction['projectName']}');
        debugPrint('fuelStation: ${transaction['fuelStation']}');
        debugPrint('operatorNumber: ${transaction['operatorNumber']}');
        debugPrint('========================');
        
        _fillAssetData({
          'assetNumber': transaction['assetNumber'],
          'description': transaction['assetDescription'],
          'fuelType': transaction['fuelType'],
          'projectNumber': transaction['projectNumber'],
          'projectName': transaction['projectName'],
          'fuelStation': transaction['fuelStation'],
          'operatorNumber': transaction['operatorNumber'],
          'odometer': transaction['odometer'],
        });
      } else {
        // Fallback: Search in Master Assets List (_excelAssets)
        // This handles cases where the asset exists but has no previous transactions
        final masterAsset = _excelAssets.firstWhere(
          (a) => a['assetNumber'].toString().trim() == assetNumber.trim(),
          orElse: () => {},
        );

        if (masterAsset.isNotEmpty) {
           debugPrint('Found in Master Assets: ${masterAsset['assetNumber']}');
           _fillAssetData({
             'assetNumber': masterAsset['assetNumber'],
             'description': masterAsset['description'] ?? masterAsset['assetDescription'],
             'fuelType': masterAsset['fuelType'],
             'projectNumber': '', // New asset might not have project linked yet
             'projectName': '',
             'fuelStation': '',
             'operatorNumber': '',
             'odometer': null,
           });
           return;
        }

        // Show specific error if API failed, otherwise 'Asset not found'
        final message = transResult['success'] == false
            ? (transResult['message'] ?? 'Error')
            : (AppLocalizations.of(context)!.isArabic ? 'لم يتم العثور على الأصل' : 'Asset not found');
            
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      debugPrint('Error searching asset: $e');
      _showSnackBar(
        AppLocalizations.of(context)!.isArabic 
            ? 'خطأ في الاتصال' 
            : 'Connection error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// تعبئة بيانات الأصل
  void _fillAssetData(Map<String, dynamic> assetData) {
    setState(() {
      _selectedAssetData = assetData;
      _assetDescriptionController.text = assetData['description']?.toString() ?? '';
      _projectNumberController.text = assetData['projectNumber']?.toString() ?? '';
      _projectNameController.text = assetData['projectName']?.toString() ?? '';
      _fuelStationController.text = assetData['fuelStation']?.toString() ?? '';
      _operatorController.text = assetData['operatorNumber']?.toString() ?? '';
      
      // آخر قراءة للعداد
      final lastOdometer = assetData['odometer'];
      if (lastOdometer != null) {
        _lastOdometerController.text = '$lastOdometer km';
      } else {
        _lastOdometerController.text = '-';
      }
      
      // تعيين نوع الوقود فقط إذا كان موجوداً في القائمة
      final fuelType = assetData['fuelType']?.toString();
      if (fuelType != null && fuelType.isNotEmpty) {
        // التحقق من وجود القيمة في القائمة
        final exists = _fuelTypes.any((f) => f['code'] == fuelType);
        if (exists) {
          _selectedFuelType = fuelType;
        }
      }
    });
    
    _showSnackBar(
      AppLocalizations.of(context)!.isArabic 
          ? 'تم تعبئة البيانات تلقائياً ✓' 
          : 'Data auto-filled ✓',
    );
  }

  Future<void> _captureOdometerImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
      
      if (image != null) {
        setState(() {
          _odometerImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening camera', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final loc = AppLocalizations.of(context)!;
      final dbService = DatabaseService.instance;
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);
      
      // التحقق من حالة الاتصال
      final isOnline = syncProvider.isOnline;
      
      // إنشاء معرف فريد محلي
      final localTransactionId = 'TRX_${DateTime.now().millisecondsSinceEpoch}';
      
      // بيانات المعاملة (للقاعدة المحلية)
      final transactionData = {
        'local_transaction_id': localTransactionId,
        'equipment_id': null, // سيتم تحديثه لاحقاً
        'fuel_type': _selectedFuelType,
        'quantity': double.tryParse(_fuelQuantityController.text) ?? 0,
        'odometer': int.tryParse(_odometerController.text),
        'transaction_date': DateTime.now().toIso8601String(),
        'notes': 'Asset: ${_assetNumberController.text}, Project: ${_projectNumberController.text}',
        'sync_status': isOnline ? 'SYNCED' : 'PENDING', // إذا كان متصلاً سنحاول المزامنة فوراً
      };
      
      // بيانات للإرسال عبر API
      final apiData = {
        'assetNumber': _assetNumberController.text,
        'assetDescription': _assetDescriptionController.text,
        'fuelType': _selectedFuelType,
        'fuelQuantity': double.tryParse(_fuelQuantityController.text) ?? 0,
        'projectNumber': _projectNumberController.text,
        'projectName': _projectNameController.text,
        'fuelStation': _fuelStationController.text,
        'odometer': int.tryParse(_odometerController.text),
        'operatorNumber': _operatorController.text,
        'creationDate': DateTime.now().toIso8601String(),
        'creationUser': Provider.of<AuthProvider>(context, listen: false).operator?.name ?? 'Mobile App',
      };

      if (isOnline) {
        // === حالة الاتصال: إرسال للسيرفر وحفظ محلي ===
        try {
          final result = await _apiService.addTransaction(apiData);
          
          if (result['success'] == true) {
            // نجح الإرسال -> حفظ محلي كـ SYNCED
            transactionData['sync_status'] = 'SYNCED';
            await dbService.insertTransaction(transactionData);
            
            if (mounted) {
              _showSnackBar(loc.isArabic ? 'تم حفظ المعاملة ✓' : 'Transaction saved ✓');
              _clearForm();
            }
          } else {
            throw Exception('API returned false');
          }
        } catch (e) {
          // فشل الإرسال رغم الاتصال ( timeout مثلاً) -> حفظ محلي كـ PENDING
          debugPrint('Online but failed to sync: $e');
          transactionData['sync_status'] = 'PENDING';
          await dbService.insertTransaction(transactionData);
          
          if (mounted) {
            _showSnackBar(loc.isArabic ? 'تم الحفظ محلياً ⏳' : 'Saved locally ⏳');
            _clearForm();
            syncProvider.refreshPendingCount();
          }
        }
      } else {
        // === حالة عدم الاتصال (Offline): حفظ محلي فوراً ===
        debugPrint('Offline mode: Saving locally directly');
        transactionData['sync_status'] = 'PENDING';
        await dbService.insertTransaction(transactionData);
        
        if (mounted) {
          _showSnackBar(
            loc.isArabic 
                ? 'لا يوجد انترنت - تم الحفظ محلياً ⏳' 
                : 'No internet - Saved locally ⏳',
          );
          _clearForm();
          syncProvider.refreshPendingCount();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.isArabic ? 'خطأ: $e' : 'Error: $e', 
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _assetNumberController.clear();
    _assetDescriptionController.clear();
    _projectNumberController.clear();
    _projectNameController.clear();
    _fuelStationController.clear();
    _fuelQuantityController.clear();
    _odometerController.clear();
    setState(() {
      _selectedFuelType = null;
      _odometerImagePath = null;
      _selectedAssetData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: _buildAppBar(loc),
        body: _buildBody(loc),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_gas_station, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            loc.isArabic ? 'معاملة جديدة' : 'New Transaction',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        // Language Toggle
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) => TextButton(
            onPressed: () => langProvider.toggleLanguage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                langProvider.isArabic ? 'EN' : 'ع',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Logout button
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Scanner Button
            _buildQRScannerButton(loc),
            const SizedBox(height: 16),
            
            // Asset Number Card - الحقل الرئيسي للإدخال
            _buildAssetNumberCard(loc),
            const SizedBox(height: 16),
            
            // Auto-filled Data Card - البيانات التلقائية (للقراءة فقط)
            _buildAutoFilledDataCard(loc),
            const SizedBox(height: 16),
            
            // Manual Entry Card - الحقول اليدوية
            _buildManualEntryCard(loc),
            const SizedBox(height: 16),
            
            // Odometer Card
            _buildOdometerCard(loc),
            const SizedBox(height: 24),
            
            // Submit Button
            _buildSubmitButton(loc),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScannerButton(AppLocalizations loc) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/scanner');
        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            _assetNumberController.text = result['assetNumber'] ?? '';
          });
          if (result['assetNumber'] != null) {
            _searchAndFillAssetData(result['assetNumber']);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.isArabic ? 'مسح QR Code' : 'Scan QR Code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.isArabic 
                        ? 'امسح رمز الأصل لتعبئة البيانات تلقائياً'
                        : 'Scan asset code to auto-fill',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetNumberCard(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                loc.isArabic ? 'رقم الأصل *' : 'Asset Number *',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: TextFormField(
                    controller: _assetNumberController,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: loc.isArabic ? 'أدخل رقم الأصل...' : 'Enter asset number...',
                      hintStyle: const TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.normal),
                    ),
                    validator: (value) => value?.isEmpty == true 
                        ? (loc.isArabic ? 'مطلوب' : 'Required') 
                        : null,
                    onFieldSubmitted: (value) => _searchAndFillAssetData(value),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isSearching 
                      ? null 
                      : () => _searchAndFillAssetData(_assetNumberController.text),
                  icon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.isArabic 
                ? '💡 أدخل الرقم واضغط بحث لتعبئة البيانات تلقائياً'
                : '💡 Enter number and press search to auto-fill',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoFilledDataCard(AppLocalizations loc) {
    final hasData = _selectedAssetData != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasData ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasData ? Icons.check_circle : Icons.info_outline,
                color: hasData ? Colors.green : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                loc.isArabic ? 'البيانات التلقائية' : 'Auto-filled Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasData ? Colors.green.shade700 : AppTheme.textSecondary,
                ),
              ),
              if (hasData) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    loc.isArabic ? 'تم التعبئة' : 'Filled',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Asset Description
          _buildReadOnlyField(
            label: loc.isArabic ? 'وصف الأصل' : 'Asset Description',
            controller: _assetDescriptionController,
            icon: Icons.description,
          ),
          const SizedBox(height: 12),
          
          // Operator Name - اسم المشغل
          _buildReadOnlyField(
            label: loc.isArabic ? 'اسم المشغل' : 'Operator',
            controller: _operatorController,
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          
          // Project Number & Name
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: loc.isArabic ? 'رقم المشروع' : 'Project #',
                  controller: _projectNumberController,
                  icon: Icons.folder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadOnlyField(
                  label: loc.isArabic ? 'اسم المشروع' : 'Project Name',
                  controller: _projectNameController,
                  icon: Icons.work,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Fuel Station & Last Odometer
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: loc.isArabic ? 'محطة الوقود' : 'Fuel Station',
                  controller: _fuelStationController,
                  icon: Icons.local_gas_station,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadOnlyField(
                  label: loc.isArabic ? 'آخر قراءة عداد' : 'Last Odometer',
                  controller: _lastOdometerController,
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.text.isEmpty ? '-' : controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.text.isEmpty 
                        ? AppTheme.textHint 
                        : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryCard(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                loc.isArabic ? 'البيانات المطلوب إدخالها' : 'Required Entry',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Fuel Type
          Text(
            loc.isArabic ? 'نوع الوقود *' : 'Fuel Type *',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedFuelType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(Icons.local_gas_station, color: AppTheme.primaryColor),
              ),
              hint: Text(loc.isArabic ? 'اختر نوع الوقود...' : 'Select fuel type...'),
              items: _fuelTypes.map((fuel) {
                return DropdownMenuItem<String>(
                  value: fuel['code'],
                  child: Text(loc.isArabic ? fuel['nameAr']! : fuel['nameEn']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              },
              validator: (value) => value == null ? (loc.isArabic ? 'مطلوب' : 'Required') : null,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 20),
          
          // Fuel Quantity
          Text(
            loc.isArabic ? 'كمية الوقود (لتر) *' : 'Fuel Quantity (Liters) *',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: TextFormField(
              controller: _fuelQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                suffixText: loc.isArabic ? 'لتر' : 'L',
                suffixStyle: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return loc.isArabic ? 'مطلوب' : 'Required';
                if (double.tryParse(value) == null) return loc.isArabic ? 'قيمة غير صالحة' : 'Invalid';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerCard(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.isArabic ? 'قراءة العداد' : 'Odometer Reading',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: loc.isArabic ? 'أدخل قراءة العداد' : 'Enter odometer',
                hintStyle: const TextStyle(color: AppTheme.textHint),
                prefixIcon: const Icon(Icons.speed, color: AppTheme.primaryColor),
                suffixText: 'km',
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            loc.isArabic ? 'صورة العداد' : 'Odometer Image',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _captureOdometerImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: _odometerImagePath != null 
                    ? AppTheme.successColor.withValues(alpha: 0.1) 
                    : const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _odometerImagePath != null ? AppTheme.successColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: _odometerImagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_odometerImagePath!), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _odometerImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, size: 32, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        Text(
                          loc.isArabic ? 'التقط صورة العداد' : 'Capture odometer',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations loc) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppTheme.primaryColor,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  loc.isArabic ? 'حفظ المعاملة' : 'Save Transaction',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

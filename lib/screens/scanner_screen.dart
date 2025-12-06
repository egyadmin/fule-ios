import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _processCode(String code) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // البحث في بيانات Excel عن الأصل
      final result = await _apiService.getAssets();
      
      if (result['success'] == true) {
        final assets = result['data'] as List;
        
        // البحث عن الأصل بالكود الممسوح
        final matchingAsset = assets.firstWhere(
          (asset) => 
            asset['assetNumber']?.toString().contains(code) == true ||
            code.contains(asset['assetNumber']?.toString() ?? ''),
          orElse: () => null,
        );
        
        if (matchingAsset != null && mounted) {
          // إرجاع بيانات الأصل للشاشة السابقة
          Navigator.pop(context, {
            'assetNumber': matchingAsset['assetNumber'],
            'assetDescription': matchingAsset['description'],
            'fuelType': matchingAsset['fuelType'],
          });
          return;
        }
      }
      
      // لم يتم العثور على الأصل
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.isArabic 
                  ? 'لم يتم العثور على أصل برقم: $code'
                  : 'No asset found with code: $code'
            ),
            backgroundColor: AppTheme.warningColor,
            action: SnackBarAction(
              label: loc.isArabic ? 'استخدام الرقم' : 'Use Code',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context, {
                  'assetNumber': code,
                  'assetDescription': '',
                });
              },
            ),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.isArabic ? 'خطأ في الاتصال' : 'Connection error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showManualEntryDialog() {
    final loc = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: loc.textDirection,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.isArabic ? 'أدخل رقم الأصل يدوياً' : 'Enter Asset Code Manually',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: loc.isArabic ? 'رقم الأصل' : 'Asset Code',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Navigator.pop(context);
                      _processCode(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_codeController.text.isNotEmpty) {
                      Navigator.pop(context);
                      _processCode(_codeController.text);
                    }
                  },
                  child: Text(
                    loc.isArabic ? 'بحث' : 'Search',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.isArabic ? 'مسح QR Code' : 'Scan QR Code',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _controller.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  );
                },
              ),
              onPressed: () => _controller.toggleTorch(),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Camera View
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processCode(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
            
            // Overlay with scan area
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            
            // Instructions
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loc.isArabic 
                        ? 'وجه الكاميرا نحو رمز QR للأصل'
                        : 'Point camera at asset QR code',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Loading Indicator
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جار البحث...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Manual Entry Button
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.keyboard),
                label: Text(
                  loc.isArabic ? 'إدخال الرقم يدوياً' : 'Enter Code Manually',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

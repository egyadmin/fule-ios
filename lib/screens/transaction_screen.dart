import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../providers/transaction_provider.dart';
import '../providers/equipment_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  
  Equipment? _selectedEquipment;
  String? _selectedFuelType;
  double _unitPrice = 0;
  bool _isLoading = false;
  Map<String, double> _fuelPrices = {};

  final List<Map<String, dynamic>> _fuelTypes = [
    {'code': 'PETROL80', 'colorAr': 'بنزين 80', 'colorEn': 'Petrol 80', 'color': AppTheme.petrol80Color},
    {'code': 'PETROL92', 'colorAr': 'بنزين 92', 'colorEn': 'Petrol 92', 'color': AppTheme.petrol92Color},
    {'code': 'PETROL95', 'colorAr': 'بنزين 95', 'colorEn': 'Petrol 95', 'color': AppTheme.petrol95Color},
    {'code': 'DIESEL', 'colorAr': 'سولار', 'colorEn': 'Diesel', 'color': AppTheme.dieselColor},
  ];

  @override
  void initState() {
    super.initState();
    _loadFuelPrices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['equipment'] != null) {
      _selectedEquipment = args['equipment'] as Equipment;
    }
  }

  Future<void> _loadFuelPrices() async {
    _fuelPrices = await DatabaseService.instance.getAllFuelPrices();
    setState(() {});
  }

  double get _totalAmount {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    return quantity * _unitPrice;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEquipment == null || _selectedFuelType == null) return;

    setState(() {
      _isLoading = true;
    });

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final loc = AppLocalizations.of(context)!;
    
    final success = await transactionProvider.saveTransaction(
      equipmentId: _selectedEquipment!.equipmentId,
      fuelType: _selectedFuelType!,
      quantity: double.parse(_quantityController.text),
      unitPrice: _unitPrice,
      odometer: _odometerController.text.isNotEmpty 
          ? int.parse(_odometerController.text) 
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('transaction_saved')),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('transaction_failed')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = loc.isArabic;

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.translate('new_transaction'),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Equipment Info Card
                if (_selectedEquipment != null)
                  _buildEquipmentCard(isArabic, loc)
                else
                  _buildEquipmentSelector(loc),
                
                const SizedBox(height: 20),
                
                // Fuel Type Selection
                Text(
                  loc.translate('fuel_type'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFuelTypeSelector(isArabic),
                
                const SizedBox(height: 20),
                
                // Quantity Input
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: loc.translate('quantity_liters'),
                    prefixIcon: const Icon(Icons.local_gas_station),
                    suffixText: loc.translate('liters'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.translate('please_enter_quantity');
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return loc.translate('invalid_quantity');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Odometer Input
                TextFormField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('odometer_km')} (${loc.translate('optional')})',
                    prefixIcon: const Icon(Icons.speed),
                    suffixText: 'km',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('notes')} (${loc.translate('optional')})',
                    prefixIcon: const Icon(Icons.note),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Total Amount Card
                if (_selectedFuelType != null && _quantityController.text.isNotEmpty)
                  _buildTotalCard(loc),
                
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  onPressed: (_selectedEquipment != null && 
                             _selectedFuelType != null && 
                             !_isLoading)
                      ? _saveTransaction
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          loc.submit,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(bool isArabic, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEquipment!.displayName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedEquipment!.getLocalizedType(isArabic),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedEquipment = null;
                  });
                },
              ),
            ],
          ),
          if (_selectedEquipment!.driverName != null) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.person, loc.translate('driver_name'), _selectedEquipment!.driverName!),
          ],
          if (_selectedEquipment!.department != null)
            _buildInfoRow(Icons.business, loc.translate('department'), _selectedEquipment!.department!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSelector(AppLocalizations loc) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/scanner'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              loc.scanQr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              loc.isArabic ? 'أو أدخل الكود يدوياً' : 'or enter code manually',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeSelector(bool isArabic) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _fuelTypes.map((fuel) {
        final isSelected = _selectedFuelType == fuel['code'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFuelType = fuel['code'];
              _unitPrice = _fuelPrices[fuel['code']] ?? 0;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? fuel['color'] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? fuel['color'] : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (fuel['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              isArabic ? fuel['colorAr'] : fuel['colorEn'],
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalCard(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loc.translate('total_amount'),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_totalAmount.toStringAsFixed(2)} ${loc.translate('currency')}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }
}

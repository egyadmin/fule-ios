import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../models/fuel_transaction.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  String? _selectedFuelType;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
    }
    
    await provider.loadTransactions(
      fuelType: _selectedFuelType,
      startDate: startDate,
      endDate: endDate,
    );
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
            loc.translate('transaction_history'),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', loc.translate('all'), isArabic),
                        const SizedBox(width: 8),
                        _buildFilterChip('today', loc.translate('today'), isArabic),
                        const SizedBox(width: 8),
                        _buildFilterChip('week', loc.translate('this_week'), isArabic),
                        const SizedBox(width: 8),
                        _buildFilterChip('month', loc.translate('this_month'), isArabic),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Fuel Type Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFuelFilterChip(null, loc.translate('all'), isArabic),
                        const SizedBox(width: 8),
                        _buildFuelFilterChip('PETROL80', isArabic ? 'بنزين 80' : 'Petrol 80', isArabic),
                        const SizedBox(width: 8),
                        _buildFuelFilterChip('PETROL92', isArabic ? 'بنزين 92' : 'Petrol 92', isArabic),
                        const SizedBox(width: 8),
                        _buildFuelFilterChip('PETROL95', isArabic ? 'بنزين 95' : 'Petrol 95', isArabic),
                        const SizedBox(width: 8),
                        _buildFuelFilterChip('DIESEL', isArabic ? 'سولار' : 'Diesel', isArabic),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (provider.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('no_transactions'),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = provider.transactions[index];
                        return _buildTransactionCard(transaction, loc, isArabic);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isArabic) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _loadTransactions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFuelFilterChip(String? value, String label, bool isArabic) {
    final isSelected = _selectedFuelType == value;
    Color chipColor = Colors.grey;
    
    if (value != null) {
      switch (value) {
        case 'PETROL80':
          chipColor = AppTheme.petrol80Color;
          break;
        case 'PETROL92':
          chipColor = AppTheme.petrol92Color;
          break;
        case 'PETROL95':
          chipColor = AppTheme.petrol95Color;
          break;
        case 'DIESEL':
          chipColor = AppTheme.dieselColor;
          break;
      }
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFuelType = value;
        });
        _loadTransactions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(FuelTransaction transaction, AppLocalizations loc, bool isArabic) {
    Color fuelColor;
    switch (transaction.fuelType) {
      case 'PETROL80':
        fuelColor = AppTheme.petrol80Color;
        break;
      case 'PETROL92':
        fuelColor = AppTheme.petrol92Color;
        break;
      case 'PETROL95':
        fuelColor = AppTheme.petrol95Color;
        break;
      case 'DIESEL':
        fuelColor = AppTheme.dieselColor;
        break;
      default:
        fuelColor = AppTheme.primaryColor;
    }
    
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', isArabic ? 'ar' : 'en');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              // Fuel Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fuelColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.getLocalizedFuelType(isArabic),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Sync Status
              _buildSyncStatusBadge(transaction, loc),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('quantity'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${transaction.quantity} ${loc.translate('liters')}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Total Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loc.translate('total_amount'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${transaction.totalAmount.toStringAsFixed(2)} ${loc.translate('currency')}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: fuelColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          // Date and Time
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(transaction.transactionDate),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (transaction.odometer != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.speed, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  '${transaction.odometer} km',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.note, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    transaction.notes!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncStatusBadge(FuelTransaction transaction, AppLocalizations loc) {
    Color color;
    IconData icon;
    String text;
    
    if (transaction.isSynced) {
      color = AppTheme.successColor;
      icon = Icons.cloud_done;
      text = loc.translate('synced');
    } else if (transaction.isFailed) {
      color = AppTheme.errorColor;
      icon = Icons.cloud_off;
      text = loc.translate('failed');
    } else {
      color = AppTheme.warningColor;
      icon = Icons.cloud_upload;
      text = loc.translate('pending');
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

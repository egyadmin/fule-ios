import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class SyncProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _syncError;
  int _pendingCount = 0;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime?.toString().substring(0, 16);
  String? get syncError => _syncError;
  int get pendingCount => _pendingCount;

  SyncProvider() {
    _initConnectivity();
    _loadPendingCount();
  }

  Future<void> _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
      
      // Auto sync when back online
      if (_isOnline && _pendingCount > 0) {
        syncAll();
      }
    });
    
    notifyListeners();
  }

  Future<void> _loadPendingCount() async {
    _pendingCount = await _dbService.getPendingTransactionsCount();
    notifyListeners();
  }

  Future<bool> syncAll() async {
    if (!_isOnline || _isSyncing) return false;
    
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      // Get pending transactions from local DB
      final pendingTransactions = await _dbService.getPendingTransactions();
      
      if (pendingTransactions.isNotEmpty) {
        debugPrint('Syncing ${pendingTransactions.length} pending transactions...');
        
        // Upload each transaction to Excel API
        for (final transaction in pendingTransactions) {
          try {
            // تحويل البيانات المحلية لصيغة API
            final apiData = {
              'assetNumber': _extractAssetFromNotes(transaction['notes']),
              'fuelType': transaction['fuel_type'],
              'fuelQuantity': transaction['quantity'],
              'odometer': transaction['odometer'],
              'creationDate': transaction['transaction_date'],
              'creationUser': 'Mobile App (Synced)',
            };
            
            final result = await _apiService.addTransaction(apiData);
            
            if (result['success'] == true) {
              // Update local sync status
              final localId = transaction['local_transaction_id'] as String?;
              if (localId != null) {
                await _dbService.updateTransactionSyncStatus(localId, 'SYNCED');
                debugPrint('✓ Synced transaction: $localId');
              }
            }
          } catch (e) {
            debugPrint('Error syncing transaction: $e');
          }
        }
      }
      
      // Download latest transactions from Excel
      try {
        final downloadResult = await _apiService.getTransactions(limit: 100);
        
        if (downloadResult['success'] == true) {
          final transactionsList = downloadResult['data'] as List;
          debugPrint('Downloaded ${transactionsList.length} transactions from Excel');
        }
      } catch (e) {
        debugPrint('Error downloading transactions: $e');
      }
      
      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      await _loadPendingCount();
      notifyListeners();
      return true;
      
    } catch (e) {
      _syncError = e.toString();
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshPendingCount() async {
    await _loadPendingCount();
  }

  // Alias for syncAll
  Future<bool> syncNow() => syncAll();
  
  /// استخراج رقم الأصل من الملاحظات
  String? _extractAssetFromNotes(String? notes) {
    if (notes == null) return null;
    // Format: "Asset: XX-XXXX, Project: XXXXX"
    final match = RegExp(r'Asset: ([^,]+)').firstMatch(notes);
    return match?.group(1)?.trim();
  }
}

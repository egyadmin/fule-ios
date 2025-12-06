import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/fuel_transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final Uuid _uuid = const Uuid();
  
  List<FuelTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  int _todayCount = 0;
  double _todayTotal = 0;

  List<FuelTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayCount => _todayCount;
  double get todayTotal => _todayTotal;

  Future<void> loadTransactions({
    int? equipmentId,
    String? fuelType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dbService.getTransactions(
        equipmentId: equipmentId,
        fuelType: fuelType,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      _transactions = data.map((e) => FuelTransaction.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayStats() async {
    try {
      final stats = await _dbService.getTodayStats();
      _todayCount = stats['count'] ?? 0;
      _todayTotal = stats['total'] ?? 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today stats: $e');
    }
  }

  Future<bool> saveTransaction({
    required int equipmentId,
    required String fuelType,
    required double quantity,
    double? unitPrice,
    int? odometer,
    String? notes,
  }) async {
    try {
      final totalAmount = quantity * (unitPrice ?? 0);
      
      final transaction = FuelTransaction(
        assetNumber: equipmentId.toString(),
        fuelType: fuelType,
        fuelQuantity: quantity,
        price: unitPrice,
        odometer: odometer,
        creationDate: DateTime.now(),
        fuelDescription: notes,
        syncStatus: 'PENDING',
      );
      
      await _dbService.insertTransaction(transaction.toJson());
      await loadTodayStats();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

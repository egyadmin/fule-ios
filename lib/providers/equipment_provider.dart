import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/equipment.dart';

class EquipmentProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  
  List<Equipment> _equipmentList = [];
  Equipment? _selectedEquipment;
  bool _isLoading = false;
  String? _error;

  List<Equipment> get equipmentList => _equipmentList;
  Equipment? get selectedEquipment => _selectedEquipment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllEquipment() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dbService.getAllEquipment();
      _equipmentList = data.map((e) => Equipment.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Equipment?> findByCode(String code) async {
    try {
      final data = await _dbService.getEquipmentByCode(code);
      if (data != null) {
        _selectedEquipment = Equipment.fromJson(data);
        notifyListeners();
        return _selectedEquipment;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void setSelectedEquipment(Equipment? equipment) {
    _selectedEquipment = equipment;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEquipment = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

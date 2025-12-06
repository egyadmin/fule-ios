class Equipment {
  final int equipmentId;
  final String equipmentCode;
  final String equipmentType;
  final String? plateNumber;
  final String? driverName;
  final String? department;
  final String status;
  final DateTime? lastSyncDate;

  Equipment({
    required this.equipmentId,
    required this.equipmentCode,
    required this.equipmentType,
    this.plateNumber,
    this.driverName,
    this.department,
    required this.status,
    this.lastSyncDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentId: json['equipment_id'] ?? json['EQUIPMENT_ID'] ?? 0,
      equipmentCode: json['equipment_code'] ?? json['EQUIPMENT_CODE'] ?? '',
      equipmentType: json['equipment_type'] ?? json['EQUIPMENT_TYPE'] ?? '',
      plateNumber: json['plate_number'] ?? json['PLATE_NUMBER'],
      driverName: json['driver_name'] ?? json['DRIVER_NAME'],
      department: json['department'] ?? json['DEPARTMENT'],
      status: json['status'] ?? json['STATUS'] ?? 'ACTIVE',
      lastSyncDate: json['last_sync_date'] != null 
          ? DateTime.tryParse(json['last_sync_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': equipmentId,
      'equipment_code': equipmentCode,
      'equipment_type': equipmentType,
      'plate_number': plateNumber,
      'driver_name': driverName,
      'department': department,
      'status': status,
      'last_sync_date': lastSyncDate?.toIso8601String(),
    };
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  
  String get displayName => plateNumber ?? equipmentCode;
  
  String getLocalizedType(bool isArabic) {
    final types = {
      'Car': isArabic ? 'سيارة' : 'Car',
      'Truck': isArabic ? 'شاحنة' : 'Truck',
      'Pickup': isArabic ? 'بيك اب' : 'Pickup',
      'Bus': isArabic ? 'حافلة' : 'Bus',
      'Generator': isArabic ? 'مولد' : 'Generator',
      'Motorcycle': isArabic ? 'دراجة نارية' : 'Motorcycle',
    };
    return types[equipmentType] ?? equipmentType;
  }
}

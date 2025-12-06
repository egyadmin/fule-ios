/// نموذج معاملة تعبئة الوقود - SAJCO Fuel Transaction Model
class FuelTransaction {
  final int? id;
  final String? fillNumber;           // رقم الفاتورة
  final DateTime creationDate;        // تاريخ الإنشاء
  final String? creationUser;         // المستخدم
  final String? fuelStation;          // محطة الوقود
  final String assetNumber;           // رقم الأصل
  final String? assetDescription;     // وصف الأصل
  final String fuelType;              // نوع الوقود
  final String? fuelDescription;      // وصف الوقود
  final String? projectNumber;        // رقم المشروع
  final String? projectName;          // اسم المشروع
  final double fuelQuantity;          // كمية الوقود
  final double? price;                // السعر
  final int? odometer;                // عداد المسافة
  final String? odometerImagePath;    // صورة العداد
  final String syncStatus;            // PENDING, SYNCED, FAILED
  final String? syncError;
  final DateTime? syncedAt;

  FuelTransaction({
    this.id,
    this.fillNumber,
    required this.creationDate,
    this.creationUser,
    this.fuelStation,
    required this.assetNumber,
    this.assetDescription,
    required this.fuelType,
    this.fuelDescription,
    this.projectNumber,
    this.projectName,
    required this.fuelQuantity,
    this.price,
    this.odometer,
    this.odometerImagePath,
    required this.syncStatus,
    this.syncError,
    this.syncedAt,
  });

  factory FuelTransaction.fromJson(Map<String, dynamic> json) {
    return FuelTransaction(
      id: json['id'],
      fillNumber: json['fill_number'] ?? json['FILL_NUMBER'],
      creationDate: DateTime.tryParse(
        (json['creation_date'] ?? json['CREATION_DATE'] ?? '').toString()
      ) ?? DateTime.now(),
      creationUser: json['creation_user'] ?? json['CREATION_USER'],
      fuelStation: json['fuel_station'] ?? json['FUEL_STATION'],
      assetNumber: json['asset_number'] ?? json['ASSET_NUMBER'] ?? '',
      assetDescription: json['asset_description'] ?? json['ASSET_DESCRIPTION'],
      fuelType: json['fuel_type'] ?? json['FUEL_TYPE'] ?? '',
      fuelDescription: json['fuel_description'] ?? json['FUEL_DESCRIPTION'],
      projectNumber: json['project_number'] ?? json['PROJECT_NUMBER'],
      projectName: json['project_name'] ?? json['PROJECT_NAME'],
      fuelQuantity: (json['fuel_quantity'] ?? json['FUEL_QUANTITY'] ?? 0).toDouble(),
      price: json['price'] != null ? (json['price'] ?? json['PRICE']).toDouble() : null,
      odometer: json['odometer'] ?? json['ODOMETER'],
      odometerImagePath: json['odometer_image_path'],
      syncStatus: json['sync_status'] ?? 'PENDING',
      syncError: json['sync_error'],
      syncedAt: json['synced_at'] != null 
          ? DateTime.tryParse(json['synced_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fill_number': fillNumber,
      'creation_date': creationDate.toIso8601String(),
      'creation_user': creationUser,
      'fuel_station': fuelStation,
      'asset_number': assetNumber,
      'asset_description': assetDescription,
      'fuel_type': fuelType,
      'fuel_description': fuelDescription,
      'project_number': projectNumber,
      'project_name': projectName,
      'fuel_quantity': fuelQuantity,
      'price': price,
      'odometer': odometer,
      'odometer_image_path': odometerImagePath,
      'sync_status': syncStatus,
      'sync_error': syncError,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  // For API sync
  Map<String, dynamic> toSyncJson() {
    return {
      'fillNumber': fillNumber,
      'creationDate': creationDate.toIso8601String(),
      'creationUser': creationUser,
      'fuelStation': fuelStation,
      'assetNumber': assetNumber,
      'assetDescription': assetDescription,
      'fuelType': fuelType,
      'fuelDescription': fuelDescription,
      'projectNumber': projectNumber,
      'projectName': projectName,
      'fuelQuantity': fuelQuantity,
      'price': price,
      'odometer': odometer,
    };
  }

  bool get isPending => syncStatus == 'PENDING';
  bool get isSynced => syncStatus == 'SYNCED';
  bool get isFailed => syncStatus == 'FAILED';

  // Get localized fuel type
  String getLocalizedFuelType(bool isArabic) {
    final types = {
      'PETROL80': isArabic ? 'بنزين 80' : 'Petrol 80',
      'PETROL92': isArabic ? 'بنزين 92' : 'Petrol 92',
      'PETROL95': isArabic ? 'بنزين 95' : 'Petrol 95',
      'DIESEL': isArabic ? 'سولار' : 'Diesel',
    };
    return types[fuelType.toUpperCase()] ?? fuelType;
  }

  // Compatibility aliases for old field names (used in history_screen)
  double get quantity => fuelQuantity;
  double get totalAmount => (price ?? 0) * fuelQuantity;
  DateTime get transactionDate => creationDate;
  String? get notes => fuelDescription;

  // Copy with modified fields
  FuelTransaction copyWith({
    int? id,
    String? fillNumber,
    DateTime? creationDate,
    String? creationUser,
    String? fuelStation,
    String? assetNumber,
    String? assetDescription,
    String? fuelType,
    String? fuelDescription,
    String? projectNumber,
    String? projectName,
    double? fuelQuantity,
    double? price,
    int? odometer,
    String? odometerImagePath,
    String? syncStatus,
    String? syncError,
    DateTime? syncedAt,
  }) {
    return FuelTransaction(
      id: id ?? this.id,
      fillNumber: fillNumber ?? this.fillNumber,
      creationDate: creationDate ?? this.creationDate,
      creationUser: creationUser ?? this.creationUser,
      fuelStation: fuelStation ?? this.fuelStation,
      assetNumber: assetNumber ?? this.assetNumber,
      assetDescription: assetDescription ?? this.assetDescription,
      fuelType: fuelType ?? this.fuelType,
      fuelDescription: fuelDescription ?? this.fuelDescription,
      projectNumber: projectNumber ?? this.projectNumber,
      projectName: projectName ?? this.projectName,
      fuelQuantity: fuelQuantity ?? this.fuelQuantity,
      price: price ?? this.price,
      odometer: odometer ?? this.odometer,
      odometerImagePath: odometerImagePath ?? this.odometerImagePath,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

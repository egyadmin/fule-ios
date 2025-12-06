import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Check if current locale is Arabic
  bool get isArabic => locale.languageCode == 'ar';
  
  // Check if current locale is RTL
  TextDirection get textDirection => 
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Fuel Management',
      'app_subtitle': 'Smart Fuel Tracking System',
      
      // Auth
      'login': 'Login',
      'logout': 'Logout',
      'username': 'Username',
      'password': 'Password',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'login_success': 'Login successful',
      'login_failed': 'Login failed',
      'invalid_credentials': 'Invalid username or password',
      'please_enter_username': 'Please enter username',
      'please_enter_password': 'Please enter password',
      
      // Home
      'home': 'Home',
      'welcome': 'Welcome',
      'today_transactions': 'Today\'s Transactions',
      'total_fuel': 'Total Fuel',
      'liters': 'Liters',
      'pending_sync': 'Pending Sync',
      'scan_qr': 'Scan QR Code',
      'manual_entry': 'Manual Entry',
      'history': 'History',
      'settings': 'Settings',
      
      // Scanner
      'scanner': 'QR Scanner',
      'scan_equipment_qr': 'Scan Equipment QR Code',
      'flash': 'Flash',
      'enter_code_manually': 'Enter Code Manually',
      'equipment_code': 'Equipment Code',
      'search': 'Search',
      'no_equipment_found': 'No equipment found',
      
      // Equipment
      'equipment': 'Equipment',
      'equipment_info': 'Equipment Information',
      'equipment_type': 'Type',
      'plate_number': 'Plate Number',
      'driver_name': 'Driver Name',
      'department': 'Department',
      'status': 'Status',
      'active': 'Active',
      'inactive': 'Inactive',
      
      // Transaction
      'new_transaction': 'New Transaction',
      'transaction_details': 'Transaction Details',
      'fuel_type': 'Fuel Type',
      'petrol_80': 'Petrol 80',
      'petrol_92': 'Petrol 92',
      'petrol_95': 'Petrol 95',
      'diesel': 'Diesel',
      'quantity': 'Quantity',
      'quantity_liters': 'Quantity (Liters)',
      'unit_price': 'Unit Price',
      'total_amount': 'Total Amount',
      'odometer': 'Odometer Reading',
      'odometer_km': 'Odometer (km)',
      'notes': 'Notes',
      'optional': 'Optional',
      'submit': 'Submit',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'transaction_saved': 'Transaction saved successfully',
      'transaction_failed': 'Failed to save transaction',
      'please_select_fuel_type': 'Please select fuel type',
      'please_enter_quantity': 'Please enter quantity',
      'invalid_quantity': 'Invalid quantity',
      
      // History
      'transaction_history': 'Transaction History',
      'all': 'All',
      'today': 'Today',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'filter_by_date': 'Filter by Date',
      'filter_by_fuel': 'Filter by Fuel Type',
      'no_transactions': 'No transactions found',
      'synced': 'Synced',
      'pending': 'Pending',
      'failed': 'Failed',
      
      // Sync
      'sync': 'Sync',
      'sync_now': 'Sync Now',
      'last_sync': 'Last Sync',
      'syncing': 'Syncing...',
      'sync_complete': 'Sync completed',
      'sync_failed': 'Sync failed',
      'offline_mode': 'Offline Mode',
      'online_mode': 'Online Mode',
      'no_internet': 'No internet connection',
      
      // Settings
      'language': 'Language',
      'arabic': 'العربية',
      'english': 'English',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'auto_sync': 'Auto Sync',
      'clear_cache': 'Clear Cache',
      'about': 'About',
      'version': 'Version',
      'contact_support': 'Contact Support',
      
      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'retry': 'Retry',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'date': 'Date',
      'time': 'Time',
      'egp': 'EGP',
      'currency': 'EGP',
    },
    'ar': {
      // App
      'app_name': 'إدارة الوقود',
      'app_subtitle': 'نظام ذكي لتتبع الوقود',
      
      // Auth
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'remember_me': 'تذكرني',
      'forgot_password': 'نسيت كلمة المرور؟',
      'login_success': 'تم تسجيل الدخول بنجاح',
      'login_failed': 'فشل تسجيل الدخول',
      'invalid_credentials': 'اسم المستخدم أو كلمة المرور غير صحيحة',
      'please_enter_username': 'برجاء إدخال اسم المستخدم',
      'please_enter_password': 'برجاء إدخال كلمة المرور',
      
      // Home
      'home': 'الرئيسية',
      'welcome': 'مرحباً',
      'today_transactions': 'معاملات اليوم',
      'total_fuel': 'إجمالي الوقود',
      'liters': 'لتر',
      'pending_sync': 'في انتظار المزامنة',
      'scan_qr': 'مسح رمز QR',
      'manual_entry': 'إدخال يدوي',
      'history': 'السجل',
      'settings': 'الإعدادات',
      
      // Scanner
      'scanner': 'ماسح QR',
      'scan_equipment_qr': 'امسح رمز QR للمعدة',
      'flash': 'الفلاش',
      'enter_code_manually': 'إدخال الكود يدوياً',
      'equipment_code': 'كود المعدة',
      'search': 'بحث',
      'no_equipment_found': 'لم يتم العثور على معدة',
      
      // Equipment
      'equipment': 'المعدات',
      'equipment_info': 'معلومات المعدة',
      'equipment_type': 'النوع',
      'plate_number': 'رقم اللوحة',
      'driver_name': 'اسم السائق',
      'department': 'القسم',
      'status': 'الحالة',
      'active': 'نشط',
      'inactive': 'غير نشط',
      
      // Transaction
      'new_transaction': 'معاملة جديدة',
      'transaction_details': 'تفاصيل المعاملة',
      'fuel_type': 'نوع الوقود',
      'petrol_80': 'بنزين 80',
      'petrol_92': 'بنزين 92',
      'petrol_95': 'بنزين 95',
      'diesel': 'سولار',
      'quantity': 'الكمية',
      'quantity_liters': 'الكمية (لتر)',
      'unit_price': 'سعر الوحدة',
      'total_amount': 'المبلغ الإجمالي',
      'odometer': 'عداد المسافة',
      'odometer_km': 'عداد المسافة (كم)',
      'notes': 'ملاحظات',
      'optional': 'اختياري',
      'submit': 'إرسال',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'transaction_saved': 'تم حفظ المعاملة بنجاح',
      'transaction_failed': 'فشل حفظ المعاملة',
      'please_select_fuel_type': 'برجاء اختيار نوع الوقود',
      'please_enter_quantity': 'برجاء إدخال الكمية',
      'invalid_quantity': 'الكمية غير صالحة',
      
      // History
      'transaction_history': 'سجل المعاملات',
      'all': 'الكل',
      'today': 'اليوم',
      'this_week': 'هذا الأسبوع',
      'this_month': 'هذا الشهر',
      'filter_by_date': 'تصفية حسب التاريخ',
      'filter_by_fuel': 'تصفية حسب نوع الوقود',
      'no_transactions': 'لا توجد معاملات',
      'synced': 'تمت المزامنة',
      'pending': 'قيد الانتظار',
      'failed': 'فشل',
      
      // Sync
      'sync': 'مزامنة',
      'sync_now': 'مزامنة الآن',
      'last_sync': 'آخر مزامنة',
      'syncing': 'جاري المزامنة...',
      'sync_complete': 'تمت المزامنة',
      'sync_failed': 'فشلت المزامنة',
      'offline_mode': 'وضع عدم الاتصال',
      'online_mode': 'متصل',
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      
      // Settings
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'dark_mode': 'الوضع الداكن',
      'notifications': 'الإشعارات',
      'auto_sync': 'مزامنة تلقائية',
      'clear_cache': 'مسح ذاكرة التخزين',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'contact_support': 'تواصل مع الدعم',
      
      // Common
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'warning': 'تحذير',
      'retry': 'إعادة المحاولة',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'close': 'إغلاق',
      'back': 'رجوع',
      'next': 'التالي',
      'done': 'تم',
      'delete': 'حذف',
      'edit': 'تعديل',
      'view': 'عرض',
      'date': 'التاريخ',
      'time': 'الوقت',
      'egp': 'ج.م',
      'currency': 'ج.م',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get appSubtitle => translate('app_subtitle');
  String get login => translate('login');
  String get logout => translate('logout');
  String get username => translate('username');
  String get password => translate('password');
  String get rememberMe => translate('remember_me');
  String get home => translate('home');
  String get welcome => translate('welcome');
  String get scanQr => translate('scan_qr');
  String get manualEntry => translate('manual_entry');
  String get history => translate('history');
  String get settings => translate('settings');
  String get language => translate('language');
  String get syncNow => translate('sync_now');
  String get loading => translate('loading');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get submit => translate('submit');
  String get ok => translate('ok');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

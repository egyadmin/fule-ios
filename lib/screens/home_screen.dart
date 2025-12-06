import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sync_provider.dart';
import '../l10n/app_localizations.dart';
import 'fuel_entry_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية - Main Home Screen with Bottom Navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FuelEntryTab(),
    const HistoryScreen(),
    const SyncTab(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.local_gas_station_rounded, loc.translate('fuel_entry'), loc),
                  _buildNavItem(1, Icons.history_rounded, loc.translate('history'), loc),
                  _buildNavItem(2, Icons.sync_rounded, loc.translate('sync'), loc),
                  _buildNavItem(3, Icons.settings_rounded, loc.translate('settings'), loc),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, AppLocalizations loc) {
    final isSelected = _currentIndex == index;
    final syncProvider = Provider.of<SyncProvider>(context);
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 24,
                ),
                // Show badge for sync if pending
                if (index == 2 && syncProvider.pendingCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${syncProvider.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// تبويب تعبئة الوقود - Fuel Entry Tab
class FuelEntryTab extends StatelessWidget {
  const FuelEntryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const FuelEntryScreen();
  }
}

/// تبويب المزامنة - Sync Tab
class SyncTab extends StatelessWidget {
  const SyncTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final syncProvider = Provider.of<SyncProvider>(context);
    
    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: Text(loc.translate('sync')),
          centerTitle: true,
          actions: [
            // Language Toggle
            Consumer<LanguageProvider>(
              builder: (context, langProvider, _) => TextButton(
                onPressed: () => langProvider.toggleLanguage(),
                child: Text(
                  langProvider.isArabic ? 'EN' : 'ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Sync Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        syncProvider.isSyncing ? Icons.sync : Icons.cloud_done,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      syncProvider.isSyncing 
                          ? (loc.isArabic ? 'جار المزامنة...' : 'Syncing...')
                          : (loc.isArabic ? 'متصل' : 'Connected'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions,
                      label: loc.isArabic ? 'معاملات معلقة' : 'Pending',
                      value: '${syncProvider.pendingCount}',
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time,
                      label: loc.isArabic ? 'آخر مزامنة' : 'Last Sync',
                      value: syncProvider.lastSyncTime ?? (loc.isArabic ? 'لم تتم' : 'Never'),
                      color: AppTheme.infoColor,
                      isSmallValue: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Connection Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (syncProvider.isOnline ? AppTheme.successColor : AppTheme.errorColor).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        syncProvider.isOnline ? Icons.wifi : Icons.wifi_off,
                        color: syncProvider.isOnline ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.isArabic ? 'حالة الاتصال' : 'Connection Status',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            syncProvider.isOnline 
                                ? (loc.isArabic ? 'متصل بالإنترنت' : 'Online')
                                : (loc.isArabic ? 'غير متصل' : 'Offline'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Sync Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: syncProvider.isSyncing ? null : () => syncProvider.syncNow(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: syncProvider.isSyncing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    syncProvider.isSyncing 
                        ? (loc.isArabic ? 'جار المزامنة...' : 'Syncing...')
                        : (loc.isArabic ? 'مزامنة الآن' : 'Sync Now'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmallValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallValue ? 14 : 24,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

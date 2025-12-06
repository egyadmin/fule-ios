import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sync_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final syncProvider = Provider.of<SyncProvider>(context);

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.translate('settings'),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      authProvider.operator?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.operator?.fullName ?? '',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          authProvider.operator?.role ?? '',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Language Section
            _buildSectionTitle(loc.translate('language')),
            _buildSettingCard(
              child: ListTile(
                leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                title: Text(
                  loc.translate('language'),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                subtitle: Text(
                  languageProvider.currentLanguageName,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageOption(
                        'العربية',
                        languageProvider.isArabic,
                        () => languageProvider.setLanguage('ar'),
                      ),
                      _buildLanguageOption(
                        'English',
                        languageProvider.isEnglish,
                        () => languageProvider.setLanguage('en'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sync Section
            _buildSectionTitle(loc.translate('sync')),
            _buildSettingCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: syncProvider.isOnline ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                    title: Text(
                      loc.translate('status'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    subtitle: Text(
                      syncProvider.isOnline
                          ? loc.translate('online_mode')
                          : loc.translate('offline_mode'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.pending_actions, color: AppTheme.warningColor),
                    title: Text(
                      loc.translate('pending_sync'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: syncProvider.pendingCount > 0
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${syncProvider.pendingCount}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.sync,
                      color: syncProvider.isSyncing ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                    title: Text(
                      loc.translate('sync_now'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    trailing: syncProvider.isSyncing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: syncProvider.isSyncing ? null : () => syncProvider.syncAll(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            _buildSectionTitle(loc.translate('about')),
            _buildSettingCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                    title: Text(
                      loc.translate('version'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: AppTheme.primaryColor),
                    title: Text(
                      loc.translate('contact_support'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement support contact
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      loc.translate('logout'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    content: Text(
                      loc.isArabic
                          ? 'هل أنت متأكد من تسجيل الخروج؟'
                          : 'Are you sure you want to logout?',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          loc.cancel,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: Text(
                          loc.translate('logout'),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && context.mounted) {
                  await authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(
                loc.translate('logout'),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildLanguageOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class LanguageToggleButton extends StatelessWidget {
  final bool iconOnly;
  
  const LanguageToggleButton({
    super.key,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    if (iconOnly) {
      return IconButton(
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            languageProvider.isArabic ? 'EN' : 'ع',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        onPressed: () => languageProvider.toggleLanguage(),
        tooltip: languageProvider.oppositeLanguageName,
      );
    }
    
    return GestureDetector(
      onTap: () => languageProvider.toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.language,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              languageProvider.oppositeLanguageName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Language toggle button for use on light backgrounds (not in AppBar)
class LanguageToggleButtonLight extends StatelessWidget {
  const LanguageToggleButtonLight({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return GestureDetector(
      onTap: () => languageProvider.toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              languageProvider.isArabic ? 'English' : 'العربية',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz,
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

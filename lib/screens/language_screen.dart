import 'package:flutter/material.dart';
import '../controllers/language_controller.dart';
import '../l10n/app_localizations.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B132B)],
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 80,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.local_gas_station_rounded,
                size: 320,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        l10n.language,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDFBF7), Color(0xFFF4EFE6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: LanguageController.instance,
                          builder: (context, child) {
                            return DropdownButtonFormField<String>(
                              initialValue: LanguageController.instance.locale.languageCode,
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: l10n.chooseLanguage,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF8A6D1C)),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'ar',
                                  child: Text('العربية (${l10n.arabic})'),
                                ),
                                DropdownMenuItem(
                                  value: 'ku',
                                  child: Text('کوردی (${l10n.kurdish})'),
                                ),
                                DropdownMenuItem(
                                  value: 'fa',
                                  child: Text('فارسی (${l10n.persian})'),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English (${l10n.english})'),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == null) return;
                                await LanguageController.instance.changeLanguage(value);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

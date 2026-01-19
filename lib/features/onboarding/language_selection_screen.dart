import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _languages = [
    {'name': 'Amharic', 'code': 'amharic', 'icon': '🇪🇹'},
    {'name': 'Afaan Oromo', 'code': 'afaan oromo', 'icon': '🌍'},
    {'name': 'Tigregna', 'code': 'tigregna', 'icon': '⭐'},
  ];

  final Set<String> _selectedCodes = {};
  String? _primaryCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'What would you like to learn?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pick one or more languages to start your journey. You can change your primary language anytime.',
                style: TextStyle(color: AppTheme.duoGray, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedCodes.contains(lang['code']);
                    final isPrimary = _primaryCode == lang['code'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCodes.remove(lang['code']);
                              if (isPrimary) _primaryCode = null;
                            } else {
                              _selectedCodes.add(lang['code']!);
                              _primaryCode ??= lang['code'];
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: isSelected ? AppTheme.duoBlue.withValues(alpha: 0.05) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(lang['icon']!, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang['name']!,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppTheme.duoBlue : Colors.black,
                                      ),
                                    ),
                                    if (isPrimary)
                                      const Text(
                                        'Primary Language',
                                        style: TextStyle(color: AppTheme.duoBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppTheme.duoBlue, size: 28),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Help text if multiple selected
              if (_selectedCodes.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      'Tapping a selected language sets it as primary.',
                      style: TextStyle(color: AppTheme.duoGray.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCodes.isEmpty || _primaryCode == null
                      ? null
                      : () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.setSelectedLanguages(
                            _selectedCodes.toList(),
                            _primaryCode!,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('LET\'S GO!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

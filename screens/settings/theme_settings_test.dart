import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/AppThemeMode.dart';

class ThemeSettingsTest extends ConsumerWidget {
  const ThemeSettingsTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors['background'],
      appBar: AppBar(
        title: const Text(
          'اختبار الثيم',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: customColors['primary'],
        foregroundColor: customColors['textPrimary'],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الثيم الحالي: ${themeState.themeMode.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: customColors['textPrimary'],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            
            // اختبار الألوان
            _buildColorTest('اللون الأساسي', customColors['primary']!),
            _buildColorTest('اللون الثانوي', customColors['accent']!),
            _buildColorTest('لون الخلفية', customColors['background']!),
            _buildColorTest('لون السطح', customColors['surface']!),
            _buildColorTest('النص الأساسي', customColors['textPrimary']!),
            _buildColorTest('النص الثانوي', customColors['textSecondary']!),
            
            const SizedBox(height: 20),
            
            // اختبار الأزرار
            Text(
              'اختبار الأزرار',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customColors['textPrimary'],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors['primary'],
                      foregroundColor: customColors['textPrimary'],
                    ),
                    child: const Text(
                      'زر أساسي',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: customColors['primary'],
                      side: BorderSide(color: customColors['primary']!),
                    ),
                    child: const Text(
                      'زر محدد',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // اختبار البطاقات
            Text(
              'اختبار البطاقات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customColors['textPrimary'],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 10),
            
            Card(
              color: customColors['surface'],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عنوان البطاقة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: customColors['textPrimary'],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هذا نص تجريبي لاختبار الألوان في البطاقة',
                      style: TextStyle(
                        color: customColors['textSecondary'],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // أزرار تغيير الثيم السريع
            Text(
              'تغيير الثيم السريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customColors['textPrimary'],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppThemeMode.values.map((mode) {
                final isSelected = themeState.themeMode == mode;
                return FilterChip(
                  label: Text(
                    mode.name,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(themeProvider.notifier).setThemeMode(mode);
                    }
                  },
                  selectedColor: customColors['primary']!.withOpacity(0.3),
                  checkmarkColor: customColors['primary'],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTest(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

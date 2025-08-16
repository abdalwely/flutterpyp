import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../models/wifi_card_model.dart';
import '../../services/wifi_cards_service.dart';
import '../../providers/auth_provider.dart';

class CardsManagementScreen extends ConsumerStatefulWidget {
  static const String routeName = '/admin/cards';

  const CardsManagementScreen({super.key});

  @override
  ConsumerState<CardsManagementScreen> createState() => _CardsManagementScreenState();
}

class _CardsManagementScreenState extends ConsumerState<CardsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final WiFiCardsService _cardsService = WiFiCardsService();
  
  // Add Cards Form
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _serialController = TextEditingController();
  String? _selectedProvider;
  int? _selectedValue;
  
  // Upload Status
  bool _isUploading = false;
  List<Map<String, dynamic>> _uploadedCards = [];
  String? _uploadStatus;
  
  // Statistics
  Map<String, dynamic>? _statistics;
  bool _loadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _loadStatistics() async {
    setState(() => _loadingStats = true);
    try {
      final stats = await _cardsService.getCardsStatistics();
      if (mounted) {
        setState(() => _statistics = stats);
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في جلب الإحصائيات: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  void _addSingleCard() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(authControllerProvider).value;
    if (currentUser == null) return;

    setState(() => _isUploading = true);

    try {
      final card = WiFiCardModel(
        id: '',
        provider: _selectedProvider!,
        value: _selectedValue!,
        code: _codeController.text.trim(),
        serial: _serialController.text.trim().isEmpty 
            ? null 
            : _serialController.text.trim(),
        createdAt: DateTime.now(),
        uploadedBy: currentUser.uid,
      );

      await _cardsService.addWiFiCards([card]);
      
      if (mounted) {
        _showSuccessSnackBar('تم إضافة الكرت بنجاح');
        _formKey.currentState!.reset();
        _codeController.clear();
        _serialController.clear();
        setState(() {
          _selectedProvider = null;
          _selectedValue = null;
        });
        _loadStatistics();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في إضافة الكرت: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _uploadCSVFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isUploading = true);
        
        final bytes = result.files.single.bytes!;
        final csvData = utf8.decode(bytes);
        final rows = const CsvToListConverter().convert(csvData);
        
        if (rows.isEmpty) {
          throw Exception('الملف فارغ');
        }
        
        // تحقق من رأس الجدول
        final headers = rows[0].map((e) => e.toString().toLowerCase()).toList();
        final requiredColumns = ['provider', 'value', 'code'];
        
        for (final column in requiredColumns) {
          if (!headers.contains(column)) {
            throw Exception('الملف يجب أن يحتوي على العمود: $column');
          }
        }
        
        final providerIndex = headers.indexOf('provider');
        final valueIndex = headers.indexOf('value');
        final codeIndex = headers.indexOf('code');
        final serialIndex = headers.contains('serial') 
            ? headers.indexOf('serial') 
            : -1;
        
        final cards = <WiFiCardModel>[];
        final errors = <String>[];
        final currentUser = ref.read(authControllerProvider).value;
        
        for (int i = 1; i < rows.length; i++) {
          try {
            final row = rows[i];
            
            if (row.length <= math.max(providerIndex, math.max(valueIndex, codeIndex))) {
              errors.add('السطر ${i + 1}: بيانات ناقصة');
              continue;
            }
            
            final provider = row[providerIndex].toString().trim();
            final valueStr = row[valueIndex].toString().trim();
            final code = row[codeIndex].toString().trim();
            final serial = serialIndex >= 0 && row.length > serialIndex
                ? row[serialIndex].toString().trim()
                : null;
            
            // التحقق من صحة البيانات
            if (!AppConfig.supportedNetworks.any((n) => n['id'] == provider)) {
              errors.add('السطر ${i + 1}: مزود غير مدعوم: $provider');
              continue;
            }
            
            final value = int.tryParse(valueStr);
            if (value == null) {
              errors.add('السطر ${i + 1}: قيمة غير صحيحة: $valueStr');
              continue;
            }
            
            if (code.isEmpty) {
              errors.add('السطر ${i + 1}: كود الكرت فارغ');
              continue;
            }
            
            final card = WiFiCardModel(
              id: '',
              provider: provider,
              value: value,
              code: code,
              serial: serial?.isEmpty == true ? null : serial,
              createdAt: DateTime.now(),
              uploadedBy: currentUser?.uid ?? 'unknown',
              batchId: DateTime.now().millisecondsSinceEpoch.toString(),
            );
            
            cards.add(card);
          } catch (e) {
            errors.add('السطر ${i + 1}: خطأ في المعالجة: ${e.toString()}');
          }
        }
        
        if (cards.isNotEmpty) {
          await _cardsService.addWiFiCards(cards);
          
          setState(() {
            _uploadedCards = cards.map((card) => {
              'provider': card.getProviderNameAr(),
              'value': card.value,
              'code': card.code,
              'serial': card.serial,
            }).toList();
            _uploadStatus = 'تم رفع ${cards.length} كرت بنجاح';
          });
          
          _loadStatistics();
        }
        
        if (errors.isNotEmpty) {
          _showErrorDialog('أخطاء في الرفع', errors);
        } else if (cards.isNotEmpty) {
          _showSuccessSnackBar('تم رفع ${cards.length} كرت بنجاح');
        }
        
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في رفع الملف: ${e.toString()}');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String title, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: errors.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                errors[index],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('غير مصرح'),
        ),
        body: const Center(
          child: Text(
            'ليس لديك صلاحية للوصول إلى هذه الصفحة',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الكروت'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الإحصائيات'),
            Tab(text: 'إضافة كرت'),
            Tab(text: 'رفع ملف'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildAddCardTab(),
          _buildUploadTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_statistics == null) {
      return const Center(
        child: Text(
          'لا توجد إحصائيات متاحة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الكروت',
                  _statistics!['total'].toString(),
                  Icons.credit_card,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المتاح',
                  _statistics!['available'].toString(),
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المباع',
                  _statistics!['sold'].toString(),
                  Icons.shopping_cart,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المحجوز',
                  _statistics!['reserved'].toString(),
                  Icons.hourglass_empty,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // By Provider
          const Text(
            'حسب المزود',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._buildProviderStats(),
          
          const SizedBox(height: 32),
          
          // By Value
          const Text(
            'حسب القيمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._buildValueStats(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProviderStats() {
    final byProvider = _statistics!['byProvider'] as Map<String, dynamic>;
    return byProvider.entries.map((entry) {
      final provider = AppConfig.supportedNetworks
          .firstWhere((n) => n['id'] == entry.key, orElse: () => {'name': entry.key});
      final stats = entry.value as Map<String, dynamic>;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                provider['name'] ?? entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Text(
              'المجموع: ${stats['total']}',
              style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
            ),
            const SizedBox(width: 8),
            Text(
              'المتاح: ${stats['available']}',
              style: const TextStyle(
                fontSize: 12, 
                color: AppTheme.successColor,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildValueStats() {
    final byValue = _statistics!['byValue'] as Map<String, dynamic>;
    final sortedEntries = byValue.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    
    return sortedEntries.map((entry) {
      final stats = entry.value as Map<String, dynamic>;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${entry.key} ريال',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Text(
              'المجموع: ${stats['total']}',
              style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
            ),
            const SizedBox(width: 8),
            Text(
              'المتا��: ${stats['available']}',
              style: const TextStyle(
                fontSize: 12, 
                color: AppTheme.successColor,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAddCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة كرت جديد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Provider Selection
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: const InputDecoration(
                labelText: 'المزود',
                prefixIcon: Icon(Icons.sim_card),
              ),
              items: AppConfig.supportedNetworks.map((provider) {
                return DropdownMenuItem<String>(
                  value: provider['id'],
                  child: Text(
                    provider['name'],
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value;
                  _selectedValue = null; // Reset value when provider changes
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار المزود';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Value Selection
            if (_selectedProvider != null)
              DropdownButtonFormField<int>(
                value: _selectedValue,
                decoration: const InputDecoration(
                  labelText: 'القيمة',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                items: AppConfig.getSupportedAmounts(_selectedProvider!).map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '$value ريال',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedValue = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار القيمة';
                  }
                  return null;
                },
              ),
            
            const SizedBox(height: 16),
            
            // Code Input
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'كود الكرت',
                hintText: 'أدخل كود الكرت',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كود الكرت';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Serial Input (Optional)
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'الرقم المسلسل (اختي��ري)',
                hintText: 'أدخل الرقم المسلسل',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _addSingleCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'إضافة الكرت',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رفع ملف CSV',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoColor),
                    const SizedBox(width: 8),
                    const Text(
                      'تعليمات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• الملف يجب أن يكون بصيغة CSV\n'
                  '• الأعمدة المطلوبة: provider, value, code\n'
                  '• العمود الاختياري: serial\n'
                  '• المزودات المدعومة: yemenmobile, mtn, sabafon, why',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadCSVFile,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(
                _isUploading ? 'جارٍ الرفع...' : 'اختي��ر ملف CSV',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Upload Status
          if (_uploadStatus != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor),
                      const SizedBox(width: 8),
                      const Text(
                        'نتيجة الرفع',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _uploadStatus!,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ],
          
          // Uploaded Cards Preview
          if (_uploadedCards.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'الكروت المرفوعة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _uploadedCards.length,
                itemBuilder: (context, index) {
                  final card = _uploadedCards[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      '${card['provider']} - ${card['value']} ريال',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    subtitle: Text(
                      'الكود: ${card['code']}${card['serial'] != null ? ' | المسلسل: ${card['serial']}' : ''}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

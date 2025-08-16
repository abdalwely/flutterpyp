import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/school_model.dart';
import '../../providers/firestore_provider.dart';

class SchoolsManagementScreen extends ConsumerStatefulWidget {
  static const String routeName = '/admin/schools';
  
  const SchoolsManagementScreen({super.key});

  @override
  ConsumerState<SchoolsManagementScreen> createState() => _SchoolsManagementScreenState();
}

class _SchoolsManagementScreenState extends ConsumerState<SchoolsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المدارس',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.successColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'إضافة مدرسة'),
            Tab(text: 'المدارس'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AddSchoolTab(),
          _SchoolsListTab(),
        ],
      ),
    );
  }
}

class _AddSchoolTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddSchoolTab> createState() => _AddSchoolTabState();
}

class _AddSchoolTabState extends ConsumerState<_AddSchoolTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleAddSchool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final school = SchoolModel(
        id: '',
        name: _nameController.text.trim(),
        nameEn: _nameController.text.trim(), // إضافة الاسم الإنجليزي (نفس الاسم العربي مؤقتاً)
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        createdAt: DateTime.now(),
      );

      final service = ref.read(firestoreServiceProvider);
      await service.addSchool(school);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المدرسة بنجاح'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Clear form
        _nameController.clear();
        _codeController.clear();
        _addressController.clear();
        _phoneController.clear();
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School Name
            const Text(
              'اسم المدرسة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'أدخل اسم المدرسة',
                prefixIcon: const Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المدرسة';
                }
                if (value.trim().length < 3) {
                  return 'اسم المدرسة يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // School Code
            const Text(
              'رمز المدرسة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'أدخل رمز المدرسة',
                prefixIcon: const Icon(Icons.code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رمز المدرسة';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address
            const Text(
              'العنوان',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'أدخل عنوان المدرسة',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان المدرسة';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone
            const Text(
              'رقم الهاتف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'أدخل رقم الهاتف',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            const Text(
              'البريد الإلكتروني',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'أدخل البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleAddSchool,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'إضافة المدرسة',
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
}

class _SchoolsListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolsProvider);

    return schoolsAsync.when(
      data: (schools) {
        if (schools.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: AppConstants.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد مدارس',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'قم بإضافة مدرسة من التبو��ب الأول',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(schoolsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return _buildSchoolCard(context, ref, school);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'خطأ في تحميل المدارس',
              style: TextStyle(
                fontSize: 18,
                color: AppConstants.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(schoolsProvider),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolCard(BuildContext context, WidgetRef ref, SchoolModel school) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'معرف: ${school.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: school.isActive
                        ? AppConstants.successColor.withOpacity(0.1)
                        : AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    school.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: school.isActive
                          ? AppConstants.successColor
                          : AppConstants.errorColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details
            _buildDetailRow(Icons.location_on, 'العنوان', school.address),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.phone, 'الهاتف', school.phone),
            const SizedBox(height: 8),

            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editSchool(context, ref, school),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text(
                      'تعديل',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleSchoolStatus(context, ref, school),
                    icon: Icon(
                      school.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(
                      school.isActive ? 'إخفاء' : 'إظهار',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: school.isActive
                          ? AppConstants.errorColor
                          : AppConstants.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  void _editSchool(BuildContext context, WidgetRef ref, SchoolModel school) {
    // Implementation for editing school
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة التعديل قيد التطوير'),
        backgroundColor: AppConstants.warningColor,
      ),
    );
  }

  void _toggleSchoolStatus(BuildContext context, WidgetRef ref, SchoolModel school) async {
    try {
      final service = ref.read(firestoreServiceProvider);
      final updatedSchool = school.copyWith(isActive: !school.isActive);
      await service.updateSchool(updatedSchool);

      ref.invalidate(schoolsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            school.isActive ? 'تم إخفاء المدرسة' : 'تم إظهار المدرسة',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
}

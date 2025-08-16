// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/constants/app_constants.dart';
// import '../../providers/auth_provider.dart';
// import '../auth/login_screen.dart';
//
// class ProfileScreen extends ConsumerWidget {
//   static const String routeName = '/profile';
//
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentUserAsync = ref.watch(currentUserAsyncProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'الملف الشخصي',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: AppConstants.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: currentUserAsync.when(
//         data: (user) {
//           if (user == null) {
//             return const Center(
//               child: Text(
//                 'خطأ في تحميل بيانات المستخدم',
//                 style: TextStyle(fontFamily: 'Cairo'),
//               ),
//             );
//           }
//
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Profile Header
//                 Container(
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         AppConstants.primaryColor,
//                         AppConstants.secondaryColor,
//                       ],
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//
//                       // Profile Picture
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundColor: Colors.white,
//                         child: user.photoUrl != null
//                             ? ClipOval(
//                                 child: Image.network(
//                                   user.photoUrl!,
//                                   width: 120,
//                                   height: 120,
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                             : const Icon(
//                                 Icons.person,
//                                 size: 60,
//                                 color: AppConstants.primaryColor,
//                               ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // User Name
//                       Text(
//                         user.name,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       // User Email
//                       Text(
//                         user.email,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//
//                 // Profile Options
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       // Personal Information Section
//                       _buildSectionHeader('المعلومات الشخصية'),
//
//                       _buildInfoCard(
//                         icon: Icons.person_outline,
//                         title: 'الاسم',
//                         value: user.name,
//                       ),
//
//                       _buildInfoCard(
//                         icon: Icons.email_outlined,
//                         title: 'البريد الإلكتروني',
//                         value: user.email,
//                       ),
//
//                       _buildInfoCard(
//                         icon: Icons.phone_outlined,
//                         title: 'رقم الهاتف',
//                         value: user.phone,
//                       ),
//
//                       if (user.balance > 0)
//                         _buildInfoCard(
//                           icon: Icons.account_balance_wallet_outlined,
//                           title: 'الرصيد',
//                           value: '${user.balance.toStringAsFixed(2)} ريال',
//                         ),
//
//                       const SizedBox(height: 20),
//
//                       // Account Actions Section
//                       _buildSectionHeader('إعدادات الحساب'),
//
//                       _buildActionCard(
//                         icon: Icons.edit_outlined,
//                         title: 'تعديل الم��لومات',
//                         subtitle: 'تحديث الاسم والصورة الشخصية',
//                         onTap: () {
//                           // Navigate to edit profile
//                         },
//                       ),
//
//                       _buildActionCard(
//                         icon: Icons.lock_outline,
//                         title: 'تغيير كلمة المرور',
//                         subtitle: 'تحديث كلمة المرور',
//                         onTap: () {
//                           // Navigate to change password
//                         },
//                       ),
//
//                       _buildActionCard(
//                         icon: Icons.notifications_outlined,
//                         title: 'الإشعارات',
//                         subtitle: 'إدارة إعدادات الإشعارات',
//                         onTap: () {
//                           // Navigate to notifications settings
//                         },
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // App Information Section
//                       _buildSectionHeader('معلومات التطبيق'),
//
//                       _buildActionCard(
//                         icon: Icons.info_outline,
//                         title: 'حول التطبيق',
//                         subtitle: 'معلومات التطبيق والإصدار',
//                         onTap: () {
//                           _showAboutDialog(context);
//                         },
//                       ),
//
//                       _buildActionCard(
//                         icon: Icons.help_outline,
//                         title: 'المساعدة والدعم',
//                         subtitle: 'الأسئلة الشائعة ومعلومات التواصل',
//                         onTap: () {
//                           // Navigate to help
//                         },
//                       ),
//
//                       _buildActionCard(
//                         icon: Icons.privacy_tip_outlined,
//                         title: 'سياسة الخصوصية',
//                         subtitle: 'شروط الاستخدام وسياسة الخصوصية',
//                         onTap: () {
//                           // Navigate to privacy policy
//                         },
//                       ),
//
//                       const SizedBox(height: 30),
//
//                       // Logout Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () => _handleLogout(context, ref),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppConstants.errorColor,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           icon: const Icon(Icons.logout),
//                           label: const Text(
//                             'تسجيل الخروج',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Cairo',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, _) => Center(
//           child: Text(
//             'خطأ: $error',
//             style: const TextStyle(fontFamily: 'Cairo'),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: AppConstants.textPrimary,
//           fontFamily: 'Cairo',
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppConstants.primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: AppConstants.primaryColor,
//               size: 20,
//             ),
//           ),
//
//           const SizedBox(width: 16),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: AppConstants.textSecondary,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppConstants.textPrimary,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey[300]!),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppConstants.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppConstants.primaryColor,
//                 size: 20,
//               ),
//             ),
//
//             const SizedBox(width: 16),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: AppConstants.textPrimary,
//                       fontFamily: 'Cairo',
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: AppConstants.textSecondary,
//                       fontFamily: 'Cairo',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const Icon(
//               Icons.arrow_forward_ios,
//               color: AppConstants.textSecondary,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _handleLogout(BuildContext context, WidgetRef ref) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'تسجيل الخروج',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         content: const Text(
//           'هل أنت م��أكد من تسجيل الخروج؟',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text(
//               'إلغاء',
//               style: TextStyle(fontFamily: 'Cairo'),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppConstants.errorColor,
//             ),
//             child: const Text(
//               'تسجيل الخروج',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       await ref.read(authControllerProvider.notifier).signOut();
//       if (context.mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           LoginScreen.routeName,
//           (route) => false,
//         );
//       }
//     }
//   }
//
//   void _showAboutDialog(BuildContext context) {
//     showAboutDialog(
//       context: context,
//       applicationName: AppConstants.appName,
//       applicationVersion: AppConstants.appVersion,
//       applicationIcon: Container(
//         width: 64,
//         height: 64,
//         decoration: BoxDecoration(
//           color: AppConstants.primaryColor,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: const Icon(
//           Icons.payment,
//           color: Colors.white,
//           size: 32,
//         ),
//       ),
//       children: [
//         const Text(
//           'تطبيق PayPoint هو منصة شاملة للدفع الإلكتروني وشحن الخدمات المختلفة في اليمن.',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:paypoint/screens/admin/schools_management_screen.dart';
// import '../../core/constants/app_constants.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/firestore_provider.dart';
// import 'futuristic_admin_dashboard.dart';
// import 'futuristic_admin_dashboard_screen.dart';
//
// class AdminDashboardScreen extends ConsumerWidget {
//   static const String routeName = '/admin-dashboard';
//
//   const AdminDashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Redirect to futuristic version
//     return const FuturisticAdminDashboardScreen();
//     final currentUserAsync = ref.watch(currentUserAsyncProvider);
//     final cardStatsAsync = ref.watch(cardStatisticsProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'لوحة تحكم المسؤول',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: AppConstants.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: currentUserAsync.when(
//         data: (user) {
//           if (user == null || !user.isAdmin) {
//             return const Center(
//               child: Text(
//                 'غير مصرح لك بالوصول لهذه الصفحة',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: AppConstants.errorColor,
//                   fontFamily: 'Cairo',
//                 ),
//               ),
//             );
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Welcome Message
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'مرحباً بك في لوحة التحكم',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'إدارة كاملة لتطبيق ${AppConstants.appName}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Statistics Cards
//                 const Text(
//                   'الإحصائيات',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppConstants.textPrimary,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 cardStatsAsync.when(
//                   data: (stats) => GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 1.5,
//                     children: [
//                       _buildStatCard(
//                         title: 'إجمالي الكروت',
//                         value: stats['total'].toString(),
//                         icon: Icons.sim_card,
//                         color: AppConstants.primaryColor,
//                       ),
//                       _buildStatCard(
//                         title: 'الكروت المتاحة',
//                         value: stats['available'].toString(),
//                         icon: Icons.inventory,
//                         color: AppConstants.successColor,
//                       ),
//                       _buildStatCard(
//                         title: 'الكروت المباعة',
//                         value: stats['sold'].toString(),
//                         icon: Icons.shopping_cart,
//                         color: AppConstants.warningColor,
//                       ),
//                       _buildStatCard(
//                         title: 'الشبكات',
//                         value: (stats['byNetwork'] as Map).length.toString(),
//                         icon: Icons.network_cell,
//                         color: AppConstants.secondaryColor,
//                       ),
//                     ],
//                   ),
//                   loading: () => const Center(child: CircularProgressIndicator()),
//                   error: (_, __) => Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red[300]!),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'خطأ في تحميل الإح��ائيات',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // Management Sections
//                 const Text(
//                   'الإدارة',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppConstants.textPrimary,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildManagementCard(
//                   icon: Icons.sim_card,
//                   title: 'إدارة الكروت',
//                   subtitle: 'إضافة وإدارة كروت الشحن',
//                   color: AppConstants.primaryColor,
//                   onTap: () {
//                     Navigator.of(context).pushNamed(CardsManagementScreen.routeName);
//                   },
//                 ),
//
//                 _buildManagementCard(
//                   icon: Icons.history,
//                   title: '��دارة المعاملات',
//                   subtitle: 'عرض وإدارة جميع المعاملات',
//                   color: AppConstants.secondaryColor,
//                   onTap: () {
//                     Navigator.of(context).pushNamed(TransactionsAdminScreen.routeName);
//                   },
//                 ),
//
//                 _buildManagementCard(
//                   icon: Icons.school,
//                   title: 'إدارة المدارس',
//                   subtitle: 'إضافة وإدارة المدارس',
//                   color: AppConstants.successColor,
//                   onTap: () {
//                     Navigator.of(context).pushNamed(SchoolsManagementScreen.routeName);
//                   },
//                 ),
//
//                 _buildManagementCard(
//                   icon: Icons.people,
//                   title: 'إدارة الم��تخدمين',
//                   subtitle: 'عرض وإدارة حسابات المستخدمين',
//                   color: AppConstants.warningColor,
//                   onTap: () {
//                     // Navigate to users management
//                   },
//                 ),
//
//                 _buildManagementCard(
//                   icon: Icons.settings,
//                   title: 'إعدادات النظام',
//                   subtitle: 'إعدادات عامة للتطبي��',
//                   color: AppConstants.textSecondary,
//                   onTap: () {
//                     // Navigate to system settings
//                   },
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
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 28,
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//               fontFamily: 'Cairo',
//             ),
//           ),
//
//           const SizedBox(height: 4),
//
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 14,
//               color: AppConstants.textSecondary,
//               fontFamily: 'Cairo',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildManagementCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 30,
//               ),
//             ),
//
//             const SizedBox(width: 20),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
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
// }

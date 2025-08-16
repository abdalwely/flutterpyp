import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboard';

  Widget _buildTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildTile(
              context,
              icon: Icons.send_to_mobile,
              label: 'تعبئة كرت إنترنت',
              onTap: () {
                // TODO: Navigate to Recharge Screen
              },
            ),
            _buildTile(
              context,
              icon: Icons.receipt_long,
              label: 'تسديد فاتورة',
              onTap: () {
                // TODO: Navigate to Bill Payment Screen
              },
            ),
            _buildTile(
              context,
              icon: Icons.history,
              label: 'سجل العمليات',
              onTap: () {
                // TODO: Navigate to History Screen
              },
            ),
            _buildTile(
              context,
              icon: Icons.people,
              label: 'إدارة الزبائن',
              onTap: () {
                // TODO: Navigate to Customers Screen
              },
            ),
            _buildTile(
              context,
              icon: Icons.settings,
              label: 'الإعدادات',
              onTap: () {
                // TODO: Navigate to Settings Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

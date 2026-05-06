import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Local variables to hold the REAL numbers from the database
  int totalOrdersCount = 0;
  int pendingOrdersCount = 0;
  double platformRevenue = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ApiService.getOrderStats();
      setState(() {
        totalOrdersCount = stats['total_orders'] ?? 0;
        pendingOrdersCount = stats['pending_orders'] ?? 0;
        platformRevenue = (stats['total_revenue'] ?? 0).toDouble();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>().products;
    final orders = context.watch<OrderProvider>().orders;
    final users = auth.allUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${auth.currentUser?.name ?? 'Admin'}',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 4),
              Text('Here\'s your platform overview',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: AppDimens.paddingLarge),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: '${users.length}',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Products',
                    value: '${products.length}',
                    icon: Icons.inventory_2,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    title: 'Orders',
                    value: '$totalOrdersCount', // FIXED: Uses real DB count
                    icon: Icons.receipt_long,
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    title: 'Revenue',
                    value: '৳${platformRevenue.toStringAsFixed(0)}', // FIXED: Uses real DB total
                    icon: Icons.account_balance_wallet,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.paddingLarge),

              // Pending Orders Alert
              if (pendingOrdersCount > 0)
                _PendingAlert(count: pendingOrdersCount),

              const SizedBox(height: AppDimens.paddingLarge),
              Text('Recent Orders', style: AppTextStyles.heading3),
              const SizedBox(height: 12),

              if (orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No orders yet'),
                  ),
                )
              else
                ...orders.take(5).map((order) => _RecentOrderTile(order: order)),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for Pending Alert
class _PendingAlert extends StatelessWidget {
  final int count;
  const _PendingAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count pending order${count > 1 ? 's' : ''} require attention',
              style: AppTextStyles.body.copyWith(
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            Text(title, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(order.status).withValues(alpha: 0.15),
          child: Icon(Icons.receipt, color: _statusColor(order.status)),
        ),
        title: Text(order.id, style: AppTextStyles.body),
        subtitle: Text(
          '৳${order.totalAmount.toStringAsFixed(0)} • ${order.statusText}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: _StatusChip(status: order.statusText),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.shipped: return Colors.indigo;
      case OrderStatus.delivered: return AppColors.primary;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Pending' => Colors.orange,
      'Confirmed' => Colors.blue,
      'Shipped' => Colors.indigo,
      'Delivered' => Colors.green,
      'Cancelled' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
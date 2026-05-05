import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // This tells the Provider to go get the orders from the API
    Future.microtask(() =>
        context.read<OrderProvider>().fetchOrders()
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final orderProvider = context.watch<OrderProvider>();

    // This logic stays the same
    final orders = user.role.name == 'farmer'
        ? orderProvider.getOrdersByFarmer(user.id)
        : orderProvider.getOrdersByBuyer(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      // Added a loading indicator so you know if the app is working
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        itemCount: orders.length,
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  // 1. Logic for updating status
  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      final int orderId = int.parse(order.id.toString());
      await context.read<OrderProvider>().updateOrderStatus(orderId, status);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${status == 'confirmed' ? 'Accepted' : 'Cancelled'}!'),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 2. Helper for colors
  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.shipped: return Colors.purple;
      case OrderStatus.delivered: return AppColors.primary;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final user = context.read<AuthProvider>().currentUser!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Order ID and Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- ITEMS: Product Names and Prices ---
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.productName} × ${item.quantity}', style: const TextStyle(fontSize: 13)),
                  Text('TK ${item.lineTotal.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            )),
            const Divider(height: 20),

            // --- FOOTER: Date and Total ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment: ${order.paymentMethod}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text(
                  'TK ${order.totalAmount.toInt()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),

            // --- ACTION BUTTONS: Farmer only ---
            if (user.role.name == 'farmer' && order.status == OrderStatus.pending) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, 'cancelled'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, 'confirmed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Accept Order'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
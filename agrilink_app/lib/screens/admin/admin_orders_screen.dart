import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _searchQuery = '';
  OrderStatus? _statusFilter;
  PaymentStatus? _paymentFilter;
  DateTimeRange? _dateRange;
  String _sortBy = 'newest';

  List<Order> _applyFilters(List<Order> orders) {
    var filtered = orders.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.id.toLowerCase().contains(query) ||
            o.shippingAddress.toLowerCase().contains(query) ||
            o.items.any(
                (i) => i.productName.toLowerCase().contains(query));
      }).toList();
    }

    if (_statusFilter != null) {
      filtered =
          filtered.where((o) => o.status == _statusFilter).toList();
    }

    if (_paymentFilter != null) {
      filtered = filtered
          .where((o) => o.paymentStatus == _paymentFilter)
          .toList();
    }

    if (_dateRange != null) {
      filtered = filtered.where((o) {
        return o.createdAt.isAfter(
                _dateRange!.start.subtract(const Duration(days: 1))) &&
            o.createdAt
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'amount_high':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_low':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _paymentFilter = null;
      _dateRange = null;
      _sortBy = 'newest';
    });
  }

  bool get _hasActiveFilters =>
      _statusFilter != null || _paymentFilter != null || _dateRange != null;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = context.watch<OrderProvider>().orders;
    final filteredOrders = _applyFilters(allOrders);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by order ID, product, or address...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Filter Row - Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.filter_list,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Status:', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('All', null),
                        _buildStatusChip('Pending', OrderStatus.pending),
                        _buildStatusChip(
                            'Confirmed', OrderStatus.confirmed),
                        _buildStatusChip('Shipped', OrderStatus.shipped),
                        _buildStatusChip(
                            'Delivered', OrderStatus.delivered),
                        _buildStatusChip(
                            'Cancelled', OrderStatus.cancelled),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Filter Row - Payment & Date & Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Payment filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius:
                          BorderRadius.circular(AppDimens.borderRadiusSmall),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PaymentStatus?>(
                        value: _paymentFilter,
                        isExpanded: true,
                        hint: const Text('Payment',
                            style: TextStyle(fontSize: 13)),
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Payments'),
                          ),
                          DropdownMenuItem(
                            value: PaymentStatus.pending,
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: PaymentStatus.paid,
                            child: Text('Paid'),
                          ),
                          DropdownMenuItem(
                            value: PaymentStatus.failed,
                            child: Text('Failed'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _paymentFilter = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Date range
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _dateRange != null
                        ? '${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}'
                        : 'Date',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    side: BorderSide(
                      color: _dateRange != null
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Sort
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, size: 20),
                  onSelected: (v) => setState(() => _sortBy = v),
                  itemBuilder: (_) => [
                    _buildSortItem('newest', 'Newest First'),
                    _buildSortItem('oldest', 'Oldest First'),
                    _buildSortItem('amount_high', 'Amount: High to Low'),
                    _buildSortItem('amount_low', 'Amount: Low to High'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results & Clear
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredOrders.length} order${filteredOrders.length != 1 ? 's' : ''} found',
                  style: AppTextStyles.bodySmall,
                ),
                const Spacer(),
                if (_hasActiveFilters)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear Filters',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No orders match your filters'),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _OrderCard(order: filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, OrderStatus? status) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  PopupMenuItem<String> _buildSortItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            const Icon(Icons.check, size: 16, color: AppColors.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusBadge(order.statusText),
              ],
            ),
            const SizedBox(height: 8),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Text(
                        '৳${item.lineTotal.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                )),

            const Divider(height: 16),

            // Footer
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.shippingAddress,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(order.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPaymentBadge(order.paymentStatus),
                const SizedBox(width: 8),
                Text(
                  order.paymentMethod,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '৳${order.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
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
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPaymentBadge(PaymentStatus status) {
    final (color, label) = switch (status) {
      PaymentStatus.paid => (Colors.green, 'Paid'),
      PaymentStatus.pending => (Colors.orange, 'Unpaid'),
      PaymentStatus.failed => (Colors.red, 'Failed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum OrderStatus { pending, confirmed, cancelled, shipped, delivered }

enum PaymentStatus { pending, paid, failed }

OrderStatus _parseOrderStatus(String? s) {
  switch (s) {
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    default:
      return OrderStatus.pending;
  }
}

PaymentStatus _parsePaymentStatus(String? s) {
  switch (s) {
    case 'paid':
      return PaymentStatus.paid;
    case 'failed':
      return PaymentStatus.failed;
    default:
      return PaymentStatus.pending;
  }
}

class Order {
  final String id;
  final String buyerId;
  final double totalAmount;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final String shippingAddress;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.totalAmount,
    this.paymentMethod = 'COD',
    this.paymentStatus = PaymentStatus.pending,
    this.status = OrderStatus.pending,
    this.shippingAddress = '',
    this.items = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      buyerId: (json['buyer_id'] ?? '').toString(),
      totalAmount:
          double.tryParse(json['total_amount'].toString()) ?? 0,
      paymentMethod: json['payment_method'] ?? 'COD',
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      status: _parseOrderStatus(json['status']),
      shippingAddress: json['shipping_address'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItem.fromJson(e))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String farmerId;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.id,
    this.orderId = '',
    required this.productId,
    this.productName = '',
    required this.farmerId,
    required this.unitPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? '',
      farmerId: (json['farmer_id'] ?? '').toString(),
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }

  double get lineTotal => unitPrice * quantity;
}

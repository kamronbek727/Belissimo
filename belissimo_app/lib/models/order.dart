import 'cart_item.dart';

class OrderData {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<CartItem> items;
  final String deliveryType; // 'delivery' or 'pickup'
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? apartmentOrOffice;
  final String? landmark;
  final String? courierComment;
  final String? branch;
  final String paymentMethod; // 'cash' or 'card'
  final String paymentStatus; // 'paid' or 'unpaid'
  final int subtotal;
  final int deliveryFee;
  final String total; // e.g. "129 000 so'm"
  final String status; // 'new', 'preparing', 'ready', 'courier_assigned', 'on_the_way', 'delivered', 'cancelled'
  final String date;

  OrderData({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.deliveryType,
    this.address,
    this.latitude,
    this.longitude,
    this.apartmentOrOffice,
    this.landmark,
    this.courierComment,
    this.branch,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'items': items.map((item) => item.toJson()).toList(),
    'deliveryType': deliveryType,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'apartmentOrOffice': apartmentOrOffice,
    'landmark': landmark,
    'courierComment': courierComment,
    'branch': branch,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status,
    'date': date,
  };

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      items: List<CartItem>.from((json['items'] as List? ?? []).map((item) => CartItem.fromJson(item))),
      deliveryType: json['deliveryType'],
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      apartmentOrOffice: json['apartmentOrOffice'],
      landmark: json['landmark'],
      courierComment: json['courierComment'],
      branch: json['branch'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      subtotal: json['subtotal'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? 0,
      total: json['total'] ?? '',
      status: json['status'] ?? 'new',
      date: json['date'] ?? '',
    );
  }
}

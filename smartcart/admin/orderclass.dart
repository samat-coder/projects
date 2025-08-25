import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String address;
  final String city;
  final String pincode;
  final String phone;
  final String paymentMethod;
  final String paymentStatus;
  final String productTitle;
  final String productImage;
  final int quantity;
  final String selectedColor;
  final String status;
  final double totalPrice;
  final DateTime orderDate;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.address,
    required this.city,
    required this.pincode,
    required this.phone,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.productTitle,
    required this.productImage,
    required this.quantity,
    required this.selectedColor,
    required this.status,
    required this.totalPrice,
    required this.orderDate,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      pincode:data['pincode'],
      phone: data['phone'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productImage: data['productImage'] ?? '',
      quantity: data['quantity'] ?? 0,
      selectedColor: data['selectedColor'] ?? '',
      status: data['status'] ?? '',
      totalPrice: (data['totalPrice'] is int)
          ? (data['totalPrice'] as int).toDouble()
          : (data['totalPrice'] ?? 0.0).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
    );
  }
}

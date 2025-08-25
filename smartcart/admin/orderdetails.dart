import 'package:admin_ecom/orderclass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? selectedStatus;
  String? selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.status;
    selectedPaymentStatus = widget.order.paymentStatus;
  }

  Future<void> _updateOrder() async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id)
        .update({
      'status': selectedStatus,
      'paymentStatus': selectedPaymentStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Order updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 Order Details",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      o.productImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.productTitle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Color: ${o.selectedColor}"),
                        Text("Quantity: ${o.quantity}"),
                        const SizedBox(height: 10),
                        Text("Total Price: \$${o.totalPrice}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("👤 Customer Details",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Name: ${o.customerName}"),
                    Text("Phone: ${o.phone}"),
                    Text("Address: ${o.address}, ${o.city}, ${o.pincode}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🕒 Order Info",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Order Date: ${o.orderDate}"),
                    Text("Payment Method: ${o.paymentMethod}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Dropdowns for status updates
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Order Status",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              value: selectedStatus,
              items: ['Pending', 'Shipped', 'Delivered']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Payment Status",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              value: selectedPaymentStatus,
              items: ['Pending', 'Paid']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedPaymentStatus = val),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.save,color: Colors.white,),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: _updateOrder,
              label: const Text(
                "Update Order",
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

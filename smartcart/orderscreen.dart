import 'dart:convert';
import 'package:bookapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String? selectedColor;
  final int quantity;
  final String? selectedsize;

  const OrderDetailsScreen({
    super.key,
    required this.product,
    this.selectedColor,
    required this.quantity,
    this.selectedsize,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = false;
  String _paymentMethod = "Cash on Delivery";

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _addressController.text = data['address'] ?? '';
            _cityController.text = data['city'] ?? '';
            _pincodeController.text = data['pincode'] ?? '';
            _phoneController.text = data['mobile'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Failed to fetch user info: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load user info")));
    }
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (_paymentMethod == "Online Payment") {
      await _startStripePayment();
    } else {
      await _saveOrder(paymentStatus: "Pending");
    }
  }

  Future<void> _startStripePayment() async {
    try {
      final totalAmount =
          (widget.product['price'] * widget.quantity * 100).toInt();

      final response = await http.post(
        Uri.parse('https://stripe-1-x37b.onrender.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': totalAmount, 'currency': 'usd'}),
      );

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['client_secret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your Shop',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await _saveOrder(paymentStatus: "Paid");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrder({required String paymentStatus}) async {
    try {
      final productId = widget.product['id'];

      final Map<String, dynamic> orderData = {
        'productId': productId,
        'productTitle': widget.product['title'],
        'productImage': widget.product['image'],
        'selectedColor': widget.selectedColor,
        'quantity': widget.quantity,
        'totalPrice': widget.product['price'] * widget.quantity,
        'paymentMethod': _paymentMethod,
        'orderDate': DateTime.now(),
        'status': 'Pending',
        'customerName': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'phone': _phoneController.text.trim(),
        'paymentStatus': paymentStatus,
      };

      // Add imagesByColor if it exists
      if (widget.product.containsKey('imagesByColor') &&
          widget.product['imagesByColor'] != null) {
        orderData['imagesByColor'] = widget.product['imagesByColor'];
      }

      // Add selectedSize if applicable
      if ((widget.product['categories'] == 'shoes' ||
              widget.product['categories'] == 'clothes') &&
          widget.selectedsize != null) {
        orderData['selectedSize'] = widget.selectedsize;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Decrease product stock

      final productSource =
          widget.product['source']; 

      if (productSource == null) {
        throw Exception("Missing product ID or source");
      }

      final productRef = FirebaseFirestore.instance
          .collection(productSource)
          .doc(productId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(productRef);

        if (!snapshot.exists) throw Exception("Product not found");

        final currentStock = snapshot.get('stock') ?? 0;
        final newStock = currentStock - widget.quantity;

        if (newStock < 0) throw Exception("Not enough stock");

        transaction.update(productRef, {'stock': newStock});
      });

      _showSuccessAnimation();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/animation/order_success2.json',
                    repeat: false,
                    onLoaded: (composition) {
                      Future.delayed(composition.duration, () {
                        Navigator.of(context).pop(); 

                        Navigator.of(context).popUntil(
                          (route) => route.settings.name == '/productDetail',
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Order Placed Successfully!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );

    setState(() => _isLoading = false);
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: true, 
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget paymentOption(String title, String value) {
    bool selected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: selected ? Colors.indigo : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.indigo,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl =
        (product['imagesByColor'] != null &&
                widget.selectedColor != null &&
                product['imagesByColor'][widget.selectedColor] != null)
            ? product['imagesByColor'][widget.selectedColor]
            : product['image'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[500],
      ),
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product summary
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.selectedColor != null)
                            Text('Color: ${widget.selectedColor}'),
                          Text('Qty: ${widget.quantity}'),
                          if (widget.product['categories'] == 'shoes' ||
                              widget.product['categories'] == 'clothes' &&
                                  widget.selectedsize != null)
                            Text('Size: ${widget.selectedsize}'),
                          Text(
                            'Total: \$${(product['price'] * widget.quantity).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Details heading with Edit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Delivery Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                      if (updated == true) {
                        _fetchUserDetails();
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),

              buildTextField(
                _nameController,
                "Full Name",
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              buildTextField(
                _addressController,
                "Address",
                maxLines: 2,
                validator: (val) => val!.isEmpty ? "Enter address" : null,
              ),
              buildTextField(
                _cityController,
                "City",
                validator: (val) => val!.isEmpty ? "Enter city" : null,
              ),
              buildTextField(
                _pincodeController,
                "Pincode",
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter pincode";
                  if (!RegExp(r'^\d{6}$').hasMatch(val)) {
                    return "6-digit required";
                  }
                  return null;
                },
              ),
              buildTextField(
                _phoneController,
                "Phone",
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter phone";
                  if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                    return "10-digit required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              paymentOption("Cash on Delivery", "Cash on Delivery"),
              paymentOption("Online Payment", "Online Payment"),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Place Order",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

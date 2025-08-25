import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class OrderDetailView extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  bool isloading = false;

  Future<Uint8List> generateInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final date = order['orderDate']?.toDate();
    final formattedDate =
        date != null ? "${date.day}/${date.month}/${date.year}" : "Unknown";

    final logoBytes = await rootBundle.load('assets/images/ecomlogo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    // Using a placeholder for product image as networkImage requires context, fix accordingly:
    // final productImage = pw.MemoryImage(
    //   (await rootBundle.load(
    //     'assets/images/ecomlogo.png',
    //   )).buffer.asUint8List(),
    // );

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(logo, height: 150, width: 150)),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    "INVOICE",
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("Order Date: $formattedDate"),
                pw.Text("Order Status: ${order['status']}"),
                pw.SizedBox(height: 16),
                // pw.Center(
                //   child: pw.Container(
                //     height: 150,
                //     width: 150,
                //     child: pw.Image(productImage, fit: pw.BoxFit.cover),
                //   ),
                // ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Customer Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text("Name: ${order['customerName']}"),
                pw.Text(
                  "Address: ${order['address']}, ${order['city']} - ${order['pincode']}",
                ),
                pw.Text("Phone: ${order['phone']}"),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Product Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text("Title: ${order['productTitle']}"),
                if (order.containsKey('selectedSize'))
                  pw.Text("Size: ${order['selectedSize']}"),
                if (order.containsKey('selectedColor') &&
                    order['selectedColor'] != null &&
                    order['selectedColor'].toString().isNotEmpty)
                  pw.Text("Color: ${order['selectedColor']}"),

                pw.Text("Quantity: ${order['quantity']}"),
                pw.Text("Total Price: \$${order['totalPrice']}"),
                pw.Text("Payment Method: ${order['paymentMethod']}"),
                pw.Text("Payment Status: ${order['paymentStatus'] ?? 'N/A'}"),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Thank you for shopping with us!",
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  int getCurrentStatusIndex(String status) {
    switch (status) {
      case 'Pending':
        return 0;
      case 'Shipped':
        return 1;
      case 'Delivered':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.order['orderDate']?.toDate();
    final formattedDate =
        date != null ? "${date.day}/${date.month}/${date.year}" : "Unknown";

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[500],
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product Image
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.order['productImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Title
            Text(
              widget.order['productTitle'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Order Details Section
            _sectionCard(
              title: "Order Summary",
              children: [
                if (widget.order.containsKey('selectedColor') &&
                    widget.order['selectedColor'] != null &&
                    widget.order['selectedColor'].toString().isNotEmpty)
                  _infoTile(
                    Icons.color_lens,
                    "Color",
                    widget.order['selectedColor'],
                  ),

                _infoTile(
                  Icons.shopping_bag,
                  "Quantity",
                  "${widget.order['quantity']}",
                ),
                _infoTile(
                  Icons.price_check,
                  "Total Price",
                  "\$${widget.order['totalPrice']}",
                ),
                _infoTile(
                  Icons.payment,
                  "Payment Method",
                  widget.order['paymentMethod'],
                ),
                _infoTile(
                  Icons.verified,
                  "Payment Status",
                  widget.order['paymentStatus'] ?? 'N/A',
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.track_changes,
                      size: 20,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Order Status:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    buildStatusChip(widget.order['status']),
                  ],
                ),

                _infoTile(Icons.calendar_today, "Order Date", formattedDate),
                if (widget.order.containsKey('selectedSize'))
                  _infoTile(
                    Icons.format_size_outlined,
                    "Size",
                    widget.order['selectedSize'],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Customer Info Section
            _sectionCard(
              title: "Customer Information",
              children: [
                _infoTile(Icons.person, "Name", widget.order['customerName']),
                _infoTile(
                  Icons.location_on,
                  "Address",
                  widget.order['address'],
                ),
                _infoTile(Icons.location_city, "City", widget.order['city']),
                _infoTile(
                  Icons.markunread_mailbox,
                  "Pincode",
                  widget.order['pincode'],
                ),
                _infoTile(Icons.phone, "Phone", widget.order['phone']),
              ],
            ),
            const SizedBox(height: 80), // Extra space for button overlay
          ],
        ),
      ),
      // Floating button pinned at the bottom center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FloatingActionButton.extended(
            onPressed: () async {
              setState(() {
                isloading = true;
              });

              final pdfData = await generateInvoice(widget.order);
              await Printing.layoutPdf(onLayout: (format) => pdfData);
              setState(() {
                isloading = false;
              });
            },
            label:
                isloading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "Download Invoice",
                      style: TextStyle(color: Colors.white),
                    ),
            icon:
                isloading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),

      backgroundColor: Colors.grey.shade100,
    );
  }
}

Widget _sectionCard({required String title, required List<Widget> children}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

Widget _infoTile(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget buildStatusChip(String status) {
  Color bgColor;
  IconData icon;

  switch (status) {
    case 'Pending':
      bgColor = Colors.orange.shade200;
      icon = Icons.hourglass_empty;
      break;
    case 'Shipped':
      bgColor = Colors.blue.shade200;
      icon = Icons.local_shipping;
      break;
    case 'Delivered':
      bgColor = Colors.green.shade300;
      icon = Icons.check_circle;
      break;
    default:
      bgColor = Colors.grey.shade400;
      icon = Icons.help_outline;
  }

  return Chip(
    label: Text(status),
    avatar: Icon(icon, size: 16, color: Colors.white),
    backgroundColor: bgColor,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  );
}

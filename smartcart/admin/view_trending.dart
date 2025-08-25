import 'package:admin_ecom/add_trending.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewTrending extends StatelessWidget {
  const ViewTrending({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Trending", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('treding').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['image'] ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['description'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Category: ${data['categories'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "Price: \$${data['price']}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "stock: ${data['stock']}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (data['sizes'] != null &&
                                    data['sizes'] is List &&
                                    (data['sizes'] as List).isNotEmpty)
                                  Text(
                                    "Sizes: ${(data['sizes'] as List).join(', ')}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _editProduct(context, docId, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () =>
                                    FirebaseFirestore.instance
                                        .collection('treding')
                                        .doc(docId)
                                        .delete(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to AddProduct screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTrending()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _editProduct(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final titleController = TextEditingController(text: data['title']);
    final descController = TextEditingController(text: data['description']);
    final imageController = TextEditingController(text: data['image']);
    final priceController = TextEditingController(
      text: data['price'].toString(),
    );
    final stockcontroller = TextEditingController(
      text: data['stock'].toString(),
    );
    final categoryController = TextEditingController(text: data['categories']);

    final hasSizes =
        data['sizes'] != null &&
        data['sizes'] is List &&
        (data['sizes'] as List).isNotEmpty;
    final sizesController = TextEditingController(
      text: hasSizes ? (data['sizes'] as List).join(', ') : '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Product"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(titleController, "Title"),
                  _buildTextField(descController, "Description"),
                  _buildTextField(imageController, "Image URL"),
                  _buildTextField(priceController, "Price", isNumber: true),
                  _buildTextField(stockcontroller, "stock", isNumber: true),
                  _buildTextField(categoryController, "Category"),
                  if (hasSizes)
                    _buildTextField(sizesController, "Sizes (comma separated)"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  final sizesText = sizesController.text.trim();
                  final updatedData = {
                    'categories': categoryController.text.trim(),
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'image': imageController.text.trim(),
                    'price': double.tryParse(priceController.text.trim()) ?? 0,
                    'stock': int.tryParse(stockcontroller.text.trim()) ?? 0,
                  };

                  if (hasSizes && sizesText.isNotEmpty) {
                    updatedData['sizes'] =
                        sizesText.split(',').map((e) => e.trim()).toList();
                  } else {
                    updatedData.remove('sizes');
                  }

                  FirebaseFirestore.instance
                      .collection('treding')
                      .doc(docId)
                      .update(updatedData);

                  Navigator.pop(context);
                },
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

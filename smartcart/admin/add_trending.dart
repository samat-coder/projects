import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTrending extends StatefulWidget {
  const AddTrending({super.key});

  @override
  State<AddTrending> createState() => _AddTrendingState();
}

class _AddTrendingState extends State<AddTrending> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockcontroller = TextEditingController();
  String? selectedSource;

  List<String> sizes = [];
  String? selectedCategory;

  Future<void> _submit() async {
    if (_sizeController.text.isNotEmpty) {
      sizes.add(_sizeController.text.trim());
      _sizeController.clear();
    }

    if (!_formKey.currentState!.validate() || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    try {
      final imageUrl = _imageUrlController.text.trim();

      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': int.tryParse(_stockcontroller.text.trim()) ?? 0,
        'categories': selectedCategory,
        'image': imageUrl,
        'source': selectedSource,
      };
      if (sizes.isNotEmpty) {
        data["sizes"] = sizes;
      }

      await FirebaseFirestore.instance.collection('treding').add(data);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('trending Product added successfully')),
      );

      _formKey.currentState!.reset();
      setState(() {
        sizes.clear();
        selectedCategory = null;
        selectedSource = null;
        _sizeController.clear();
        _imageUrlController.clear();
        _imageUrlController.clear();
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockcontroller.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          "Add trending Product",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader("trending Product Details"),
                  const SizedBox(height: 10),
                  _buildTextField(_titleController, 'Title'),
                  _buildTextField(_descriptionController, 'Description'),
                  _buildTextField(_priceController, 'Price', isNumber: true),
                  _buildTextField(_stockcontroller, 'stock', isNumber: true),

                  const SizedBox(height: 15),
                  _buildHeader("Sizes"),
                  _buildSizeInput(),

                  const SizedBox(height: 15),
                  _buildHeader("Category"),
                  _buildCategoryDropdown(),

                  const SizedBox(height: 15),
                  _buildHeader("source"),
                  _buildSourceDropdown(),

                  const SizedBox(height: 15),
                  _buildHeader("Image URL"),
                  _buildTextField(_imageUrlController, 'Image URL'),

                  const SizedBox(height: 10),
                  if (_imageUrlController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrlController.text,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Invalid image URL');
                        },
                      ),
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Add Product",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) => val!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Divider(thickness: 1.2),
      ],
    );
  }

  Widget _buildSizeInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _sizeController,
            decoration: InputDecoration(
              labelText: 'Add Size (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_sizeController.text.isNotEmpty) {
              setState(() {
                sizes.add(_sizeController.text.trim());
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("size added")));
                _sizeController.clear();
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<DropdownMenuItem<String>> items =
            snapshot.data!.docs
                .map(
                  (doc) => DropdownMenuItem<String>(
                    value: doc['name'],
                    child: Text(doc['name']),
                  ),
                )
                .toList();

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: selectedCategory,
          items: items,
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildSourceDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sources').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        List<DropdownMenuItem<String>> items =
            snapshot.data!.docs
                .map(
                  (doc) => DropdownMenuItem<String>(
                    value: doc['name'],
                    child: Text(doc['name']),
                  ),
                )
                .toList();

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Source',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: selectedSource,
          items: items,
          onChanged: (value) {
            setState(() {
              selectedSource = value;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        );
      },
    );
  }
}

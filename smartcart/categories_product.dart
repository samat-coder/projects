import 'package:bookapp/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ... other imports ...
import 'package:flutter/material.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) toggleFavorite;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.favoriteProducts,
    required this.toggleFavorite,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool isLoading = true;
  String _searchquery = '';
  String _selectedpricerange = 'All';

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('categories', isEqualTo: widget.categoryName)
            .get();

    final fetchedProducts =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

    setState(() {
      _products = fetchedProducts;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _filteredProducts() {
    return _products.where((product) {
      final titleMatch = product['title'].toString().toLowerCase().contains(
        _searchquery.toLowerCase(),
      );

      double price = double.tryParse(product['price'].toString()) ?? 0;
      bool priceMatch = true;

      if (_selectedpricerange == '50-500') {
        priceMatch = price >= 50 && price <= 500;
      } else if (_selectedpricerange == '600-1000') {
        priceMatch = price >= 600 && price <= 1000;
      }

      return titleMatch && priceMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.categoryName,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple[500],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? const Center(child: Text('No products found.'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // 🔍 Search Bar
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration:  InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: Icon(Icons.search_rounded),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple)
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchquery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 🔽 Price Dropdown
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedpricerange,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            items:
                                ['All', '50-500', '600-1000'].map((range) {
                                  return DropdownMenuItem<String>(
                                    value: range,
                                    child: Text(
                                      range == 'All'
                                          ? 'All'
                                          : range == '50-500'
                                          ? '₹50–₹500'
                                          : '₹600–₹1000',
                                      style: TextStyle(
                                        color:
                                            _selectedpricerange == range
                                                ? Colors
                                                    .deepPurple // selected item in dropdown
                                                : Colors
                                                    .black, // others stay default
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedpricerange = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filtered = _filteredProducts();
                        return filtered.isEmpty
                            ? const Center(child: Text('No matching products.'))
                            : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filtered.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.50,
                                  ),
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                bool isFavorite = widget.favoriteProducts.any(
                                  (p) => p['id'] == product['id'],
                                );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => myproduct_details(
                                              product: product,
                                            ),
                                             settings: RouteSettings(name: '/productDetail'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            55,
                                            56,
                                            67,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    child: const Text(
                                                      "-50%",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      isFavorite
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color:
                                                          isFavorite
                                                              ? Colors.red
                                                              : Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      widget.toggleFavorite(
                                                        product,
                                                      );
                                                      setState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.network(
                                                  product["image"],
                                                  fit: BoxFit.fill,
                                                  height: 170,
                                                  width: 235,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Image.network(
                                                      "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                product["title"],
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                "\$${product["price"]}",
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

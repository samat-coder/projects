import 'package:bookapp/login.dart';
import 'package:bookapp/orderscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class myproduct_details extends StatefulWidget {
  final Map<String, dynamic> product;
  const myproduct_details({super.key, required this.product});

  @override
  State<myproduct_details> createState() => _mytrending_detailsState();
}

class _mytrending_detailsState extends State<myproduct_details> {
  void Function(void Function())? updatePriceUI;

  bool _isExpanded = false;
  String? _selectedcolor;

  int _quantity = 1;
  String? _selectedsize;
  int availablestock = 0;
  double _currentRating = 0.0;
  List<Map<String, dynamic>> availablecolor = [];

  final TextEditingController _commentController = TextEditingController();

  Future<void> _postComment() async {
    final commentText = _commentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (commentText.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "please firstly login to do this",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    final collection = widget.product['source'] ?? 'products';

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final username = userDoc.data()?['name'] ?? 'User';

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.product['id'])
        .collection('comments')
        .add({
          'userId': user.uid,
          'username': username,
          'comment': commentText,
          'rating': _currentRating,
          'timestamp': FieldValue.serverTimestamp(),
        });

    //Recalculate and update averageRating
    final commentsSnapshot =
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.product['id'])
            .collection('comments')
            .get();

    double totalRating = 0;
    int count = 0;

    for (var doc in commentsSnapshot.docs) {
      if (doc.data().containsKey('rating')) {
        totalRating += (doc['rating'] as num).toDouble();
        count++;
      }
    }

    double averageRating = count > 0 ? totalRating / count : 0;

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.product['id'])
        .update({'averageRating': averageRating});
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey; // fallback for unknown colors
    }
  }

  @override
void initState() {
  super.initState();

  final colorMapRaw = widget.product['imagesByColor'];

  Map<String, dynamic> colorMap;
  if (colorMapRaw != null && colorMapRaw is Map<String, dynamic>) {
    colorMap = colorMapRaw;
  } else {
    colorMap = {};
  }

  if (colorMap.isNotEmpty) {
    _selectedcolor = colorMap.keys.first;
    availablecolor = colorMap.keys.map((colorName) {
      return {
        'name': colorName,
        'color': _getColorFromName(colorName),
      };
    }).toList();
  } else {
    _selectedcolor = null;
    availablecolor = [];
  }
}

  @override
  Widget build(BuildContext context) {
    //  int? maxLines = _isExpanded ? widget.product["description"].length : 2;

    String category =
        widget.product['categories']?.toString().toLowerCase() ?? '';
    bool showSizeSelector =
        category == 'shoes' ||
        category == 'clothes' ||
        category == 'electronics' ||
        category == 'watches';

    List<dynamic> rawSizes = widget.product['sizes'] ?? [];
    List<String> sizes = rawSizes.map((e) => e.toString()).toList();
    if (category == 'shoes') {
      sizes = sizes.where((size) => double.tryParse(size) != null).toList();
    }

    // ✅ Get the correct Firestore collection
    String collection = widget.product['source'] ?? 'products';

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(collection)
              .doc(widget.product['id'])
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Product not found.'));
        }

        final liveData = snapshot.data!.data() as Map<String, dynamic>;
        int stock = liveData["stock"] ?? 0;
        availablestock = stock;
        bool isOutOfStock = stock == 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
          ),
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setpricestate) {
              updatePriceUI = setpricestate;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total Price",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        Text(
                          "\$${(widget.product["price"] * _quantity).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        if (isOutOfStock)
                          const Text(
                            "Out of Stock",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed:
                          isOutOfStock
                              ? null
                              : () async {
                                if (showSizeSelector && _selectedsize == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a size before checkout.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final hasColors =
                                    widget.product['imagesByColor'] != null &&
                                    (widget.product['imagesByColor'] as Map)
                                        .isNotEmpty;

                                if (hasColors && _selectedcolor == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a color before checkout.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please firstly do the login for futher process.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  final loggedIn = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => LoginScreen(
                                            returnAfterLogin: true,
                                          ),
                                    ),
                                  );

                                  if (loggedIn == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => OrderDetailsScreen(
                                              product: widget.product,
                                              selectedColor: _selectedcolor,
                                              quantity: _quantity,
                                              selectedsize:
                                                  showSizeSelector
                                                      ? _selectedsize
                                                      : null,
                                            ),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => OrderDetailsScreen(
                                            product: widget.product,
                                            selectedColor: _selectedcolor,
                                            quantity: _quantity,
                                            selectedsize:
                                                showSizeSelector
                                                    ? _selectedsize
                                                    : null,
                                          ),
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatefulBuilder(
                  builder: (context, setStateImage) {
                    final Map<String, dynamic>? imageMap =
                        widget.product['imagesByColor'];
                    final String imageToShow =
                        (imageMap != null &&
                                _selectedcolor != null &&
                                imageMap[_selectedcolor] != null)
                            ? imageMap[_selectedcolor]
                            : (widget.product['image'] ?? '');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE SECTION
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            imageToShow,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        // COLOR SELECTOR
                        if (availablecolor.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select Color"),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    availablecolor.map((colorData) {
                                      final colorName = colorData['name'];
                                      final color = colorData['color'];

                                      return GestureDetector(
                                        onTap: () {
                                          setStateImage(() {
                                            _selectedcolor = colorName;
                                          });
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                            border: Border.all(
                                              width: 2,
                                              color:
                                                  _selectedcolor == colorName
                                                      ? Colors.black
                                                      : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ⭐ Average Rating Display (Top)
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection(collection)
                          .doc(widget.product['id'])
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink(); // Loading
                    }

                    final productData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final avgRating =
                        (productData['averageRating'] ?? 2).toDouble();

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 10),
                Text(
                  widget.product["title"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // 👇 After product title
                StatefulBuilder(
                  builder: (context, setStateDesc) {
                    int? maxLines =
                        _isExpanded ? widget.product["description"].length : 2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product["description"],
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.product["description"].length > 100)
                          TextButton(
                            onPressed: () {
                              setStateDesc(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Text(
                              _isExpanded ? 'Read Less <' : 'Read More >',
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const Divider(height: 30),
                const Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                StatefulBuilder(
                  builder: (context, setpricestate) {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setpricestate(() {
                                _quantity--;
                              });
                            }
                            if (updatePriceUI != null) {
                              updatePriceUI!(() {});
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_quantity < availablestock) {
                              setpricestate(() {
                                _quantity++;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You’ve reached maximum stock available.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            if (updatePriceUI != null) {
                              updatePriceUI!(() {});
                            }
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color:
                                _quantity < availablestock
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),
                if (showSizeSelector) ...[
                  const Text(
                    "Select Size:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, setSizeState) {
                      return Wrap(
                        spacing: 8,
                        children:
                            sizes.map((size) {
                              final selected = size == _selectedsize;
                              return ChoiceChip(
                                label: Text(size),
                                selected: selected,
                                onSelected: (selected) {
                                  setSizeState(() {
                                    _selectedsize = selected ? size : null;
                                  });
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 30),
                _buildInfoCard(
                  iconUrl:
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDtam4w69J-r7M9uBEL1IrK2jTg4uUP1Ydpw&s",
                  text: "Free Delivery",
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      iconUrl:
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8NQsFWDItLevSw58gVVv3dzJJj8L0KyEjAQ&s",
                      text: "No Return",
                      width: 150,
                    ),
                    _buildInfoCard(
                      iconUrl:
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmzpgRr5awMQJLY478n7bI08VtLyqtb2EEGg&s",
                      text: "COD Available",
                      width: 150,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // 🔽 Show Comments
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection(collection)
                          .doc(widget.product['id'])
                          .collection('comments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!.docs;

                    if (comments.isEmpty) {
                      return const Text("No comments yet.");
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final double rating =
                            (comment['rating'] ?? 0).toDouble();

                        return ListTile(
                          leading: const Icon(Icons.comment),
                          title: Text(comment['username'] ?? 'User'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rating > 0)
                                Row(
                                  children: [
                                    ...List.generate(5, (i) {
                                      if (i < rating.floor()) {
                                        return Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      } else if (i < rating &&
                                          rating - i >= 0.5) {
                                        return Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      } else {
                                        return Icon(
                                          Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }
                                    }),
                                    SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),

                              const SizedBox(height: 4),
                              Text(comment['comment']),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setLocalState) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text("Rate this product"),
                          RatingBar.builder(
                            initialRating: _currentRating,
                            minRating: 1,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder:
                                (context, _) =>
                                    Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              setLocalState(() {
                                _currentRating = rating;
                              });
                            },
                          ),
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: "Write a comment...",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  await _postComment(); // no setState here
                                  setLocalState(() {
                                    _commentController.clear();
                                    _currentRating = 3.0;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 🔼 Add Comment Box
                // TextField(
                //   controller: _commentController,
                //   maxLines: null,
                //   decoration: InputDecoration(
                //     hintText: 'Write a comment...',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     suffixIcon: IconButton(
                //       icon: const Icon(Icons.send),
                //       onPressed: _postComment,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // const Text(
                //   "Rate this product:",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 6),

                // const SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     RatingBar.builder(
                //       initialRating: _currentRating,
                //       minRating: 1,
                //       direction: Axis.horizontal,
                //       allowHalfRating: true,
                //       itemCount: 5,
                //       itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                //       itemBuilder:
                //           (context, _) =>
                //               const Icon(Icons.star, color: Colors.amber),
                //       onRatingUpdate: (rating) {
                //         _currentRating = rating;
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildInfoCard({
  required String iconUrl,
  required String text,
  double width = double.infinity,
}) {
  return Container(
    width: width,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 240, 240, 240),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(iconUrl, height: 40, width: 40),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}

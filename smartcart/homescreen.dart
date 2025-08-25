import 'package:bookapp/categories_product.dart';
import 'package:bookapp/product_detail.dart';
import 'package:bookapp/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class myhomescreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) toggleFavorite;
  const myhomescreen({
    super.key,
    required this.favoriteProducts,
    required this.toggleFavorite,
  });

  @override
  State<myhomescreen> createState() => _myhomescreenState();
}

class _myhomescreenState extends State<myhomescreen> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> trending = [];
  List<Map<String, dynamic>> filteredcategories = [];
  List<Map<String, dynamic>> filteredtrending = [];
  List<Map<String, dynamic>> sliderItems = [];
  bool loading = true;
  int currentSlide = 0;
  TextEditingController searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchCategories();
    await fetchTrending();
    await fetchSliderItems();
    filteredcategories = categories;
    filteredtrending = trending;
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    categories = snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> fetchTrending() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('treding').get();
    trending =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // optional: if you want Firestore ID
          return data;
        }).toList();
  }

  Future<void> fetchSliderItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('slider').get();
    sliderItems =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // optional: if you want Firestore ID
          return data;
        }).toList();
  }

  void searchproducts(String query) {
    setState(() {
      filteredcategories =
          categories
              .where(
                (cat) =>
                    cat['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      filteredtrending =
          trending
              .where(
                (item) =>
                    item['title'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  String getUserNameFromEmail(String email) {
    return email.split('@')[0]; // returns "karan" from "karan@gmail.com"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text("Smartcart", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.deepPurple[500],
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.supervised_user_circle, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  getUserNameFromEmail(
                    FirebaseAuth.instance.currentUser?.email ?? "User",
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: 45,
                        width: MediaQuery.of(context).size.width - 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const [
                            BoxShadow(
                              spreadRadius: 1,
                              blurRadius: 10,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchcontroller,
                                onChanged: searchproducts,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  hintText: "search",
                                  hintStyle: TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                            if (searchcontroller.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  searchcontroller.clear();
                                  searchproducts(""); // Reset search
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CarouselSlider(
                        items:
                            sliderItems.map((item) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: const [
                                    BoxShadow(blurRadius: 8.0, spreadRadius: 2),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => myproduct_details(
                                              product: item,
                                            ),
                                        settings: RouteSettings(
                                          name: '/productDetail',
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      item["image"],
                                      fit: BoxFit.cover,
                                      width: 300,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        options: CarouselOptions(
                          height: 250.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          enableInfiniteScroll: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          viewportFraction: 0.8,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentSlide = index;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        sliderItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: currentSlide == index ? 9.0 : 6.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color:
                                currentSlide == index
                                    ? Colors.deepPurple
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    if (filteredcategories.isNotEmpty)
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "categories",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    if (filteredcategories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                              NeverScrollableScrollPhysics(), // prevent internal scroll
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // two items per row
                                crossAxisSpacing: 10,
                                childAspectRatio:
                                    0.95, // adjust for height/width balance
                              ),
                          itemCount: filteredcategories.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CategoryProductsScreen(
                                          categoryName:
                                              filteredcategories[index]['name'],
                                          favoriteProducts:
                                              widget.favoriteProducts,
                                          toggleFavorite: widget.toggleFavorite,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        filteredcategories[index]["image"],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.network(
                                            "https://images.pexels.com/photos/1957477/pexels-photo-1957477.jpeg",
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      filteredcategories[index]["name"],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    if (filteredtrending.isNotEmpty)
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "trending products",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    if (filteredtrending.isNotEmpty)
                      SizedBox(
                        height: 360,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredtrending.length,
                          itemBuilder: (context, index) {
                            int proPrice = 0;
                            proPrice = filteredtrending[index]["price"];
                            final product = filteredtrending[index];
                            bool isFavorite = widget.favoriteProducts.any(
                              (p) => p['id'] == product['id'],
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            myproduct_details(product: product),
                                    settings: RouteSettings(
                                      name: '/productDetail',
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Container(
                                  height: 180,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      55,
                                      56,
                                      67,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              child: const Text(
                                                "-45%",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color:
                                                    isFavorite
                                                        ? Colors.red
                                                        : Colors.grey,
                                              ),
                                              onPressed:
                                                  () => widget.toggleFavorite(
                                                    product,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            "${filteredtrending[index]["image"]}",
                                            height: 180,
                                            width: 180,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.network(
                                                "https://images.pexels.com/photos/1957477/pexels-photo-1957477.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                                                height: 180,
                                                width: 180,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          filteredtrending[index]["title"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "\$$proPrice",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}

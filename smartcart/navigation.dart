import 'package:bookapp/favorite.dart';
import 'package:bookapp/homescreen.dart';
import 'package:bookapp/my_order.dart';
import 'package:flutter/material.dart';

class mynavigation extends StatefulWidget {
  const mynavigation({super.key});

  @override
  State<mynavigation> createState() => _mynavigationState();
}

class _mynavigationState extends State<mynavigation> {
  int _selectedindex = 0;

  List<Map<String, dynamic>> favoriteProducts = [];

  void toggleFavorite(Map<String, dynamic> product) {
    setState(() {
      if (favoriteProducts.any((item) => item['id'] == product['id'])) {
        favoriteProducts.removeWhere((item) => item['id'] == product['id']);
      } else {
        favoriteProducts.add(product);
      }
    });
  }

  List<Widget> get _screens => [
    myhomescreen(
      favoriteProducts: favoriteProducts,
      toggleFavorite: toggleFavorite,
    ),
     FavoriteScreen(
    favoriteProducts: favoriteProducts,
    removeFromFavorites: (product) {
      setState(() {
        favoriteProducts.removeWhere((p) => p['id'] == product['id']);
      });
    },
  ),
    MyOrdersScreen(),
  ];

  void onitemtapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedindex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            backgroundColor: Colors.deepPurple[500],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedindex,
            onTap: onitemtapped,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
            selectedFontSize: 14,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_rounded),
                label: 'My Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

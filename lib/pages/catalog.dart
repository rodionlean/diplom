import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_login_page/pages/item.dart';
import 'package:web_login_page/pages/search.dart';

import '../database_manager.dart';
import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';
import 'cart.dart';

class CatalogPage extends StatefulWidget {
  static const String route = '/catalog';

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final myController = TextEditingController();
  double _scrollPosition = 0;
  double _opacity = 0;
  List myProducts = [];
  List itemImageSize = [200, 200]; // default for large screens

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      itemImageSize = [99, 99];
    }
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: ResponsiveWidget.isSmallScreen(context)
          ? AppBar(
              backgroundColor: Color.fromARGB(255, 107, 193, 232),
              elevation: 0,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()));
                    },
                    child: Text(
                      'Leather product shop',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  SizedBox(width: 70),
                  SizedBox(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CartPage(cart.cartItems)));
                      },
                      child: Icon(Icons.shopping_cart, size: 35, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: Size(screenSize.width, 1000),
              child: TopAppBar(_opacity),
            ),
      drawer: Drawers(),
      body: FutureBuilder(
        future: FireStoreDatabase().getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            myProducts = snapshot.data as List;
            return buildGrid(myProducts);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildGrid(List myProducts) => GridView.builder(
      padding: ResponsiveWidget.isSmallScreen(context)
          ? const EdgeInsets.all(60)
          : const EdgeInsets.all(120),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: myProducts.length,
      itemBuilder: (BuildContext ctx, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ItemPage(int.tryParse(myProducts[index]['id'])!)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    "images/${myProducts[index]["url"]}.png",
                    height: itemImageSize[0].toDouble(),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myProducts[index]["name"],
                        style: TextStyle(
                          fontSize: ResponsiveWidget.isSmallScreen(context)
                              ? 14
                              : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        myProducts[index]["type"],
                        style: TextStyle(
                          fontSize: ResponsiveWidget.isSmallScreen(context)
                              ? 12
                              : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${myProducts[index]["price"]}',
                            style: TextStyle(
                              fontSize: ResponsiveWidget.isSmallScreen(context)
                                  ? 14
                                  : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser !=
                                  null) {
                                // Пользователь авторизован, добавляем товар в корзину
                                cart.addValue(myProducts[index]['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Item added to cart'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                // Пользователь не авторизован, показываем Snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'You need to sign in to add items to cart.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // Background color
                              foregroundColor:
                                  Colors.white, // Text color
                              padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveWidget.isSmallScreen(
                                          context)
                                      ? 10
                                      : 20,
                                  vertical: ResponsiveWidget.isSmallScreen(
                                          context)
                                      ? 5
                                      : 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

}

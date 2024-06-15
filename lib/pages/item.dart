import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_login_page/pages/search.dart';

import '../database_manager.dart';
import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';
import 'cart.dart';

class ItemPage extends StatefulWidget {
  static const String route = '/item/';

  final int productId;

  ItemPage(this.productId);

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final myController = TextEditingController();

  double _scrollPosition = 0;
  double _opacity = 0;
  List myItems = [];
  List itemImageSize = [500, 500]; // default for large screens

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      itemImageSize = [250, 250];
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
              backgroundColor: Colors.lightBlue,
              elevation: 0,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
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
                  SizedBox(
                    width: 70,
                  ),
                  SizedBox(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartPage(cart.cartItems)));
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
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error loading data");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            myItems = snapshot.data as List;
            int ind = findId(widget.productId, myItems);
            return buildItem(myItems, ind);
          }
          return Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  //
  Widget buildItem(List myItems, int ind) => Padding(
  padding: ResponsiveWidget.isSmallScreen(context) ? EdgeInsets.symmetric(vertical: 80, horizontal: 20) : EdgeInsets.symmetric(vertical: 120, horizontal: 40),
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  "images/" + myItems[ind]["url"] + ".png",
                  height: itemImageSize[0],
                  width: itemImageSize[1],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myItems[ind]["name"],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    myItems[ind]["type"],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Price: \$ ${myItems[ind]["price"]}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        // User is authenticated, add item to cart
                        cart.addValue(myItems[ind]['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item added to cart'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // User is not authenticated, show Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You need to sign in to add items to cart.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          "Description:",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          myItems[ind]["dscr"],
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    ),
  ),
);


  int findId(int productId, List products) {
    for (int i = 0; i < products.length; i++) {
      if (products[i]['id'] != null &&
          int.tryParse(products[i]['id']) == productId) {
        return i;
      }
    }
    return 0;
  }
}

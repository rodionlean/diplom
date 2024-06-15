import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_login_page/pages/cart.dart';
import 'package:web_login_page/pages/item.dart';

import '../database_manager.dart';
import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';

String searchStr = '';

class SearchPage extends StatefulWidget {
  static const String route = '/search';

  SearchPage(String str) {
    searchStr = str;
  }

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController();
  double _scrollPosition = 0;
  double _opacity = 0;
  List myItems = [];
  List matchItems = [];

  @override
  Widget build(BuildContext context) {
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
              myItems = snapshot.data as List;
              return buildSearch(myItems);
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget buildSearch(List items) {
    if (searchStr.isEmpty) {
      return Center(
        child: Text(
          'Please enter something',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      );
    }

    findMatch(items, searchStr.toLowerCase());

    if (matchItems.isEmpty) {
      return Center(
        child: Text(
          'Nothing found..',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        itemCount: matchItems.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ItemPage(int.tryParse(matchItems[index]['id'])!)));
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage(
                        "images/" + matchItems[index]["url"] + ".png"),
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matchItems[index]["name"],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          matchItems[index]["type"],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          matchItems[index]["dscr"],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + matchItems[index]["price"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser != null) {
                            // User is authenticated, add item to cart
                            cart.addValue(matchItems[index]['id']);
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
                        child: Text("Add to cart"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void findMatch(List items, String keyword) {
    matchItems.clear();
    for (int i = 0; i < items.length; i++) {
      Map<String, dynamic> item = items[i] as Map<String, dynamic>;
      if (item.containsKey('dscr') &&
          item['dscr'].toString().toLowerCase().contains(keyword)) {
        matchItems.add(item);
      } else if (item.containsKey('type') &&
          item['type'].toString().toLowerCase().contains(keyword)) {
        matchItems.add(item);
      } else if (item.containsKey('name') &&
          item['name'].toString().toLowerCase().contains(keyword)) {
        matchItems.add(item);
      } else if (item.containsKey('color') &&
          item['color'].toString().toLowerCase().contains(keyword)) {
        matchItems.add(item);
      }
    }
  }
}

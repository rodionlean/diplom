import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_login_page/pages/search.dart';

import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';
import 'cart.dart';

class NewsPage extends StatefulWidget {
  static const String route = '/news';

  @override
  _NewsPage createState() => _NewsPage();
}

class _NewsPage extends State<NewsPage> {
  final myController = TextEditingController();
  double _scrollPosition = 0;
  double _opacity = 0;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('news').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No news available.'));
          }
          final newsItems = snapshot.data!.docs;

          return ListView.builder(
  padding: ResponsiveWidget.isSmallScreen(context)
      ? const EdgeInsets.all(58)
      : const EdgeInsets.all(100),
  itemCount: newsItems.length,
  itemBuilder: (context, index) {
    var newsItem = newsItems[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.get('title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              newsItem.get('content'),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                newsItem.get('date'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

        },
      ),
    );
  }
}

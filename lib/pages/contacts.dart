import 'package:flutter/material.dart';
import 'package:web_login_page/pages/search.dart';

import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';
import 'cart.dart';

class ContactsPage extends StatefulWidget {
  static const String route = '/contacts';

  @override
  _ContactsPage createState() => _ContactsPage();
}

class _ContactsPage extends State<ContactsPage> {
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
                      child: Icon(Icons.shopping_cart, size: 35, color: Colors.white),
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
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Text(
                'Contact information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Adress: st. Example, 123, City, Country',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Phone number: +1 (234) 567-890',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Email: example@shop.com',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Image.asset(
                  'images/mapENG.png', // Путь к изображению карты
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_login_page/database_manager.dart';
import 'package:web_login_page/responsive.dart';
import 'package:web_login_page/top_app_bar.dart';
import 'auth.dart';
import 'drawers.dart';
import 'pages/cart.dart';
import 'pages/search.dart';

/// UI of Home Page
class HomePage extends StatefulWidget {
  static const String route = '/homepage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();

  double _scrollPosition = 0;
  double _opacity = 0;
  /// Define variables of grid list items
  List myProducts = [];

  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    /// Define variables to control with size of parent widget
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    /// We have to make changes in two places for integrating the AuthDialog widget: in the top bar (for large screens) and the drawer (for small screens).
    return Scaffold(
      backgroundColor: Colors.white,//Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,

      /// Call of Responsive Widget
      appBar: ResponsiveWidget.isSmallScreen(context)
          ? AppBar(
              backgroundColor:
                  Color.fromARGB(255, 107, 193, 232),//Theme.of(context).cardColor.withOpacity(_opacity),
              elevation: 0,
              centerTitle: true,
              title:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              InkWell(
                onTap:() {Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));} ,
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
              SizedBox(width: 70,),
              SizedBox(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(cart.cartItems)));
                  },
                  child: Icon(Icons.shopping_cart, size: 35, color: Colors.white),
                ),
              ),
                ]
          ),
            )
          : PreferredSize(
              preferredSize: Size(screenSize.width, 1000),

              /// Call of TopAppBar Widget
              child: TopAppBar(_opacity),
            ),

      drawer: Drawers(),
      body: Center(
/// to show home page if user log in or not
        child: currentUser == null
            ? Container(
                child: Text(
                  'Welcome guest',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Container(
              child: Text(
                'Welcome ${currentUser?.displayName==null ? currentUser?.email : currentUser?.displayName}', style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
              )
            )
      )
    );
  }

  /*Widget buildItems(dataList) => ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: dataList.length,
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        title: Text(
          dataList[index]["name"],
        ),
        subtitle: Text(dataList[index]["type"]),
        trailing: Text(dataList[index]["price"]),
      );
    });*/
}

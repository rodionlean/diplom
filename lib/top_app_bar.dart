import 'package:flutter/material.dart';
import 'package:web_login_page/auth.dart';
import 'package:web_login_page/dialog_auth.dart';
import 'package:web_login_page/home_page.dart';
import 'package:web_login_page/pages/admin.dart';
import 'package:web_login_page/pages/cart.dart';
import 'package:web_login_page/pages/catalog.dart';
import 'package:web_login_page/pages/contacts.dart';
import 'package:web_login_page/pages/news.dart';
import 'package:web_login_page/pages/search.dart';

class TopAppBar extends StatefulWidget {
  final double opacity;

  TopAppBar(this.opacity);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  bool _isProcessing = false;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Color.fromARGB(255, 107, 193, 232),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
              SizedBox(width: 30),
              FutureBuilder<String?>(
                future: getCurrentUserUid(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    String? uid = snapshot.data;
                    if (uid != null) {
                      return FutureBuilder<bool>(
                        future: isAdmin(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            bool isAdmin = snapshot.data ?? false;
                            if (isAdmin) {
                              return ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text('Admin Panel'),
                              );
                            } else {
                              return SizedBox();
                            }
                          } else {
                            return SizedBox();
                          }
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  } else {
                    return SizedBox();
                  }
                },
              ),
              Spacer(),
              Row(
                children: [
                  _buildAppBarItem('Catalog', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CatalogPage()));
                  }),
                  SizedBox(width: screenSize.width / 20),
                  _buildAppBarItem('News', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
                  }),
                  SizedBox(width: screenSize.width / 20),
                  _buildAppBarItem('Contacts', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsPage()));
                  }),
                  SizedBox(width: screenSize.width / 20),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a search item',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: Color.fromARGB(255, 107, 193, 232),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(myController.text)));
                    },
                    child: Icon(Icons.search),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(cart.cartItems)));
                    },
                    child: Icon(Icons.shopping_cart, size: 50, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  _buildSignInSignOutButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarItem(String title, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildSignInSignOutButton() {
    return InkWell(
      onTap: userEmail == null
          ? () {
              showDialog(
                context: context,
                builder: (context) => AuthDialog(),
              );
            }
          : null,
      child: userEmail == null
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? Icon(Icons.account_circle, size: 30) : null,
                ),
                SizedBox(width: 5),
                Text(
                  name ?? userEmail!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          setState(() {
                            _isProcessing = true;
                          });
                          await signOut().then((result) {
                            print(result);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => HomePage(),
                              ),
                            );
                          }).catchError((error) {
                            print('Sign Out Error: $error');
                          });
                          setState(() {
                            _isProcessing = false;
                          });
                        },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: _isProcessing
                        ? CircularProgressIndicator()
                        : Text(
                            'Sign out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

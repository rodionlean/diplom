import 'package:flutter/material.dart';
import 'package:web_login_page/auth.dart';
import 'package:web_login_page/dialog_auth.dart';
import 'package:web_login_page/home_page.dart';
import 'package:web_login_page/pages/cart.dart';
import 'package:web_login_page/pages/catalog.dart';
import 'package:web_login_page/pages/contacts.dart';
import 'package:web_login_page/pages/news.dart';
import 'package:web_login_page/pages/search.dart';

class Drawers extends StatefulWidget {
  const Drawers({Key? key}) : super(key: key);

  @override
  _DrawersState createState() => _DrawersState();
}

class _DrawersState extends State<Drawers> {
  bool _isProcessing = false;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromARGB(255, 107, 193, 232),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (userEmail == null)
                _buildSignInButton()
              else
                _buildUserDetails(),
              SizedBox(height: 20),
              _buildSearchRow(),
              SizedBox(height: 30),
              _buildDrawerItem('Catalog', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CatalogPage()));
              }),
              _buildDivider(),
              _buildDrawerItem('News', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
              }),
              _buildDivider(),
              _buildDrawerItem('Contacts', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsPage()));
              }),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'AVDEYEVICH',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.maxFinite,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AuthDialog(),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            'Sign in',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null ? Icon(Icons.account_circle, size: 40) : null,
        ),
        SizedBox(width: 10),
        Text(
          name ?? userEmail!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search item',
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        FloatingActionButton(
          backgroundColor: Colors.grey.shade50,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(myController.text)));
          },
          child: Icon(Icons.search, color: Colors.lightBlue),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(String title, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Divider(
        color: Colors.blueGrey[400],
        thickness: 2,
      ),
    );
  }
}

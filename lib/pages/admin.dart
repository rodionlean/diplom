import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth.dart';
import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';
import 'cart.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  //item controllers
  final TextEditingController colorController = TextEditingController();
  final TextEditingController dscrController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  //news controllers
  final TextEditingController newsTitleController = TextEditingController();
  final TextEditingController newsContentController = TextEditingController();
  final TextEditingController newsDateController = TextEditingController();

  double _scrollPosition = 0;
  double _opacity = 0;

  int totalProducts = 0;

  @override
  void initState() {
    super.initState();
    // Вызываем метод для получения общего количества продуктов
    getTotalProductCount();
  }

  Future<void> getTotalProductCount() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        totalProducts = querySnapshot.size;
      });
    } catch (e) {
      print('Error getting total product count: $e');
      // Обработка ошибки при получении данных
    }
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(120.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Items',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: dscrController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'Type',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: 'URL',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
    if (colorController.text.isEmpty ||
        dscrController.text.isEmpty ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        typeController.text.isEmpty ||
        urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all ITEM fields.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      addProduct();
    }
  },
                      child: Text('Add Item'),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Delete Item',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Виджет для вывода списка товаров и удаления
                    ProductsList(),
                  ],
                ),
              ),
              SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage News',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: newsTitleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: newsContentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: newsDateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (newsTitleController.text.isEmpty || newsContentController.text.isEmpty || newsDateController.text.isEmpty) {
                          // Показываем Snackbar, если хотя бы одно поле пустое
                          ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                           content: Text('Please fill in all NEWS fields'),
                           duration: Duration(seconds: 2),
                           ),
                          );
                        } else { addNews(); }
                      },
                      child: Text('Add News'),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Delete News',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    NewsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  Future<void> addProduct() async {
  try {
    // Fetch the maximum id currently in use
    var querySnapshot = await FirebaseFirestore.instance.collection('products').orderBy('id', descending: true).limit(1).get();
    int maxId = 0;
    if (querySnapshot.docs.isNotEmpty) {
      maxId = int.parse(querySnapshot.docs.first.get('id'));
    }

    // Calculate the next id
    int nextId = maxId + 1;

    // Add the product with the calculated id
    await FirebaseFirestore.instance.collection('products').add({
      'color': colorController.text,
      'dscr': dscrController.text,
      'name': nameController.text,
      'price': priceController.text,
      'type': typeController.text,
      'url': urlController.text,
      'id': nextId.toString(),
    });

    // Clear fields after successful addition
    colorController.clear();
    dscrController.clear();
    nameController.clear();
    priceController.clear();
    typeController.clear();
    urlController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product added successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    print('Error adding product: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to add product'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  Future<void> addNews() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!['role'] == 'admin') {
          await FirebaseFirestore.instance.collection('news').add({
            'title':  newsTitleController.text,
            'content': newsContentController.text,
            'date': newsDateController.text,
          });
          // Clear fields after successful addition
          newsTitleController.clear();
          newsContentController.clear();
          newsDateController.clear();
        } else {
          throw Exception('User is not an admin');
        }
      } else {
        throw Exception('User is not authenticated');
      }
    } catch (e) {
      // Show a SnackBar when an exception occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add news: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

//
class ProductsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: documents.length,
          itemBuilder: (context, index) {
            String color = documents[index].get('color');
            String dscr = documents[index].get('dscr');
            String name = documents[index].get('name');
            String price = documents[index].get('price');
            String type = documents[index].get('type');
            String url = documents[index].get('url');
            return ListTile(
              title: Text(name),
              subtitle: Text(dscr),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Are you sure you want to delete this product?"),
                            SizedBox(height: 10),
                            Text("Name: $name"),
                            //Text("Description: $dscr"),
                            Text("Color: $color"),
                            Text("Price: $price"),
                            Text("Type: $type"),
                            Text("URL: $url"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Delete"),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(documents[index].id)
                                  .delete();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}


//
class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('news').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: documents.length,
          itemBuilder: (context, index) {
            String title = documents[index].get('title');
            String content = documents[index].get('content');
            return ListTile(
              title: Text(title),
              subtitle: Text(content),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Are you sure you want to delete this news item?"),
                            SizedBox(height: 10),
                            Text("Title: $title"),
                            Text("Content: $content"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Delete"),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('news')
                                  .doc(documents[index].id)
                                  .delete();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}



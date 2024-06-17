import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web_login_page/pages/item.dart';
import 'package:web_login_page/pages/search.dart';

import '../database_manager.dart';
import '../drawers.dart';
import '../home_page.dart';
import '../responsive.dart';
import '../top_app_bar.dart';

class Cart {
  Map<String, int> cartItems = {};

  Future<void> addValue(String value) async {
    if (!cartItems.containsKey(value)) {
      cartItems[value] = 1;
    } else {
      cartItems[value] = cartItems[value]! + 1;
    }
    await saveCartItems();
  }

  Future<void> removeValue(String value) async {
    if (cartItems.containsKey(value) && cartItems[value]! > 1) {
      cartItems[value] = cartItems[value]! - 1;
    } else {
      cartItems.remove(value);
    }
    await saveCartItems();
  }

  Future<void> clearCart() async {
    cartItems.clear();
    await saveCartItems();
  }

  Future<void> loadCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('carts').doc(user.uid).get();
      if (doc.exists) {
        cartItems = Map<String, int>.from(doc.data()!['cartItems']);
      }
    }
  }

  Future<void> saveCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('carts').doc(user.uid).set({
        'cartItems': cartItems,
      });
    }
  }

  Future<void> printCartItems(List<Map<String, dynamic>> allItems, Map<String, int> cartItems) async {
    final pdf = pw.Document();

    int totalQuantity = 0;
    int totalPrice = 0;
for (var cartItemKey in cartItems.keys) {
  final cartItemValue = cartItems[cartItemKey]!;
  totalQuantity += cartItemValue;

  final item = allItems.firstWhere(
    (element) => element['id'] == cartItemKey,
    orElse: () => {},
  );
  if (item != null) {
    int itemPrice = int.tryParse(item['price'].toString()) ?? 0;
    totalPrice += itemPrice * cartItemValue;
  }
}

    pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      List<pw.Widget> itemWidgets = [];

      // Iterate through cartItems
      for (var cartItemKey in cartItems.keys) {
        final cartItemValue = cartItems[cartItemKey];

        final item = allItems.firstWhere((element) => element['id'] == cartItemKey, orElse: () => {});

        if (item != null) {
          itemWidgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ID: $cartItemKey'),
                pw.SizedBox(height: 5), // Add space between items
                pw.Text('Quantity: $cartItemValue'),
                pw.SizedBox(height: 5), // Add space between items
                pw.Text('Name: ${item['name']}'),
                pw.SizedBox(height: 5), // Add space between items
                pw.Text('Type: ${item['type']}'),
                pw.SizedBox(height: 5), // Add space between items
                pw.Text('Color: ${item['color']}'),
                pw.SizedBox(height: 5), // Add space between items
                pw.Text('Price: \$${item['price']}'),
                pw.Divider(), // Add a divider between items
              ],
            ),
          );
        } else {
          itemWidgets.add(
            pw.Text('Item not found for ID: $cartItemKey'),
          );
        }
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Cart Items', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10), // Add space below 'Cart Items'
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: itemWidgets,
          ),
          pw.Divider(),
          pw.Text('Total Quantity: $totalQuantity', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      );
    },
  ),
);

    
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

Cart cart = Cart();

class CartPage extends StatefulWidget {
  static const String route = '/cart';

  CartPage(Map<String, int> list) {
    cart.cartItems = list;
  }

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final myController = TextEditingController();
  double _scrollPosition = 0;
  double _opacity = 0;
  List<Map<String, dynamic>> allItems = []; // Явное указание типа List<Map<String, dynamic>>

  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    await cart.loadCartItems();
    await FireStoreDatabase().getData().then((data) {
      setState(() {
        // Явное приведение типа List<dynamic> к List<Map<String, dynamic>>
        allItems = (data as List).cast<Map<String, dynamic>>();
        totalPrice = getTotalPrice();
      });
    });
  }

  double getTotalPrice() {
    double totalPrice = 0.0;
    cart.cartItems.forEach((itemId, count) {
      var itemData = allItems.firstWhere((item) => item['id'] == itemId, orElse: () => {});
      if (itemData != null) {
        double itemPrice = double.tryParse(itemData["price"].toString()) ?? 0.0; // Use null-aware operator and provide default value
        totalPrice += itemPrice * count;
      }
    });
    return totalPrice;
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
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 107, 193, 232),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total items: ${getTotalItemCount()}',
                style: TextStyle(color: Colors.black, fontSize: ResponsiveWidget.isSmallScreen(context) ? 11 : 18),
              ),
              Text(
                'Total price: \$ ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.black, fontSize: ResponsiveWidget.isSmallScreen(context) ? 11 : 18),
              ),
              ElevatedButton(
                onPressed: () {
                  cart.clearCart();
                  setState(() {
                    totalPrice = 0.0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Clear cart', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                child: Text('Print cart', style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  await cart.printCartItems(allItems, cart.cartItems);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                                      ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawers(),
      body: FutureBuilder(
        future: FireStoreDatabase().getData(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // Явное приведение типа List<dynamic> к List<Map<String, dynamic>>
            allItems = (snapshot.data as List).cast<Map<String, dynamic>>();
            return buildItem(allItems);
          }
          return const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  int getTotalItemCount() {
    return cart.cartItems.values.fold(0, (sum, count) => sum + count);
  }

  void updateItemCount(String itemId, int change) async {
    String message;
    if (change > 0) {
      await cart.addValue(itemId);
      message = 'Item added to cart';
    } else {
      await cart.removeValue(itemId);
      message = 'Item removed from cart';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
    setState(() {
      totalPrice = getTotalPrice();
    });
  }

  Widget buildItem(List<Map<String, dynamic>> allItems) {
    Map<String, int> matchItems = cart.cartItems;

    return matchItems.isEmpty
        ? Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 24),
            ),
          )
        : ListView.builder(
            padding: ResponsiveWidget.isSmallScreen(context) ? const EdgeInsets.all(58) : const EdgeInsets.all(100),
            itemCount: matchItems.length,
            itemBuilder: (BuildContext context, int index) {
              String itemId = matchItems.keys.elementAt(index);
              int itemCount = matchItems[itemId]!;
              var itemData = allItems.firstWhere((item) => item['id'] == itemId, orElse: () => {});
              if (itemData == null) {
                return SizedBox.shrink(); // Return an empty widget if itemData is null
              }
              double itemPrice = double.tryParse(itemData["price"].toString()) ?? 0.0;
              double totalItemPrice = itemPrice * itemCount;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemPage(int.parse(itemData['id'].toString())),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left part - image
                        Image.asset(
                          "images/" + itemData["url"] + ".png",
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column with name, type, and price
                              Text(
                                itemData["name"] ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                itemData["type"] ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '\$ ${itemData["price"] ?? '0.0'}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      updateItemCount(itemId, -1);
                                    },
                                  ),
                                  Text(
                                    '$itemCount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      updateItemCount(itemId, 1);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Total: \$ ${totalItemPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        // Right part - column with item description
                        ResponsiveWidget.isSmallScreen(context) 
                        ? SizedBox()
                        : Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                itemData["dscr"] ?? '',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}


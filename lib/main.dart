import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_login_page/pages/catalog.dart';
import 'package:web_login_page/pages/search.dart';

import 'auth.dart';
import 'home_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase

  await Firebase.initializeApp(
    // Replace with your actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyCnJpn8mU9odl8pl-jDmpgbYfWkHPRnRN0",
        authDomain: "fir-flutter-web-1f060.firebaseapp.com",
        databaseURL: "https://fir-flutter-web-1f060-default-rtdb.firebaseio.com",
        projectId: "fir-flutter-web-1f060",
        storageBucket: "fir-flutter-web-1f060.appspot.com",
        messagingSenderId: "56034006003",
        appId: "1:56034006003:web:746fc013b7c60e5d6df886",
        measurementId: "G-THY0J94NF3"
    ),
  );
  runApp(MyApp());
}

/// We Modify the MyApp to a StatefulWidget.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// To define a method called getUserInfo to invoke the getUser function:
  Future getUserInfo() async {
    await getUser();
    setState(() {});
    print(uid);
  }

  @override
  void initState() {
    /// To Call it from the initState method
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leather product shop',
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      /// for navigate to Home page
      home: HomePage(),
    );
  }
}

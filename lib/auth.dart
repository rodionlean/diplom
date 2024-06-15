import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'pages/cart.dart';

/// Create an instance of GoogleSignIn, and add a few more variables:
final GoogleSignIn googleSignIn = GoogleSignIn();
String? userEmail;
String? imageUrl;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String?> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

/// Define a new function called signInWithGoogle, which we will use to handle the Google Sign-In process:
Future<User?> signInWithGoogle() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  User? user;

  if (kIsWeb) {
    // The `GoogleAuthProvider` can only be used while running on the web
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential =
          await _auth.signInWithPopup(authProvider);

      user = userCredential.user;
    } catch (e) {
      print(e);
    }
  } else {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print('The account already exists with a different credential.');
        } else if (e.code == 'invalid-credential') {
          print('Error occurred while accessing credentials. Try again.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  if (user != null) {
    uid = user.uid;
    name = user.displayName;
    userEmail = user.email;
    imageUrl = user.photoURL;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', true);
  }

  return user;
}

/// For sign out of their Google account
void signOutGoogle() async {
  await googleSignIn.signOut();
  await _auth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  name = null;
  userEmail = null;
  imageUrl = null;
  cart.clearCart();

  print("User signed out of Google account");
}

/// Create an instance of FirebaseAuth, and add a few more variables:
final FirebaseAuth _auth = FirebaseAuth.instance;

String? uid;
String? name;

/// Authenticating using email and password

/// We will define a new function called registerWithEmailPassword that will handle the whole process of registering a new user.
/// This function will contain two parameters, an email and a password, which will be used to authenticate the user.
Future<User?> registerWithEmailPassword(String email, String password, String role) async {
  await Firebase.initializeApp();
  User? user;

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    user = userCredential.user;

    if (user != null) {
      uid = user.uid;
      userEmail = user.email;

      // Сохранение роли и почты пользователя в документе с UID
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
      });

      // Создание документа в коллекции carts с UID пользователя
      await _firestore.collection('carts').doc(user.uid).set({
        'cartItems': {},
      });
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }

  return user;
}

/// After a user is successfully registered, they can log in using their correct credentials.
/// You can use the method signInWithEmailAndPassword provided by FirebaseAuth to authenticate the login process.
/// We will define another function called signInWithEmailPassword for handling the login process.

Future<User?> signInWithEmailPassword(String email, String password) async {
  await Firebase.initializeApp();
  User? user;

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential.user;

    if (user != null) {
      uid = user.uid;
      userEmail = user.email;

      // Получение роли пользователя
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String role = userDoc['role'];

      // Кеширование роли пользователя
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);
      await prefs.setString('role', role);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided.');
    }
  }

  return user;
}

/// Let’s also define a handy function for signing out of an account.
Future<String> signOut() async {
  await _auth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  userEmail = null;
  cart.clearCart();

  return 'User signed out';
}

/// In order to prevent users from having to log in every time they come back to your web app or reload the web page, you can cache their login status and auto-login when they come back to your web app.

/// Define a new function called getUser to retrieve the user’s information if they have already logged in previously:
Future getUser() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool authSignedIn = prefs.getBool('auth') ?? false;

  final User? user = _auth.currentUser;

  if (authSignedIn == true) {
    if (user != null) {
      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;
    }
  }
}

Future<String?> getCurrentUserUid() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    // Если пользователь не аутентифицирован, вернуть null или выполнить дополнительные действия
    return null;
  }
}

Future<bool> isAdmin(String uid) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      String role = userDoc.get('role');
      return role == 'admin';
    } else {
      // В случае если документ не существует (что маловероятно для зарегистрированного пользователя)
      return false;
    }
  } catch (e) {
    print('Error checking admin role: $e');
    return false; // В случае ошибки также возвращаем false
  }
}

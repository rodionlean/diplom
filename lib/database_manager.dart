import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FireStoreDatabase{
  List itemsList = [];
  final CollectionReference collectionRef = FirebaseFirestore.instance.collection("products");

  Future getData() async{
    try{

      // to get data from single/particular document alone
      // var temp = await collectionRef.doc("INPUT_YOUR_DOCUMENT_ID").get();

      // to get data from all docs
      await collectionRef.get().then((querySnapshot){
        for(var result in querySnapshot.docs){
          itemsList.add(result.data());
        }
      });

      return itemsList;
    } catch(e){
      debugPrint("Error - $e");
      return null;
    }
  }
}
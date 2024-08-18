// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getEmployeeData(String nip) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('employees')
        .doc(nip)
        .get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>?;
    } else {
      print('No such document!');
      return null;
    }
  } catch (e) {
    print('Error getting document: $e');
    return null;
  }
}

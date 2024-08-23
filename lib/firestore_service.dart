import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getEmployeeData(String employeeId) async {
  if (employeeId.isEmpty) {
    throw ArgumentError('Employee ID cannot be empty');
  }
  
  try {
    final document = await FirebaseFirestore.instance.collection('employees').doc(employeeId).get();
    if (document.exists) {
      return document.data();
    } else {
      throw Exception('Document does not exist');
    }
  } catch (e) {
    print('Error getting document: $e');
    return null;
  }
}

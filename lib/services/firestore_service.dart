import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();
  // ===============================
  // Users Collection
  // ===============================

  final CollectionReference<Map<String, dynamic>> usersRef =
  FirebaseFirestore.instance.collection('users');

  Future<void> addUser(AppUser user) async {
    await usersRef.doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(AppUser user) async {
    await usersRef.doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await usersRef.doc(id).delete();
  }

  Future<AppUser?> getUser(String id) async {
    final doc = await usersRef.doc(id).get();

    if (!doc.exists) return null;

    return AppUser.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  Stream<List<AppUser>> getUsers() {
    return usersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}
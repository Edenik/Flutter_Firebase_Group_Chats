import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/models/user_model.dart';
import 'package:firebase_chat/utilities/constants.dart';

class DatabaseService {
  Future<User> getUser(String userId) async {
    DocumentSnapshot userDoc = await usersRef.document(userId).get();
    return User.fromDoc(userDoc);
  }

  Future<List<User>> searchUsers(String currentUserId, String name) async {
    QuerySnapshot usersSnap = await usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments();

    List<User> users = [];
    usersSnap.documents.forEach((doc) {
      User user = User.fromDoc(doc);
      if (user.id != currentUserId) {
        users.add(user);
      }
    });
    return users;
  }
}

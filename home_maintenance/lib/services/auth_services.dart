import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up method
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String contact,
    required String userType,
  }) async {
    try {
      // Check if email already exists in Firestore
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        // Email already exists
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        );
      }
     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;

      if (user != null) {
        // Add user details to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'contact': contact,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in method
  // Future<User?> signIn(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>> signInAndGetRole(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = result.user;
    if (user != null) {
      // Fetch the user's role from Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String userType = userData['userType'] ?? 'user'; 
      return {'user': user, 'userType': userType};
    }
  } catch (e) {
    print(e.toString());
  }
  return {'user': null, 'userType': null};
}

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream to listen to auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();
}
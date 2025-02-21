import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Initialize with current user if exists
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      _fetchUserData();
    }

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData() async {
    if (_firebaseUser == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
        notifyListeners();
      } else {
        // If document doesn't exist but user is authenticated,
        // create a new user document
        final newUser = UserModel(
          uid: _firebaseUser!.uid,
          email: _firebaseUser!.email!,
          name: _firebaseUser!.displayName ?? '',
          photoUrl: _firebaseUser!.photoURL,
          role: 'user',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(_firebaseUser!.uid)
            .set(newUser.toMap());

        _user = newUser;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'Sign in was canceled by the user',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create new user document if it doesn't exist
          final newUser = UserModel(
            uid: user.uid,
            email: user.email!,
            name: user.displayName ?? '',
            photoUrl: user.photoURL,
            role: 'user',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());

          _user = newUser;
        } else {
          // Update last login for existing user
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'lastLogin': DateTime.now().toIso8601String()});
          
          _user = UserModel.fromMap(userDoc.data()!);
        }

        notifyListeners();
        return _user;
      }

      throw FirebaseAuthException(
        code: 'sign_in_failed',
        message: 'Failed to sign in with Google',
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      
      _user = null;
      _firebaseUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_firebaseUser == null || _user == null) return;

      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update(data);

      _user = UserModel.fromMap({
        ..._user!.toMap(),
        ...data,
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }
} 
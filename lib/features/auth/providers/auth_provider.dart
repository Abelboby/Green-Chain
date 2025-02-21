import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> _fetchUserData() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final docSnapshot = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (docSnapshot.exists) {
        _userData = docSnapshot.data();
      } else {
        // Create user document if it doesn't exist
        final userData = {
          'name': _user!.displayName ?? 'Anonymous',
          'email': _user!.email,
          'photoURL': _user!.photoURL,
          'walletAddress': null, // Will be set when user connects wallet
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .set(userData);
        _userData = userData;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? walletAddress,
    String? photoURL,
  }) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        if (name != null) 'name': name,
        if (walletAddress != null) 'walletAddress': walletAddress,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update(updates);

      _userData = {...?_userData, ...updates};
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      _userData = {...?_userData, ...data};
    } catch (e) {
      debugPrint('Error updating user data: $e');
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
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
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

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Create or update user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'notifications': {
            'report_updates': true,
            'verification_status': true,
            'rewards': true,
            'community_updates': false,
            'tips_and_news': false,
          },
        }, SetOptions(merge: true));

        await _fetchUserData();
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? bio,
  }) async {
    if (_user == null) throw Exception('No user logged in');

    try {
      _isLoading = true;
      notifyListeners();

      // Update Firebase Auth display name
      await _user!.updateDisplayName(displayName);

      // Update Firestore user document
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': displayName,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _fetchUserData();
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

      await _googleSignIn.signOut();
      await _auth.signOut();
      _userData = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    if (_user == null) throw Exception('No user logged in');

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(_user!.uid).update({
        'notifications': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _fetchUserData();
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
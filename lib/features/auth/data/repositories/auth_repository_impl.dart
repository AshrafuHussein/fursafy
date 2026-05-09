import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth? _injectedFirebaseAuth;
  final FirebaseFirestore? _injectedFirestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _injectedFirebaseAuth = firebaseAuth,
        _injectedFirestore = firestore;

  FirebaseAuth get _firebaseAuth {
    try {
      return _injectedFirebaseAuth ?? FirebaseAuth.instance;
    } catch (_) {
      throw Exception('Firebase is not initialized. Please configure Firebase.');
    }
  }

  FirebaseFirestore get _firestore {
    try {
      return _injectedFirestore ?? FirebaseFirestore.instance;
    } catch (_) {
      throw Exception('Firebase is not initialized.');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;
      return UserEntity.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        try {
          final doc = await _firestore
              .collection(FirestorePaths.users)
              .doc(firebaseUser.uid)
              .get();
          if (!doc.exists) return null;
          return UserEntity.fromMap(doc.data()!);
        } catch (_) {
          return null;
        }
      });
    } catch (_) {
      return Stream.value(null);
    }
  }


  @override
  Future<({UserEntity user, Failure? failure})> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final doc =
          await _firestore.collection(FirestorePaths.users).doc(uid).get();

      if (!doc.exists) {
        return (
          user: UserEntity(
            uid: uid,
            email: email,
            displayName: '',
            role: UserRole.youth,
            createdAt: DateTime.now(),
          ),
          failure: null
        );
      }
      return (user: UserEntity.fromMap(doc.data()!), failure: null);
    } on FirebaseAuthException catch (e) {
      return (
        user: UserEntity(
          uid: '',
          email: email,
          displayName: '',
          role: UserRole.youth,
          createdAt: DateTime.now(),
        ),
        failure: AuthFailure.fromFirebaseCode(e.code),
      );
    } catch (e) {
      return (
        user: UserEntity(
          uid: '',
          email: email,
          displayName: '',
          role: UserRole.youth,
          createdAt: DateTime.now(),
        ),
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({UserEntity user, Failure? failure})> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final user = UserEntity(
        uid: uid,
        email: email.trim(),
        phone: phone,
        displayName: displayName.trim(),
        role: UserRole.fromString(role),
        status: AccountStatus.active,
        createdAt: DateTime.now(),
      );

      // Write user document to Firestore
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .set(user.toMap());

      return (user: user, failure: null);
    } on FirebaseAuthException catch (e) {
      return (
        user: UserEntity(
          uid: '',
          email: email,
          displayName: displayName,
          role: UserRole.fromString(role),
          createdAt: DateTime.now(),
        ),
        failure: AuthFailure.fromFirebaseCode(e.code),
      );
    } catch (e) {
      return (
        user: UserEntity(
          uid: '',
          email: email,
          displayName: displayName,
          role: UserRole.fromString(role),
          createdAt: DateTime.now(),
        ),
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Failure?> sendPhoneOtp({required String phoneNumber}) async {
    // Phone auth will be implemented with verifyPhoneNumber
    // For now, return null (success placeholder)
    return null;
  }

  @override
  Future<Failure?> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure.fromFirebaseCode(e.code);
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure.fromFirebaseCode(e.code);
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> createYouthProfile({
    required String uid,
    required List<String> skills,
    required double latitude,
    required double longitude,
    String? bio,
  }) async {
    try {
      final profile = YouthProfile(
        uid: uid,
        skills: skills,
        location: GeoPoint(latitude, longitude),
        bio: bio,
      );
      await _firestore
          .collection(FirestorePaths.youthProfiles)
          .doc(uid)
          .set(profile.toMap());
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        'fcmToken': token,
      });
    } catch (_) {
      // Silently fail — FCM token update is non-critical
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

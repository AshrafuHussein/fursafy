import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/features/profile/domain/repositories/profile_repository.dart';

/// Firestore implementation of [ProfileRepository].
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  ProfileRepositoryImpl({FirebaseFirestore? db, FirebaseStorage? storage})
      : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<({UserEntity? user, Failure? failure})> getUserProfile(
      String uid) async {
    try {
      final doc =
          await _db.collection(FirestorePaths.users).doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return (
          user: null,
          failure: const ServerFailure(message: 'User not found'),
        );
      }
      return (user: UserEntity.fromMap(doc.data()!), failure: null);
    } catch (e) {
      return (
        user: null,
        failure: ServerFailure(message: 'Failed to load profile: $e'),
      );
    }
  }

  @override
  Future<({YouthProfile? profile, Failure? failure})> getYouthProfile(
      String uid) async {
    try {
      final doc = await _db
          .collection(FirestorePaths.youthProfiles)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) {
        return (profile: null, failure: null);
      }
      final data = doc.data()!;
      data['uid'] = uid;
      return (profile: YouthProfile.fromMap(data), failure: null);
    } catch (e) {
      return (
        profile: null,
        failure: ServerFailure(message: 'Failed to load youth profile: $e'),
      );
    }
  }

  @override
  Future<Failure?> updateUserProfile(UserEntity user) async {
    try {
      await _db
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .update(user.toMap());
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<Failure?> updateYouthProfile(YouthProfile profile) async {
    try {
      await _db
          .collection(FirestorePaths.youthProfiles)
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to update youth profile: $e');
    }
  }

  @override
  Future<({String? url, Failure? failure})> uploadAvatar(
      String uid, String filePath) async {
    try {
      final ref = _storage.ref('avatars/$uid.jpg');
      final uploadTask = ref.putFile(
        File(filePath),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snap = await uploadTask;
      final url = await snap.ref.getDownloadURL();

      // Update user document with new avatar URL
      await _db
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'avatarUrl': url});

      return (url: url, failure: null);
    } catch (e) {
      return (
        url: null,
        failure: ServerFailure(message: 'Failed to upload avatar: $e'),
      );
    }
  }
}

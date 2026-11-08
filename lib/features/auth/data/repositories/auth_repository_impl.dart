import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/cach/shared_prefs.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromFirestore(doc.data()!, doc.id);
        await _saveLocalUser(user);
        return user;
      }
    } catch (_) {}

    final newUser = UserModel(
      id: uid,
      email: email,
      fullName: credential.user?.displayName ?? email.split('@').first,
      role: email.contains('manager') ? AppConstants.roleManager : AppConstants.roleEmployee,
      companyId: 'company_001',
      companyName: 'Workforce Pro Ltd.',
      departmentId: 'dept_001',
      departmentName: 'Operations',
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(uid).set(newUser.toFirestore());
    } catch (_) {}

    await _saveLocalUser(newUser);
    return newUser;
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? companyName,
    String? departmentId,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final newUser = UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      role: role,
      companyId: 'company_001',
      companyName: companyName ?? 'Workforce Pro Ltd.',
      departmentId: departmentId ?? 'dept_001',
      departmentName: 'Operations',
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(uid).set(newUser.toFirestore());
    } catch (_) {}

    await _saveLocalUser(newUser);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    await SharedPrefs.removeData(key: 'user_id');
    await SharedPrefs.removeData(key: 'user_email');
    await SharedPrefs.removeData(key: 'user_name');
    await SharedPrefs.removeData(key: 'user_role');
    await SharedPrefs.removeData(key: 'company_id');
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    final cachedUid = SharedPrefs.getData(key: 'user_id') as String?;

    if (currentUser == null && cachedUid == null) {
      return null;
    }

    final uid = currentUser?.uid ?? cachedUid!;

    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromFirestore(doc.data()!, doc.id);
        await _saveLocalUser(user);
        return user;
      }
    } catch (_) {}

    final email = currentUser?.email ?? (SharedPrefs.getData(key: 'user_email') as String? ?? 'user@workforce.com');
    final name = currentUser?.displayName ?? (SharedPrefs.getData(key: 'user_name') as String? ?? email.split('@').first);
    final role = SharedPrefs.getData(key: 'user_role') as String? ?? AppConstants.roleEmployee;
    final companyId = SharedPrefs.getData(key: 'company_id') as String? ?? 'company_001';

    return UserEntity(
      id: uid,
      email: email,
      fullName: name,
      role: role,
      companyId: companyId,
      companyName: 'Workforce Pro Ltd.',
    );
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(user.id).update(model.toFirestore());
    } catch (_) {}
    await _saveLocalUser(model);
  }

  Future<void> _saveLocalUser(UserModel user) async {
    await SharedPrefs.saveData(key: 'user_id', value: user.id);
    await SharedPrefs.saveData(key: 'user_email', value: user.email);
    await SharedPrefs.saveData(key: 'user_name', value: user.fullName);
    await SharedPrefs.saveData(key: 'user_role', value: user.role);
    if (user.companyId != null) {
      await SharedPrefs.saveData(key: 'company_id', value: user.companyId!);
    }
  }
}

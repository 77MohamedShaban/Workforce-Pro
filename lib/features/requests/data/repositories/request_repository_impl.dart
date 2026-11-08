import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirebaseFirestore _firestore;

  RequestRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<RequestEntity>> getRequestsForEmployee(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionRequests)
          .where('employeeId', isEqualTo: employeeId)
          .get();

      final list = snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<RequestEntity>> getAllRequestsForCompany(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionRequests)
          .where('companyId', isEqualTo: companyId)
          .get();

      final list = snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> submitRequest(RequestEntity request) async {
    final model = RequestModel(
      id: request.id,
      employeeId: request.employeeId,
      employeeName: request.employeeName,
      companyId: request.companyId,
      type: request.type,
      reason: request.reason,
      date: request.date,
      status: request.status,
      managerNotes: request.managerNotes,
      createdAt: request.createdAt,
    );

    await _firestore
        .collection(AppConstants.collectionRequests)
        .doc(request.id)
        .set(model.toFirestore());
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status, {String? managerNotes}) async {
    await _firestore
        .collection(AppConstants.collectionRequests)
        .doc(requestId)
        .update({
      'status': status,
      if (managerNotes != null) 'managerNotes': managerNotes,
    });
  }
}

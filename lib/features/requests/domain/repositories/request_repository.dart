import '../entities/request_entity.dart';

abstract class RequestRepository {
  Future<List<RequestEntity>> getRequestsForEmployee(String employeeId);
  Future<List<RequestEntity>> getAllRequestsForCompany(String companyId);
  Future<void> submitRequest(RequestEntity request);
  Future<void> updateRequestStatus(String requestId, String status, {String? managerNotes});
}

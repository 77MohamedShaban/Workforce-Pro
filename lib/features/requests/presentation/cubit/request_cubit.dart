import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  final RequestRepository _repository;

  RequestCubit(this._repository) : super(RequestInitial());

  Future<void> loadEmployeeRequests(String employeeId) async {
    emit(RequestLoading());
    try {
      final reqs = await _repository.getRequestsForEmployee(employeeId);
      emit(RequestLoaded(reqs));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  Future<void> loadCompanyRequests(String companyId) async {
    emit(RequestLoading());
    try {
      final reqs = await _repository.getAllRequestsForCompany(companyId);
      emit(RequestLoaded(reqs));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  Future<void> submitRequest(RequestEntity request) async {
    final currentState = state;
    emit(RequestLoading());
    try {
      await _repository.submitRequest(request);
      final list = currentState is RequestLoaded ? List<RequestEntity>.from(currentState.requests) : <RequestEntity>[];
      list.insert(0, request);
      emit(RequestLoaded(list));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  Future<void> updateStatus(String requestId, String status, {String? managerNotes}) async {
    final currentState = state;
    if (currentState is! RequestLoaded) return;

    try {
      await _repository.updateRequestStatus(requestId, status, managerNotes: managerNotes);
      final updatedList = currentState.requests.map((r) {
        if (r.id == requestId) {
          return RequestEntity(
            id: r.id,
            employeeId: r.employeeId,
            employeeName: r.employeeName,
            companyId: r.companyId,
            type: r.type,
            reason: r.reason,
            date: r.date,
            status: status,
            managerNotes: managerNotes ?? r.managerNotes,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      emit(RequestLoaded(updatedList));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }
}

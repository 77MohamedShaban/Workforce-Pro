import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;

  ReportCubit(this._repository) : super(ReportInitial());

  Future<void> loadReportSummary(String companyId) async {
    emit(ReportLoading());
    try {
      final summary = await _repository.getReportSummary(companyId);
      emit(ReportLoaded(summary));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}

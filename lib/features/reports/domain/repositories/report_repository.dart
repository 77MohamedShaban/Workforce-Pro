abstract class ReportRepository {
  Future<Map<String, dynamic>> getReportSummary(String companyId);
}

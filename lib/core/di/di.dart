import 'package:get_it/get_it.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/presentation/cubit/company_cubit.dart';
import '../../features/employees/data/repositories/employee_repository_impl.dart';
import '../../features/employees/domain/repositories/employee_repository.dart';
import '../../features/employees/presentation/cubit/employee_cubit.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/presentation/cubit/report_cubit.dart';
import '../../features/requests/data/repositories/request_repository_impl.dart';
import '../../features/requests/domain/repositories/request_repository.dart';
import '../../features/requests/presentation/cubit/request_cubit.dart';
import '../../features/schedules/data/repositories/schedule_repository_impl.dart';
import '../../features/schedules/domain/repositories/schedule_repository.dart';
import '../../features/schedules/presentation/cubit/schedule_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<AuthRepository>()) return;

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(),
  );
  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(),
  );
  getIt.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(),
  );
  getIt.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(),
  );
  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ScheduleCubit>(
    () => ScheduleCubit(getIt<ScheduleRepository>()),
  );
  getIt.registerFactory<AttendanceCubit>(
    () => AttendanceCubit(getIt<AttendanceRepository>()),
  );
  getIt.registerFactory<RequestCubit>(
    () => RequestCubit(getIt<RequestRepository>()),
  );
  getIt.registerFactory<CompanyCubit>(
    () => CompanyCubit(getIt<CompanyRepository>()),
  );
  getIt.registerFactory<EmployeeCubit>(
    () => EmployeeCubit(getIt<EmployeeRepository>()),
  );
  getIt.registerFactory<ReportCubit>(
    () => ReportCubit(getIt<ReportRepository>()),
  );
  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(getIt<ChatRepository>()),
  );
}

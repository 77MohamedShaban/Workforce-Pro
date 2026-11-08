import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/reusable_component/error_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../attendance/presentation/cubit/attendance_cubit.dart';
import '../../../attendance/presentation/cubit/attendance_state.dart';
import '../../../attendance/presentation/pages/attendance_screen.dart';
import '../../../dashboard/presentation/pages/manager_dashboard_screen.dart';
import '../../../home/presentation/pages/employee_home_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../requests/presentation/cubit/request_cubit.dart';
import '../../../requests/presentation/pages/requests_screen.dart';
import '../../../schedules/presentation/cubit/schedule_cubit.dart';
import '../../../schedules/presentation/cubit/schedule_state.dart';
import '../../../schedules/presentation/widgets/daily_timeline_view.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  bool _isManagerView = false;
  bool _hasInitializedRole = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.isManager) {
        _isManagerView = true;
      }
      _hasInitializedRole = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (!_hasInitializedRole && user.isManager) {
        setState(() {
          _isManagerView = true;
          _hasInitializedRole = true;
        });
      }
      context.read<ScheduleCubit>().loadSchedule(user.id, DateTime.now());
      context.read<AttendanceCubit>().loadAttendance(user.id);
      context.read<RequestCubit>().loadEmployeeRequests(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Explicitly listen to context.locale so locale changes instantly rebuild all bottom navigation labels
    final currentLocale = context.locale;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(body: LoadingIndicator());
        }

        if (authState is Authenticated) {
          final user = authState.user;

          // Ensure initial role initialization if not set yet
          if (!_hasInitializedRole) {
            _hasInitializedRole = true;
            if (user.isManager) {
              _isManagerView = true;
            }
          }

          final List<Widget> pages = [
            _isManagerView
                ? ManagerDashboardScreen(user: user)
                : EmployeeHomeScreen(
                    user: user,
                    onNavigateToTab: (idx) {
                      setState(() => _currentIndex = idx);
                    },
                  ),
            BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, attState) {
                final isClockedIn = attState is AttendanceLoaded && (attState.todayRecord?.isClockedIn ?? false);

                return BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) {
                    if (state is ScheduleLoading) {
                      return const LoadingIndicator();
                    }
                    if (state is ScheduleLoaded) {
                      return DailyTimelineView(
                        schedule: state.schedule,
                        transitions: state.transitions,
                        isClockedIn: isClockedIn,
                        onActivityChanged: (actualName, currentAct) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await context.read<ScheduleCubit>().changeActualActivity(
                                employeeId: user.id,
                                companyId: user.companyId ?? 'company_001',
                                actualActivityName: actualName,
                                plannedActivity: currentAct,
                              );
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Actual activity updated to "$actualName" in Firestore!'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    }
                    if (state is ScheduleError) {
                      return ErrorStateWidget(
                        errorMessage: state.message,
                        onRetry: () {
                          context.read<ScheduleCubit>().loadSchedule(user.id, DateTime.now());
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
            RequestsScreen(
              userId: user.id,
              userName: user.fullName,
              companyId: user.companyId ?? 'company_001',
              isManager: _isManagerView,
            ),
            AttendanceScreen(
              userId: user.id,
              userName: user.fullName,
              companyId: user.companyId ?? 'company_001',
            ),
            ProfileScreen(user: user),
          ];

          return Scaffold(
            key: ValueKey(currentLocale.languageCode),
            appBar: AppBar(
              title: Text(_isManagerView ? 'Workforce Pro Manager' : 'Workforce Pro'),
              actions: [
                if (user.isManager)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.blue),
                    onPressed: () {
                      setState(() {
                        _isManagerView = !_isManagerView;
                      });
                    },
                    icon: Icon(_isManagerView ? Icons.person_outline : Icons.dashboard_outlined),
                    label: Text(_isManagerView ? 'Employee View' : 'Manager View'),
                  )
              ],
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              key: ValueKey('nav_${currentLocale.languageCode}'),
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 0 || index == 1) {
                  context.read<ScheduleCubit>().loadSchedule(user.id, DateTime.now());
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: 'home'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calendar_month_outlined),
                  activeIcon: const Icon(Icons.calendar_month),
                  label: 'schedule'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment_outlined),
                  activeIcon: const Icon(Icons.assignment),
                  label: 'requests'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.fingerprint),
                  activeIcon: const Icon(Icons.fingerprint),
                  label: 'attendance'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: 'profile'.tr(),
                ),
              ],
            ),
          );
        }

        return const Scaffold(body: LoadingIndicator());
      },
    );
  }
}

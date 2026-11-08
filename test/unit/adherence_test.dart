import 'package:flutter_test/flutter_test.dart';
import 'package:workforce/core/utils/app_constants.dart';
import 'package:workforce/features/schedules/domain/entities/planned_activity_entity.dart';
import 'package:workforce/features/schedules/domain/entities/planned_schedule_entity.dart';

void main() {
  group('Daily Timeline & Adherence Tests', () {
    final now = DateTime(2025, 1, 15, 10, 0);

    final act1 = PlannedActivityEntity(
      id: '1',
      name: 'Morning Work',
      code: 'WORK',
      colorHex: '#3B82F6',
      iconName: 'work',
      startTime: DateTime(2025, 1, 15, 9, 0),
      endTime: DateTime(2025, 1, 15, 11, 0),
      durationMinutes: 120,
    );

    final act2 = PlannedActivityEntity(
      id: '2',
      name: 'Lunch Break',
      code: 'LUNCH',
      colorHex: '#F59E0B',
      iconName: 'restaurant',
      startTime: DateTime(2025, 1, 15, 11, 0),
      endTime: DateTime(2025, 1, 15, 12, 0),
      durationMinutes: 60,
    );

    final schedule = PlannedScheduleEntity(
      id: 'sched_1',
      employeeId: 'emp_1',
      employeeName: 'John Doe',
      companyId: 'comp_1',
      departmentId: 'dept_1',
      date: DateTime(2025, 1, 15),
      activities: [act1, act2],
    );

    test('getCurrentActivity returns correct in-progress activity', () {
      final current = schedule.getCurrentActivity(now);
      expect(current?.id, equals('1'));
      expect(current?.name, equals('Morning Work'));
    });

    test('getNextActivity returns correct upcoming activity', () {
      final next = schedule.getNextActivity(now);
      expect(next?.id, equals('2'));
      expect(next?.name, equals('Lunch Break'));
    });

    test('getShiftProgress calculates correct completion percentage', () {
      final progress = schedule.getShiftProgress(now);
      // 1 hour elapsed out of 3 total shift hours => 0.3333...
      expect(progress, closeTo(0.333, 0.01));
    });

    test('Adherence tolerance calculation handles on-time vs late', () {
      final transitionTimeOnTime = DateTime(2025, 1, 15, 9, 1); // 1 minute late <= 2 min tolerance
      final diffOnTime = transitionTimeOnTime.difference(act1.startTime).inMinutes.abs();
      expect(diffOnTime <= AppConstants.defaultAdherenceToleranceMinutes, isTrue);

      final transitionTimeLate = DateTime(2025, 1, 15, 9, 5); // 5 minutes late > 2 min tolerance
      final diffLate = transitionTimeLate.difference(act1.startTime).inMinutes.abs();
      expect(diffLate <= AppConstants.defaultAdherenceToleranceMinutes, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cronograma_flow/core/date_utils.dart';
import 'package:cronograma_flow/models/schedule_item.dart';

void main() {
  test('serializa e restaura uma atividade', () {
    final start = DateTime(2026, 10, 28, 10);
    final item = ScheduleItem(
      id: 'abc', title: 'Estudar Dart', description: 'Revisar exercícios',
      start: start, end: start.add(const Duration(hours: 1)),
      category: ScheduleCategory.estudos,
      priority: SchedulePriority.alta,
      completed: true,
    );
    final restored = ScheduleItem.fromJson(item.toJson());
    expect(restored.id, 'abc');
    expect(restored.title, 'Estudar Dart');
    expect(restored.category, ScheduleCategory.estudos);
    expect(restored.priority, SchedulePriority.alta);
    expect(restored.completed, true);
    expect(restored.end.difference(restored.start).inMinutes, 60);
  });

  test('calcula início da semana em segunda-feira', () {
    expect(weekStart(DateTime(2026, 10, 28)), DateTime(2026, 10, 26));
    expect(weekStart(DateTime(2026, 11, 1)), DateTime(2026, 10, 26));
  });

  test('distingue dia calendário de horário', () {
    expect(isSameDay(DateTime(2026, 10, 28, 8), DateTime(2026, 10, 28, 22)), true);
    expect(isSameDay(DateTime(2026, 10, 28), DateTime(2026, 10, 29)), false);
  });
}

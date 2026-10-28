import 'package:flutter_test/flutter_test.dart';
import 'package:cronograma_flow/controllers/schedule_controller.dart';
import 'package:cronograma_flow/data/schedule_repository.dart';
import 'package:cronograma_flow/models/schedule_item.dart';

class InMemoryRepository extends ScheduleRepository {
  List<ScheduleItem>? stored = [];

  @override
  Future<List<ScheduleItem>?> load() async => stored;

  @override
  Future<void> save(List<ScheduleItem> items) async {
    stored = List.of(items);
  }
}

void main() {
  test('adiciona, filtra, conclui e remove atividade', () async {
    final repo = InMemoryRepository();
    final controller = ScheduleController(repo);
    await controller.load();
    expect(controller.items, isEmpty);

    final date = DateTime(2026, 10, 28, 9);
    final item = ScheduleItem(
      id: '1', title: 'Estudar Flutter',
      start: date, end: date.add(const Duration(hours: 1)),
      category: ScheduleCategory.estudos, priority: SchedulePriority.media,
    );
    await controller.add(item);
    expect(controller.total, 1);
    expect(controller.pendingCount, 1);

    controller.search('flutter');
    expect(controller.filteredItems.length, 1);
    controller.search('inexistente');
    expect(controller.filteredItems, isEmpty);
    controller.search('');

    await controller.toggle(item);
    expect(controller.completedCount, 1);
    controller.setFilter(TaskFilter.pendentes);
    expect(controller.filteredItems, isEmpty);
    controller.setFilter(TaskFilter.concluidas);
    expect(controller.filteredItems.length, 1);

    await controller.remove(item.id);
    expect(repo.stored, isEmpty);
    controller.dispose();
  });

  test('detecta choque de horário sem acusar a própria edição', () async {
    final controller = ScheduleController(InMemoryRepository());
    await controller.load();
    final date = DateTime(2026, 10, 28, 9);
    final first = ScheduleItem(
      id: 'a', title: 'A', start: date,
      end: date.add(const Duration(minutes: 60)),
      category: ScheduleCategory.trabalho, priority: SchedulePriority.alta,
    );
    await controller.add(first);
    final overlap = first.copyWith(id: 'b', start: date.add(const Duration(minutes: 30)),
        end: date.add(const Duration(minutes: 90)));
    expect(controller.conflictsFor(overlap), hasLength(1));
    expect(controller.conflictsFor(first), isEmpty);
    controller.dispose();
  });
}

import 'package:flutter/foundation.dart';

import '../core/date_utils.dart';
import '../data/schedule_repository.dart';
import '../models/schedule_item.dart';

enum TaskFilter { todas, pendentes, concluidas }

class ScheduleController extends ChangeNotifier {
  ScheduleController(this._repository);

  final ScheduleRepository _repository;
  List<ScheduleItem> _items = [];
  bool isLoading = true;
  String? loadError;
  String? saveError;
  DateTime selectedDate = dateOnly(DateTime.now());
  TaskFilter filter = TaskFilter.todas;
  ScheduleCategory? categoryFilter;
  String query = '';
  Future<void> _writeQueue = Future<void>.value();

  List<ScheduleItem> get items => List.unmodifiable(_items);
  int get total => _items.length;
  int get completedCount => _items.where((item) => item.completed).length;
  int get pendingCount => _items.where((item) => !item.completed).length;
  double get progress => total == 0 ? 0 : completedCount / total;

  List<ScheduleItem> get todayItems => forDate(DateTime.now());
  List<ScheduleItem> get selectedDateItems => forDate(selectedDate);
  List<ScheduleItem> get filteredItems => _sorted(_items.where(_matches).toList());

  List<ScheduleItem> forDate(DateTime day) => _sorted(
    _items.where((item) => isSameDay(item.start, day) && _matches(item)).toList(),
  );
  List<ScheduleItem> itemsForDateUnfiltered(DateTime day) => _sorted(
    _items.where((item) => isSameDay(item.start, day)).toList(),
  );
  int completedForDate(DateTime day) => _items.where(
    (item) => isSameDay(item.start, day) && item.completed,
  ).length;

  bool _matches(ScheduleItem item) {
    if (filter == TaskFilter.pendentes && item.completed) return false;
    if (filter == TaskFilter.concluidas && !item.completed) return false;
    if (categoryFilter != null && item.category != categoryFilter) return false;
    final terms = query.trim().toLowerCase();
    if (terms.isNotEmpty && !'${item.title} ${item.description} ${item.category.label}'
        .toLowerCase().contains(terms)) return false;
    return true;
  }

  List<ScheduleItem> _sorted(List<ScheduleItem> source) {
    source.sort((a, b) {
      final dateOrder = a.start.compareTo(b.start);
      return dateOrder != 0 ? dateOrder : a.title.compareTo(b.title);
    });
    return source;
  }

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final data = await _repository.load();
      if (data == null) {
        _items = sampleItems();
        await _repository.save(_items);
      } else {
        _items = data;
      }
    } catch (_) {
      loadError = 'Não foi possível carregar os dados locais. Tente novamente.';
      _items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    selectedDate = dateOnly(date);
    notifyListeners();
  }

  void setFilter(TaskFilter value) {
    filter = value;
    notifyListeners();
  }

  void setCategory(ScheduleCategory? value) {
    categoryFilter = value;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  Future<void> add(ScheduleItem item) async {
    _items = [..._items, item];
    notifyListeners();
    await _save();
  }

  Future<void> update(ScheduleItem item) async {
    _items = _items.map((previous) => previous.id == item.id ? item : previous).toList();
    notifyListeners();
    await _save();
  }

  Future<void> toggle(ScheduleItem item) async =>
      update(item.copyWith(completed: !item.completed));

  Future<void> remove(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    notifyListeners();
    await _save();
  }

  List<ScheduleItem> conflictsFor(ScheduleItem item) => _items.where((old) =>
    old.id != item.id &&
    old.start.isBefore(item.end) &&
    item.start.isBefore(old.end) &&
    !old.completed
  ).toList();

  Future<void> _save() {
    final snapshot = List<ScheduleItem>.from(_items);
    _writeQueue = _writeQueue.catchError((Object _) {}).then((_) async {
      try {
        await _repository.save(snapshot);
        if (saveError != null) {
          saveError = null;
          notifyListeners();
        }
      } catch (_) {
        saveError = 'Falha ao salvar no dispositivo. Verifique o armazenamento.';
        notifyListeners();
      }
    });
    return _writeQueue;
  }

  static List<ScheduleItem> sampleItems() {
    final today = dateOnly(DateTime.now());
    ScheduleItem make(int offset, int hour, int minute, int duration, String title,
        ScheduleCategory category, SchedulePriority priority, {bool done = false}) {
      final start = today.add(Duration(days: offset, hours: hour, minutes: minute));
      return ScheduleItem(
        id: 'exemplo_${offset}_${hour}_$minute', title: title,
        description: 'Atividade de demonstração. Edite ou exclua quando quiser.',
        start: start, end: start.add(Duration(minutes: duration)),
        category: category, priority: priority, completed: done,
      );
    }
    return [
      make(0, 8, 0, 60, 'Planejamento do dia', ScheduleCategory.pessoal, SchedulePriority.media, done: true),
      make(0, 10, 0, 90, 'Desenvolver projeto Flutter', ScheduleCategory.projetos, SchedulePriority.alta),
      make(0, 14, 0, 60, 'Estudar Dart e widgets', ScheduleCategory.estudos, SchedulePriority.media),
      make(1, 9, 0, 75, 'Revisão das entregas', ScheduleCategory.trabalho, SchedulePriority.alta),
      make(1, 18, 0, 45, 'Atividade física', ScheduleCategory.saude, SchedulePriority.baixa),
      make(2, 15, 30, 60, 'Organizar próximos objetivos', ScheduleCategory.pessoal, SchedulePriority.media),
      make(3, 11, 0, 90, 'Concluir funcionalidades do app', ScheduleCategory.projetos, SchedulePriority.alta),
      make(-1, 16, 0, 60, 'Revisar tarefas anteriores', ScheduleCategory.estudos, SchedulePriority.baixa, done: true),
    ];
  }
}

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

enum ScheduleCategory { estudos, trabalho, projetos, pessoal, saude }
enum SchedulePriority { baixa, media, alta }

extension CategoryInfo on ScheduleCategory {
  String get label => switch (this) {
    ScheduleCategory.estudos => 'Estudos',
    ScheduleCategory.trabalho => 'Trabalho',
    ScheduleCategory.projetos => 'Projetos',
    ScheduleCategory.pessoal => 'Pessoal',
    ScheduleCategory.saude => 'Saúde',
  };
  Color get color => switch (this) {
    ScheduleCategory.estudos => AppColors.blue,
    ScheduleCategory.trabalho => AppColors.cyan,
    ScheduleCategory.projetos => AppColors.indigo,
    ScheduleCategory.pessoal => AppColors.pink,
    ScheduleCategory.saude => AppColors.green,
  };
  IconData get icon => switch (this) {
    ScheduleCategory.estudos => Icons.menu_book_rounded,
    ScheduleCategory.trabalho => Icons.work_outline_rounded,
    ScheduleCategory.projetos => Icons.rocket_launch_outlined,
    ScheduleCategory.pessoal => Icons.person_outline_rounded,
    ScheduleCategory.saude => Icons.favorite_outline_rounded,
  };
}

extension PriorityInfo on SchedulePriority {
  String get label => switch (this) {
    SchedulePriority.baixa => 'Baixa',
    SchedulePriority.media => 'Média',
    SchedulePriority.alta => 'Alta',
  };
  Color get color => switch (this) {
    SchedulePriority.baixa => AppColors.green,
    SchedulePriority.media => AppColors.orange,
    SchedulePriority.alta => const Color(0xFFEC6A73),
  };
}

class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.category,
    required this.priority,
    this.description = '',
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final ScheduleCategory category;
  final SchedulePriority priority;
  final bool completed;

  bool get isOverdue => !completed && end.isBefore(DateTime.now());

  ScheduleItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    ScheduleCategory? category,
    SchedulePriority? priority,
    bool? completed,
  }) => ScheduleItem(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    start: start ?? this.start,
    end: end ?? this.end,
    category: category ?? this.category,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'category': category.name,
    'priority': priority.name,
    'completed': completed,
  };

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['start'] as String);
    final end = DateTime.parse(json['end'] as String);
    if (!end.isAfter(start)) throw const FormatException('Horário inválido');
    return ScheduleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      start: start,
      end: end,
      category: ScheduleCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => ScheduleCategory.pessoal,
      ),
      priority: SchedulePriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => SchedulePriority.media,
      ),
      completed: json['completed'] == true,
    );
  }
}

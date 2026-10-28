import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/date_utils.dart';
import '../models/schedule_item.dart';

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({super.key, required this.child, this.padding = const EdgeInsets.all(22)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.divider),
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, color: AppColors.ink, fontWeight: FontWeight.w800)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ])),
      if (trailing != null) trailing!,
    ],
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key, required this.label, required this.value,
    required this.icon, required this.color, this.detail,
  });
  final String label;
  final String value;
  final String? detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.all(19),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color),
        ),
        const Spacer(),
        const Icon(Icons.more_horiz, color: AppColors.muted, size: 21),
      ]),
      const SizedBox(height: 17),
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ink)),
      const SizedBox(height: 3),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
      if (detail != null) ...[
        const SizedBox(height: 4),
        Text(detail!, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    ]),
  );
}

class CategoryPill extends StatelessWidget {
  const CategoryPill(this.category, {super.key, this.compact = false});
  final ScheduleCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
    decoration: BoxDecoration(
      color: category.color.withOpacity(.10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(height: 7, width: 7, decoration: BoxDecoration(color: category.color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(category.label, style: TextStyle(fontSize: compact ? 10 : 11, fontWeight: FontWeight.w700, color: category.color)),
    ]),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message, this.onCreate});
  final String title;
  final String message;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) => SurfacePanel(child: SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 33),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(color: AppColors.softIndigo, shape: BoxShape.circle),
          child: const Icon(Icons.event_available_outlined, size: 35, color: AppColors.indigo),
        ),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 7),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        if (onCreate != null) ...[
          const SizedBox(height: 17),
          TextButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Criar atividade')),
        ],
      ]),
    ),
  ));
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key, required this.item, required this.onToggle,
    required this.onEdit, required this.onDelete, this.showDate = false,
  });
  final ScheduleItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDate;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(100),
          child: Semantics(
            label: item.completed ? 'Marcar como pendente' : 'Marcar como concluída',
            child: Icon(
              item.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: item.completed ? AppColors.green : AppColors.muted,
              size: 25,
            ),
          ),
        ),
      ),
      const SizedBox(width: 13),
      Container(
        width: 3, height: 53,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(color: item.category.color, borderRadius: BorderRadius.circular(5)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: Text(item.title,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              color: item.completed ? AppColors.muted : AppColors.ink,
              decoration: item.completed ? TextDecoration.lineThrough : null,
            ),
          )),
          if (item.isOverdue) ...[
            const SizedBox(width: 7),
            const Tooltip(message: 'Atividade atrasada', child: Icon(Icons.error_outline, size: 16, color: Color(0xFFEC6A73))),
          ],
        ]),
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 9, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.schedule_rounded, size: 14, color: AppColors.muted),
            const SizedBox(width: 4),
            Text('${formatTime(item.start)}–${formatTime(item.end)}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
          ]),
          if (showDate) Text(formatDate(item.start),
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          CategoryPill(item.category, compact: true),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.flag_rounded, color: item.priority.color, size: 12),
            const SizedBox(width: 3),
            Text(item.priority.label, style: TextStyle(fontSize: 10, color: item.priority.color, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ])),
      PopupMenuButton<String>(
        tooltip: 'Opções da atividade',
        icon: const Icon(Icons.more_vert, color: AppColors.muted, size: 20),
        onSelected: (action) {
          if (action == 'edit') onEdit();
          if (action == 'delete') onDelete();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Row(children: [
            Icon(Icons.edit_outlined, size: 19), SizedBox(width: 10), Text('Editar'),
          ])),
          PopupMenuItem(value: 'delete', child: Row(children: [
            Icon(Icons.delete_outline, size: 19, color: Color(0xFFDD5E68)),
            SizedBox(width: 10), Text('Excluir', style: TextStyle(color: Color(0xFFDD5E68))),
          ])),
        ],
      ),
    ]),
  );
}

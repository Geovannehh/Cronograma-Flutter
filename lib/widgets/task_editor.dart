import 'package:flutter/material.dart';

import '../controllers/schedule_controller.dart';
import '../core/app_theme.dart';
import '../core/date_utils.dart';
import '../models/schedule_item.dart';

Future<bool?> showTaskEditor(
  BuildContext context,
  ScheduleController controller, {
  ScheduleItem? existing,
  DateTime? date,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
  ),
  builder: (_) => TaskEditor(controller: controller, existing: existing, date: date),
);

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key, required this.controller, this.existing, this.date});
  final ScheduleController controller;
  final ScheduleItem? existing;
  final DateTime? date;

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late ScheduleCategory _category;
  late SchedulePriority _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _title = TextEditingController(text: item?.title ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _date = dateOnly(item?.start ?? widget.date ?? DateTime.now());
    _start = item == null ? const TimeOfDay(hour: 9, minute: 0) : timeOf(item.start);
    _end = item == null ? const TimeOfDay(hour: 10, minute: 0) : timeOf(item.end);
    _category = item?.category ?? ScheduleCategory.projetos;
    _priority = item?.priority ?? SchedulePriority.media;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Data da atividade',
    );
    if (result != null && mounted) setState(() => _date = result);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final start = combineDateAndTime(_date, _start);
    final end = combineDateAndTime(_date, _end);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O horário final deve ser posterior ao inicial.')),
      );
      return;
    }
    final item = ScheduleItem(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      start: start,
      end: end,
      category: _category,
      priority: _priority,
      completed: widget.existing?.completed ?? false,
    );
    final conflicts = widget.controller.conflictsFor(item);
    if (conflicts.isNotEmpty) {
      final allowed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Conflito de horários'),
          content: Text('Esse horário coincide com "${conflicts.first.title}". Deseja salvar mesmo assim?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar mesmo assim')),
          ],
        ),
      );
      if (allowed != true || !mounted) return;
    }
    setState(() => _saving = true);
    if (widget.existing == null) {
      await widget.controller.add(item);
    } else {
      await widget.controller.update(item);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return FractionallySizedBox(
      heightFactor: .94,
      child: Padding(
        padding: EdgeInsets.fromLTRB(23, 19, 23, bottom + 20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text(widget.existing == null ? 'Nova atividade' : 'Editar atividade',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height: 5),
            const Align(alignment: Alignment.centerLeft,
              child: Text('Organize seus compromissos em poucos passos.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13))),
            const SizedBox(height: 24),
            Expanded(child: ListView(children: [
              const _InputLabel('Nome da atividade'),
              TextFormField(
                controller: _title,
                autofocus: widget.existing == null,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 90,
                decoration: const InputDecoration(hintText: 'Ex.: Estudar Flutter'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Informe o nome da atividade' : null,
              ),
              const SizedBox(height: 13),
              const _InputLabel('Descrição (opcional)'),
              TextFormField(
                controller: _description,
                minLines: 2, maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Adicione uma observação...'),
              ),
              const SizedBox(height: 22),
              const _InputLabel('Data'),
              _PickerField(icon: Icons.calendar_today_outlined, value: formatDate(_date), onTap: _pickDate),
              const SizedBox(height: 17),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _InputLabel('Início'),
                  _PickerField(icon: Icons.schedule, value: _start.format(context), onTap: () => _pickTime(true)),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _InputLabel('Término'),
                  _PickerField(icon: Icons.schedule, value: _end.format(context), onTap: () => _pickTime(false)),
                ])),
              ]),
              const SizedBox(height: 22),
              const _InputLabel('Categoria'),
              DropdownButtonFormField<ScheduleCategory>(
                value: _category,
                decoration: const InputDecoration(),
                items: ScheduleCategory.values.map((value) => DropdownMenuItem(
                  value: value, child: Row(children: [
                    Icon(value.icon, size: 18, color: value.color),
                    const SizedBox(width: 10), Text(value.label),
                  ]),
                )).toList(),
                onChanged: (value) { if (value != null) setState(() => _category = value); },
              ),
              const SizedBox(height: 18),
              const _InputLabel('Prioridade'),
              DropdownButtonFormField<SchedulePriority>(
                value: _priority,
                decoration: const InputDecoration(),
                items: SchedulePriority.values.map((value) => DropdownMenuItem(
                  value: value, child: Row(children: [
                    Icon(Icons.flag_outlined, size: 18, color: value.color),
                    const SizedBox(width: 10), Text(value.label),
                  ]),
                )).toList(),
                onChanged: (value) { if (value != null) setState(() => _priority = value); },
              ),
              const SizedBox(height: 14),
            ])),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving ? const SizedBox(width: 17, height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                label: Text(_saving ? 'Salvando...' : widget.existing == null ? 'Criar atividade' : 'Salvar alterações'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
  );
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.icon, required this.value, required this.onTap});
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.indigo),
          const SizedBox(width: 11),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}

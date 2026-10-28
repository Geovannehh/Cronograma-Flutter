import 'package:flutter/material.dart';

import '../controllers/schedule_controller.dart';
import '../core/app_theme.dart';
import '../core/date_utils.dart';
import '../models/schedule_item.dart';
import '../widgets/task_editor.dart';
import '../widgets/ui_elements.dart';

enum _Page { overview, calendar, tasks }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});
  final ScheduleController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Page _page = _Page.overview;
  DateTime _visibleMonth = startOfMonth(DateTime.now());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ScheduleController get controller => widget.controller;

  Future<void> _openEditor({ScheduleItem? item, DateTime? date}) async {
    final result = await showTaskEditor(
      context, controller, existing: item, date: date ?? controller.selectedDate,
    );
    if (!mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(controller.saveError ?? (item == null
          ? 'Atividade criada com sucesso!'
          : 'Atividade atualizada!')),
    ));
  }

  void _remove(ScheduleItem item) {
    controller.remove(item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Atividade excluída.'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'DESFAZER', textColor: const Color(0xFFB6B1FF),
            onPressed: () => controller.add(item)),
      ));
  }

  void _goToPage(_Page page) {
    setState(() {
      _page = page;
      if (page == _Page.calendar) {
        _visibleMonth = startOfMonth(controller.selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1100;
        return Scaffold(
          body: Row(children: [
            if (desktop) _sidebar(),
            Expanded(child: SafeArea(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.loadError != null
                      ? _loadError()
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(desktop ? 38 : 18, desktop ? 30 : 21,
                              desktop ? 38 : 18, 35),
                          child: Center(child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1270),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _header(desktop),
                              if (controller.saveError != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFFFE7E8), borderRadius: BorderRadius.circular(12)),
                                  child: Row(children: [
                                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFAE3F49)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(controller.saveError!, style: const TextStyle(color: Color(0xFFAE3F49)))),
                                  ]),
                                ),
                              ],
                              const SizedBox(height: 27),
                              if (_page == _Page.overview) _overview(desktop),
                              if (_page == _Page.calendar) _calendar(desktop),
                              if (_page == _Page.tasks) _allTasks(desktop),
                            ]),
                          )),
                        ),
            )),
          ]),
          floatingActionButton: desktop || controller.isLoading || controller.loadError != null
              ? null
              : FloatingActionButton(
                  tooltip: 'Nova atividade',
                  backgroundColor: AppColors.indigo,
                  foregroundColor: Colors.white,
                  onPressed: () => _openEditor(),
                  child: const Icon(Icons.add_rounded),
                ),
          bottomNavigationBar: desktop ? null : NavigationBar(
            height: 73,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.softIndigo,
            selectedIndex: _page.index,
            onDestinationSelected: (index) => _goToPage(_Page.values[index]),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded), label: 'Painel'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendário'),
              NavigationDestination(icon: Icon(Icons.checklist_outlined),
                  selectedIcon: Icon(Icons.checklist_rounded), label: 'Atividades'),
            ],
          ),
        );
      },
    ),
  );

  Widget _loadError() => Center(child: Padding(
    padding: const EdgeInsets.all(30),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.muted),
      const SizedBox(height: 15),
      Text(controller.loadError!, textAlign: TextAlign.center),
      const SizedBox(height: 13),
      FilledButton(onPressed: controller.load, child: const Text('Tentar novamente')),
    ]),
  ));

  Widget _sidebar() => Container(
    width: 244,
    color: AppColors.sidebar,
    child: SafeArea(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.fromLTRB(17, 31, 17, 25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 13), child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.cyan]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 11),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('flow.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: -.9)),
            Text('SEU CRONOGRAMA', style: TextStyle(fontSize: 9,
                fontWeight: FontWeight.w800, color: Color(0xFF969DBB), letterSpacing: 1.3)),
          ]),
        ])),
        const SizedBox(height: 54),
        const Padding(padding: EdgeInsets.only(left: 14, bottom: 16),
          child: Text('MENU PRINCIPAL', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF888EAB), letterSpacing: 1.3))),
        _sideNav(_Page.overview, 'Visão geral', Icons.dashboard_rounded),
        _sideNav(_Page.calendar, 'Calendário', Icons.calendar_month_rounded),
        _sideNav(_Page.tasks, 'Minhas atividades', Icons.checklist_rounded),
        const SizedBox(height: 36),
        const Padding(padding: EdgeInsets.only(left: 14, bottom: 16),
          child: Text('CATEGORIAS', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF888EAB), letterSpacing: 1.3))),
        ...ScheduleCategory.values.map((category) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            controller.setCategory(controller.categoryFilter == category ? null : category);
            _goToPage(_Page.tasks);
          },
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(
                  color: category.color, shape: BoxShape.circle)),
              const SizedBox(width: 14),
              Expanded(child: Text(category.label, style: TextStyle(
                fontSize: 13, color: controller.categoryFilter == category
                    ? Colors.white : const Color(0xFFAFB6D0),
                fontWeight: controller.categoryFilter == category ? FontWeight.w800 : FontWeight.w500,
              ))),
              if (controller.categoryFilter == category)
                const Icon(Icons.check, size: 16, color: Colors.white),
            ]),
          ),
        )),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(color: const Color(0xFF24294C), borderRadius: BorderRadius.circular(17)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFFFC472), size: 19),
              SizedBox(width: 7),
              Text('Seu progresso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 7,
              backgroundColor: const Color(0xFF41466B),
              valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
            )),
            const SizedBox(height: 10),
            Text('${(controller.progress * 100).round()}% concluído',
                style: const TextStyle(color: Color(0xFFD1D5EB), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 22),
        const Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Color(0xFF3F4471),
              child: Icon(Icons.person_rounded, size: 21, color: Colors.white)),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Minha agenda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            SizedBox(height: 2),
            Text('Organização pessoal', style: TextStyle(color: Color(0xFF888EAB), fontSize: 10)),
          ]),
        ]),
      ]),
    ))),
  );

  Widget _sideNav(_Page page, String title, IconData icon) {
    final selected = _page == page;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: selected ? AppColors.indigo : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _goToPage(page),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              Icon(icon, size: 20, color: selected ? Colors.white : const Color(0xFFAFB6D0)),
              const SizedBox(width: 13),
              Text(title, style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFAFB6D0),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13,
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header(bool desktop) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_page == _Page.overview ? 'Visão geral' : _page == _Page.calendar ? 'Calendário' : 'Minhas atividades',
              style: TextStyle(fontSize: desktop ? 29 : 25, color: AppColors.ink,
                  fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 5),
          Text('${formatWeekdayDate(DateTime.now())} • ${DateTime.now().year}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ])),
        if (desktop) ...[
          SizedBox(width: 240, child: TextField(
            controller: _searchController,
            onChanged: controller.search,
            decoration: const InputDecoration(
              hintText: 'Buscar atividade...',
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 13),
            ),
          )),
          const SizedBox(width: 13),
          FilledButton.icon(onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 20), label: const Text('Nova atividade')),
        ] else
          IconButton(tooltip: 'Ir para hoje',
              onPressed: () { controller.selectDate(DateTime.now()); setState(() => _visibleMonth = startOfMonth(DateTime.now())); },
              icon: const Icon(Icons.today_outlined, color: AppColors.indigo)),
      ]),
      if (!desktop) ...[
        const SizedBox(height: 17),
        TextField(
          controller: _searchController,
          onChanged: controller.search,
          decoration: const InputDecoration(
            hintText: 'Buscar atividades...',
            hintStyle: TextStyle(fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
          ),
        ),
      ],
    ],
  );

  Widget _overview(bool desktop) {
    final today = DateTime.now();
    final todayCount = controller.itemsForDateUnfiltered(today).length;
    final week = weekStart(controller.selectedDate);
    final weekItems = controller.items.where((item) =>
        !item.start.isBefore(week) && item.start.isBefore(week.add(const Duration(days: 7)))).toList();
    final doneWeek = weekItems.where((item) => item.completed).length;
    final weekProgress = weekItems.isEmpty ? 0.0 : doneWeek / weekItems.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(desktop ? 27 : 23),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF6557F5), Color(0xFF463DC1)]),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Wrap(spacing: 25, runSpacing: 20,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greetingFor(DateTime.now()), style: const TextStyle(color: Color(0xFFD7D3FF),
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(todayCount == 0 ? 'Seu dia está livre para novos planos.' : 'Transforme seus planos em conquistas.',
                    style: TextStyle(color: Colors.white,
                        fontSize: desktop ? 25 : 22, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 10),
                Text('Você tem $todayCount ${todayCount == 1 ? 'atividade programada' : 'atividades programadas'} para hoje. Mantenha seu ritmo!',
                    style: const TextStyle(color: Color(0xFFE1DEFF), fontSize: 12)),
              ]),
            ),
            Container(
              width: 178,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(17)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('META DA SEMANA', style: TextStyle(fontSize: 10,
                    color: Color(0xFFE1DEFF), fontWeight: FontWeight.w800, letterSpacing: .6)),
                const SizedBox(height: 10),
                Text('${(weekProgress * 100).round()}%', style: const TextStyle(color: Colors.white,
                    fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                ClipRRect(borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: weekProgress, minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF61E4DC)))),
                const SizedBox(height: 8),
                Text('$doneWeek de ${weekItems.length} concluídas',
                    style: const TextStyle(color: Color(0xFFE1DEFF), fontSize: 10)),
              ]),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, bounds) {
        final cols = bounds.maxWidth >= 750 ? 4 : bounds.maxWidth >= 440 ? 2 : 2;
        const gap = 12.0;
        final tileWidth = (bounds.maxWidth - gap * (cols - 1)) / cols;
        final metrics = [
          MetricTile(label: 'Total de atividades', value: '${controller.total}',
            icon: Icons.grid_view_rounded, color: AppColors.indigo, detail: 'No seu cronograma'),
          MetricTile(label: 'Para hoje', value: '$todayCount',
            icon: Icons.today_outlined, color: AppColors.blue, detail: 'Compromissos do dia'),
          MetricTile(label: 'Pendentes', value: '${controller.pendingCount}',
            icon: Icons.pending_actions_rounded, color: AppColors.orange, detail: 'Aguardando conclusão'),
          MetricTile(label: 'Concluídas', value: '${controller.completedCount}',
            icon: Icons.task_alt_rounded, color: AppColors.green, detail: 'Tarefas finalizadas'),
        ];
        return Wrap(spacing: gap, runSpacing: gap,
          children: metrics.map((metric) => SizedBox(width: tileWidth, child: metric)).toList());
      }),
      const SizedBox(height: 28),
      SectionTitle('Sua semana', subtitle: 'Selecione um dia para visualizar os compromissos',
        trailing: TextButton.icon(
          onPressed: () => controller.selectDate(DateTime.now()),
          icon: const Icon(Icons.near_me_outlined, size: 16), label: const Text('Hoje'),
        )),
      const SizedBox(height: 16),
      _weekStrip(),
      const SizedBox(height: 26),
      if (desktop)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 7, child: _agendaForSelected()),
          const SizedBox(width: 20),
          Expanded(flex: 4, child: _insightsPanel()),
        ])
      else ...[
        _agendaForSelected(),
        const SizedBox(height: 20),
        _insightsPanel(),
      ],
    ]);
  }

  Widget _weekStrip() {
    final monday = weekStart(controller.selectedDate);
    final days = List.generate(7, (index) => monday.add(Duration(days: index)));
    return SurfacePanel(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 16), child: Column(children: [
      Row(children: [
        IconButton(tooltip: 'Semana anterior',
          onPressed: () => controller.selectDate(controller.selectedDate.subtract(const Duration(days: 7))),
          icon: const Icon(Icons.chevron_left, size: 22, color: AppColors.muted)),
        Expanded(child: Text('${formatDate(monday)}  –  ${formatDate(weekEnd(monday))}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 12))),
        IconButton(tooltip: 'Próxima semana',
          onPressed: () => controller.selectDate(controller.selectedDate.add(const Duration(days: 7))),
          icon: const Icon(Icons.chevron_right, size: 22, color: AppColors.muted)),
      ]),
      const SizedBox(height: 12),
      Row(children: days.map((date) {
        final selected = isSameDay(date, controller.selectedDate);
        final dayTasks = controller.itemsForDateUnfiltered(date);
        final completed = dayTasks.where((item) => item.completed).length;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: () => controller.selectDate(date),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? AppColors.indigo : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: [
                Text(shortDaysPt[date.weekday - 1],
                  style: TextStyle(color: selected ? Colors.white.withOpacity(.80) : AppColors.muted,
                      fontWeight: FontWeight.w800, fontSize: 9)),
                const SizedBox(height: 10),
                Text('${date.day}', style: TextStyle(color: selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 10),
                Container(width: 7, height: 7, decoration: BoxDecoration(
                  color: dayTasks.isEmpty ? Colors.transparent
                      : completed == dayTasks.length ? AppColors.green
                      : selected ? Colors.white : AppColors.indigo,
                  shape: BoxShape.circle,
                )),
              ]),
            ),
          ),
        ));
      }).toList()),
    ]));
  }

  Widget _agendaForSelected() {
    final tasks = controller.selectedDateItems;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('Agenda do dia', subtitle: formatWeekdayDate(controller.selectedDate),
        trailing: IconButton(tooltip: 'Adicionar neste dia',
            onPressed: () => _openEditor(date: controller.selectedDate),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.indigo))),
      const SizedBox(height: 15),
      if (tasks.isEmpty)
        EmptyState(title: 'Nenhuma atividade por aqui',
          message: 'Seu dia está livre ou os filtros ocultaram os compromissos.',
          onCreate: () => _openEditor(date: controller.selectedDate))
      else
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _taskCard(task),
        )),
    ]);
  }

  Widget _taskCard(ScheduleItem task, {bool showDate = false}) => TaskCard(
    item: task, showDate: showDate,
    onToggle: () => controller.toggle(task),
    onEdit: () => _openEditor(item: task),
    onDelete: () => _remove(task),
  );

  Widget _insightsPanel() {
    final upcoming = controller.items.where((item) =>
      !item.completed && !item.start.isBefore(dateOnly(DateTime.now()))).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return Column(children: [
      SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_graph_rounded, color: AppColors.indigo, size: 20),
          SizedBox(width: 9),
          Text('Próximas atividades',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink)),
        ]),
        const SizedBox(height: 20),
        if (upcoming.isEmpty)
          const Text('Sem compromissos futuros.', style: TextStyle(color: AppColors.muted, fontSize: 12))
        else
          ...upcoming.take(4).map((item) => InkWell(
            onTap: () => _openEditor(item: item),
            child: Padding(padding: const EdgeInsets.only(bottom: 17),
              child: Row(children: [
                Container(width: 3, height: 37, decoration: BoxDecoration(
                    color: item.category.color, borderRadius: BorderRadius.circular(5))),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 5),
                  Text('${formatDate(item.start)} • ${formatTime(item.start)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
              ]),
            ),
          )),
      ])),
      const SizedBox(height: 16),
      SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.donut_small_rounded, color: AppColors.cyan, size: 20),
          SizedBox(width: 9),
          Text('Por categoria', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w800, color: AppColors.ink)),
        ]),
        const SizedBox(height: 18),
        ...ScheduleCategory.values.map((category) {
          final count = controller.items.where((item) => item.category == category).length;
          final ratio = controller.total == 0 ? 0.0 : count / controller.total;
          return Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(children: [
            Row(children: [
              Icon(category.icon, color: category.color, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(category.label,
                  style: const TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w600))),
              Text('$count', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
            const SizedBox(height: 7),
            ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(
              value: ratio, minHeight: 5, backgroundColor: AppColors.bg,
              valueColor: AlwaysStoppedAnimation<Color>(category.color))),
          ]));
        }),
      ])),
    ]);
  }

  Widget _calendar(bool desktop) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SectionTitle('Organize seu mês', subtitle: 'Visualize seus dias e escolha quando planejar',
      trailing: TextButton(onPressed: () {
        controller.selectDate(DateTime.now());
        setState(() => _visibleMonth = startOfMonth(DateTime.now()));
      }, child: const Text('Ir para hoje'))),
    const SizedBox(height: 19),
    SurfacePanel(child: Column(children: [
      Row(children: [
        Expanded(child: Text(formatMonthYear(_visibleMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink))),
        IconButton(tooltip: 'Mês anterior',
            onPressed: () => setState(() => _visibleMonth = addMonths(_visibleMonth, -1)),
            icon: const Icon(Icons.chevron_left)),
        IconButton(tooltip: 'Próximo mês',
            onPressed: () => setState(() => _visibleMonth = addMonths(_visibleMonth, 1)),
            icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 18),
      Row(children: shortDaysPt.map((day) => Expanded(child: Center(child: Text(day,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted))))).toList()),
      const SizedBox(height: 11),
      LayoutBuilder(builder: (context, bounds) {
        final first = weekStart(_visibleMonth);
        final lastDay = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
        final last = weekEnd(lastDay);
        final cells = last.difference(first).inDays + 1;
        final days = List.generate(cells, (index) => first.add(Duration(days: index)));
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: bounds.maxWidth >= 700 ? 1.24 : .72,
          ),
          itemBuilder: (context, index) {
            final date = days[index];
            final activeMonth = date.month == _visibleMonth.month;
            final selected = isSameDay(date, controller.selectedDate);
            final today = isSameDay(date, DateTime.now());
            final dayTasks = controller.itemsForDateUnfiltered(date);
            return Material(
              color: selected ? AppColors.softIndigo : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  controller.selectDate(date);
                  if (!activeMonth) setState(() => _visibleMonth = startOfMonth(date));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: selected ? AppColors.indigo : Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Container(
                      width: 25, height: 25,
                      decoration: BoxDecoration(
                        color: today ? AppColors.indigo : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${date.day}', style: TextStyle(
                          fontWeight: selected || today ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 12,
                          color: today ? Colors.white : activeMonth ? AppColors.ink : AppColors.muted.withOpacity(.5))),
                    ),
                    Wrap(alignment: WrapAlignment.center, spacing: 3, runSpacing: 3,
                      children: dayTasks.take(3).map((item) => Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(color: item.category.color, shape: BoxShape.circle),
                      )).toList()),
                  ]),
                ),
              ),
            );
          },
        );
      }),
      const SizedBox(height: 10),
      const Row(children: [
        Icon(Icons.circle, size: 8, color: AppColors.indigo),
        SizedBox(width: 6),
        Flexible(child: Text('Hoje e dia selecionado em destaque • Pontos indicam atividades',
            style: TextStyle(color: AppColors.muted, fontSize: 10))),
      ]),
    ])),
    const SizedBox(height: 25),
    _agendaForSelected(),
  ]);

  Widget _allTasks(bool desktop) {
    final entries = controller.filteredItems;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('Todas as atividades',
        subtitle: '${entries.length} ${entries.length == 1 ? 'atividade encontrada' : 'atividades encontradas'}',
        trailing: desktop ? FilledButton.icon(
          onPressed: () => _openEditor(),
          icon: const Icon(Icons.add), label: const Text('Adicionar'),
        ) : null),
      const SizedBox(height: 17),
      Wrap(spacing: 9, runSpacing: 10, children: [
        for (final current in TaskFilter.values)
          ChoiceChip(
            label: Text(switch (current) {
              TaskFilter.todas => 'Todas',
              TaskFilter.pendentes => 'Pendentes',
              TaskFilter.concluidas => 'Concluídas',
            }),
            selected: controller.filter == current,
            onSelected: (_) => controller.setFilter(current),
            selectedColor: AppColors.softIndigo,
            side: BorderSide(color: controller.filter == current ? AppColors.indigo : AppColors.divider),
            labelStyle: TextStyle(color: controller.filter == current ? AppColors.indigo : AppColors.ink,
                fontWeight: FontWeight.w700, fontSize: 12),
            showCheckmark: false,
          ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 9, runSpacing: 9, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const Text('Categoria:', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        DropdownButton<ScheduleCategory?>(
          value: controller.categoryFilter,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(12),
          items: [
            const DropdownMenuItem<ScheduleCategory?>(value: null, child: Text('Todas')),
            ...ScheduleCategory.values.map((c) => DropdownMenuItem<ScheduleCategory?>(
              value: c, child: Text(c.label),
            )),
          ],
          onChanged: controller.setCategory,
        ),
        if (controller.query.isNotEmpty || controller.categoryFilter != null || controller.filter != TaskFilter.todas)
          TextButton.icon(onPressed: () {
            _searchController.clear();
            controller.search('');
            controller.setCategory(null);
            controller.setFilter(TaskFilter.todas);
          }, icon: const Icon(Icons.filter_alt_off_outlined, size: 15), label: const Text('Limpar filtros')),
      ]),
      const SizedBox(height: 14),
      if (entries.isEmpty)
        EmptyState(title: 'Nenhuma atividade encontrada',
          message: 'Experimente outros filtros ou crie um compromisso.',
          onCreate: () => _openEditor())
      else
        ...entries.map((task) => Padding(padding: const EdgeInsets.only(bottom: 11),
          child: _taskCard(task, showDate: true))),
    ]);
  }
}

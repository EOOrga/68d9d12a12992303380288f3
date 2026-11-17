import 'package:flutter/material.dart';

const String appTitle = 'ROUILLON ISABELLE';
const bool screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

void main() {
  runApp(const OperationsApp());
}

class OperationsApp extends StatelessWidget {
  const OperationsApp({
    super.key,
    OpsStore? store,
    this.useScreenshotData = screenshotMode,
  }) : store = store ?? const SessionOpsStore();

  final OpsStore store;
  final bool useScreenshotData;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF214C67),
      primary: const Color(0xFF214C67),
      secondary: const Color(0xFF2F8EA6),
      tertiary: const Color(0xFFC4A15D),
      surface: const Color(0xFFF6FAFB),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF3F7F8),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: const TextStyle(
            color: Color(0xFF173343),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE0EAED)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: OperationsHome(store: store, useScreenshotData: useScreenshotData),
    );
  }
}

abstract class OpsStore {
  Future<List<OpsRecord>> loadRecords();
  Future<void> saveRecords(List<OpsRecord> records);
  Future<void> clearRecords();
}

class SessionOpsStore implements OpsStore {
  const SessionOpsStore();

  static var _records = <OpsRecord>[];

  @override
  Future<List<OpsRecord>> loadRecords() async => [..._records];

  @override
  Future<void> saveRecords(List<OpsRecord> records) async {
    _records = [...records];
  }

  @override
  Future<void> clearRecords() async {
    _records = [];
  }
}

class MemoryOpsStore implements OpsStore {
  MemoryOpsStore([List<OpsRecord>? records]) : _records = [...?records];

  List<OpsRecord> _records;

  @override
  Future<List<OpsRecord>> loadRecords() async => [..._records];

  @override
  Future<void> saveRecords(List<OpsRecord> records) async {
    _records = [...records];
  }

  @override
  Future<void> clearRecords() async {
    _records = [];
  }
}

enum RecordType { shipment, lead, visitor }

extension RecordTypeText on RecordType {
  String get label {
    switch (this) {
      case RecordType.shipment:
        return 'Shipment';
      case RecordType.lead:
        return 'Lead';
      case RecordType.visitor:
        return 'Visitor';
    }
  }

  String get plural {
    switch (this) {
      case RecordType.shipment:
        return 'Shipments';
      case RecordType.lead:
        return 'Leads';
      case RecordType.visitor:
        return 'Visitors';
    }
  }

  String get storageKey {
    switch (this) {
      case RecordType.shipment:
        return 'shipment';
      case RecordType.lead:
        return 'lead';
      case RecordType.visitor:
        return 'visitor';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.shipment:
        return Icons.local_shipping_outlined;
      case RecordType.lead:
        return Icons.handshake_outlined;
      case RecordType.visitor:
        return Icons.badge_outlined;
    }
  }

  static RecordType fromKey(String key) {
    return RecordType.values.firstWhere(
      (type) => type.storageKey == key,
      orElse: () => RecordType.shipment,
    );
  }
}

enum OpsStatus { planned, active, waiting, completed }

extension OpsStatusText on OpsStatus {
  String get label {
    switch (this) {
      case OpsStatus.planned:
        return 'Planned';
      case OpsStatus.active:
        return 'Active';
      case OpsStatus.waiting:
        return 'Waiting';
      case OpsStatus.completed:
        return 'Complete';
    }
  }

  String get storageKey {
    switch (this) {
      case OpsStatus.planned:
        return 'planned';
      case OpsStatus.active:
        return 'active';
      case OpsStatus.waiting:
        return 'waiting';
      case OpsStatus.completed:
        return 'completed';
    }
  }

  static OpsStatus fromKey(String key) {
    return OpsStatus.values.firstWhere(
      (status) => status.storageKey == key,
      orElse: () => OpsStatus.planned,
    );
  }
}

class OpsRecord {
  const OpsRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.reference,
    required this.contact,
    required this.status,
    required this.dueDate,
    required this.notes,
  });

  final String id;
  final RecordType type;
  final String title;
  final String reference;
  final String contact;
  final OpsStatus status;
  final DateTime dueDate;
  final String notes;

  OpsRecord copyWith({
    String? id,
    RecordType? type,
    String? title,
    String? reference,
    String? contact,
    OpsStatus? status,
    DateTime? dueDate,
    String? notes,
  }) {
    return OpsRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      reference: reference ?? this.reference,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.storageKey,
      'title': title,
      'reference': reference,
      'contact': contact,
      'status': status.storageKey,
      'dueDate': dueDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory OpsRecord.fromJson(Map<String, dynamic> json) {
    return OpsRecord(
      id: json['id'] as String,
      type: RecordTypeText.fromKey(json['type'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      status: OpsStatusText.fromKey(json['status'] as String? ?? ''),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class OperationsHome extends StatefulWidget {
  const OperationsHome({
    required this.store,
    required this.useScreenshotData,
    super.key,
  });

  final OpsStore store;
  final bool useScreenshotData;

  @override
  State<OperationsHome> createState() => _OperationsHomeState();
}

class _OperationsHomeState extends State<OperationsHome> {
  var _records = <OpsRecord>[];
  var _loading = true;
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (widget.useScreenshotData) {
      setState(() {
        _records = sampleRecords(DateTime(2026, 5, 12));
        _loading = false;
      });
      return;
    }

    final stored = await widget.store.loadRecords();
    final records = stored.isEmpty ? sampleRecords(DateTime.now()) : stored;
    if (stored.isEmpty) {
      await widget.store.saveRecords(records);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _saveRecord(OpsRecord record) async {
    setState(() {
      final index = _records.indexWhere((entry) => entry.id == record.id);
      if (index == -1) {
        _records = [record, ..._records];
      } else {
        final next = [..._records];
        next[index] = record;
        _records = next;
      }
    });
    if (!widget.useScreenshotData) {
      await widget.store.saveRecords(_records);
    }
  }

  Future<void> _deleteRecord(String id) async {
    setState(() {
      _records = _records.where((record) => record.id != id).toList();
    });
    if (!widget.useScreenshotData) {
      await widget.store.saveRecords(_records);
    }
  }

  Future<void> _resetRecords() async {
    final records = sampleRecords(DateTime.now());
    setState(() {
      _records = records;
    });
    if (!widget.useScreenshotData) {
      await widget.store.clearRecords();
      await widget.store.saveRecords(records);
    }
  }

  Future<void> _openRecord(OpsRecord record) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(
          record: record,
          onSave: _saveRecord,
          onDelete: _deleteRecord,
        ),
      ),
    );
  }

  Future<void> _createRecord([RecordType? type]) async {
    final record = await Navigator.of(context).push<OpsRecord>(
      MaterialPageRoute(
        builder: (_) =>
            EditRecordPage(initialType: type ?? _typeForCurrentTab()),
      ),
    );
    if (record != null) {
      await _saveRecord(record);
    }
  }

  RecordType _typeForCurrentTab() {
    switch (_selectedIndex) {
      case 1:
        return RecordType.shipment;
      case 2:
        return RecordType.lead;
      case 3:
        return RecordType.visitor;
      default:
        return RecordType.shipment;
    }
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return appTitle;
      case 1:
        return 'Shipment Log';
      case 2:
        return 'Lead Board';
      case 3:
        return 'Visitor Desk';
      default:
        return 'Settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        records: _records,
        onOpen: _openRecord,
        onCreate: _createRecord,
      ),
      TypedRecordsScreen(
        title: 'ROUILLON ISABELLE',
        subtitle: 'Containers, delivery references, and transport follow-up.',
        type: RecordType.shipment,
        records: _records,
        onOpen: _openRecord,
        onCreate: _createRecord,
      ),
      TypedRecordsScreen(
        title: 'Lead Board',
        subtitle: 'Commercial leads with next contact owners and due dates.',
        type: RecordType.lead,
        records: _records,
        onOpen: _openRecord,
        onCreate: _createRecord,
      ),
      TypedRecordsScreen(
        title: 'Visitor Desk',
        subtitle: 'Expected arrivals, hosts, and front-desk status.',
        type: RecordType.visitor,
        records: _records,
        onOpen: _openRecord,
        onCreate: _createRecord,
      ),
      SettingsScreen(records: _records, onReset: _resetRecords),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          if (_selectedIndex != 4)
            IconButton(
              tooltip: 'Add record',
              onPressed: () => _createRecord(),
              icon: const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: _selectedIndex == 4
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createRecord(),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Ship',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.records,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  final List<OpsRecord> records;
  final ValueChanged<OpsRecord> onOpen;
  final ValueChanged<RecordType> onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = records.where(
      (record) => record.status != OpsStatus.completed,
    );
    final nextItems = [...active]
      ..sort((left, right) => left.dueDate.compareTo(right.dueDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'docs/icon.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operations control room',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${active.length} active items across shipments, leads, and visits',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: .86),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final type in RecordType.values)
              SizedBox(
                width: _metricWidth(context),
                child: MetricTile(
                  label: type.plural,
                  value: records.where((record) => record.type == type).length,
                  icon: type.icon,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Quick capture',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                label: 'Shipment',
                icon: Icons.local_shipping_outlined,
                onPressed: () => onCreate(RecordType.shipment),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuickActionButton(
                label: 'Lead',
                icon: Icons.handshake_outlined,
                onPressed: () => onCreate(RecordType.lead),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuickActionButton(
                label: 'Visitor',
                icon: Icons.badge_outlined,
                onPressed: () => onCreate(RecordType.visitor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Next actions',
          subtitle: 'Sorted by the nearest follow-up date.',
        ),
        const SizedBox(height: 8),
        if (nextItems.isEmpty)
          const EmptyState(
            icon: Icons.task_alt,
            title: 'All clear',
            message: 'Completed work stays available in each section.',
          )
        else
          ...nextItems
              .take(5)
              .map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RecordCard(
                    record: record,
                    onTap: () => onOpen(record),
                  ),
                ),
              ),
      ],
    );
  }

  double _metricWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 520) {
      return (width - 42) / 2;
    }
    return (width - 52) / 3;
  }
}

class TypedRecordsScreen extends StatefulWidget {
  const TypedRecordsScreen({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.records,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  final String title;
  final String subtitle;
  final RecordType type;
  final List<OpsRecord> records;
  final ValueChanged<OpsRecord> onOpen;
  final ValueChanged<RecordType> onCreate;

  @override
  State<TypedRecordsScreen> createState() => _TypedRecordsScreenState();
}

class _TypedRecordsScreenState extends State<TypedRecordsScreen> {
  OpsStatus? _status;

  @override
  Widget build(BuildContext context) {
    final typedRecords =
        widget.records
            .where((record) => record.type == widget.type)
            .where((record) => _status == null || record.status == _status)
            .toList()
          ..sort((left, right) => left.dueDate.compareTo(right.dueDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        SectionHeader(title: widget.title, subtitle: widget.subtitle),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                avatar: const Icon(Icons.view_list_outlined, size: 18),
                label: const Text('All'),
                selected: _status == null,
                onSelected: (_) {
                  setState(() {
                    _status = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              for (final status in OpsStatus.values) ...[
                FilterChip(
                  label: Text(status.label),
                  selected: _status == status,
                  onSelected: (_) {
                    setState(() {
                      _status = status;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (typedRecords.isEmpty)
          EmptyState(
            icon: widget.type.icon,
            title: 'No records here',
            message:
                'Add a ${widget.type.label.toLowerCase()} to start tracking it.',
            actionLabel: 'Add ${widget.type.label}',
            onAction: () => widget.onCreate(widget.type),
          )
        else
          ...typedRecords.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecordCard(
                record: record,
                onTap: () => widget.onOpen(record),
              ),
            ),
          ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.records,
    required this.onReset,
    super.key,
  });

  final List<OpsRecord> records;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'Local workspace',
          subtitle:
              'Records stay on this device. There is no account, sync, or external service.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: const Icon(Icons.business_center_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Operations, leads, shipments, and visitor notes',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                SettingRow(
                  icon: Icons.storage_outlined,
                  label: 'Saved records',
                  value: '${records.length}',
                ),
                const SizedBox(height: 10),
                const SettingRow(
                  icon: Icons.cloud_off_outlined,
                  label: 'Cloud sync',
                  value: 'Off',
                ),
                const SizedBox(height: 10),
                const SettingRow(
                  icon: Icons.lock_outline,
                  label: 'Data sharing',
                  value: 'None',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The app stores shipment logs, container references, lead notes, visitor entries, and preferences locally on the device.',
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restore_outlined),
                  label: const Text('Restore starter records'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    required this.record,
    required this.onSave,
    required this.onDelete,
    super.key,
  });

  final OpsRecord record;
  final ValueChanged<OpsRecord> onSave;
  final ValueChanged<String> onDelete;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late OpsRecord _record = widget.record;

  Future<void> _editRecord() async {
    final updated = await Navigator.of(context).push<OpsRecord>(
      MaterialPageRoute(builder: (_) => EditRecordPage(record: _record)),
    );
    if (updated == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    widget.onSave(updated);
    setState(() {
      _record = updated;
    });
  }

  void _deleteRecord() {
    widget.onDelete(_record.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_record.type.label),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _editRecord,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: _deleteRecord,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(status: _record.status),
                    const SizedBox(height: 12),
                    Text(
                      _record.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _record.reference,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(height: 30),
                    DetailLine(
                      icon: Icons.person_outline,
                      label: 'Owner or contact',
                      value: _record.contact,
                    ),
                    const SizedBox(height: 14),
                    DetailLine(
                      icon: Icons.event_outlined,
                      label: 'Next follow-up',
                      value: formatDate(_record.dueDate),
                    ),
                    const SizedBox(height: 14),
                    DetailLine(
                      icon: _record.type.icon,
                      label: 'Record type',
                      value: _record.type.label,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_record.notes),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditRecordPage extends StatefulWidget {
  const EditRecordPage({super.key, this.record, this.initialType});

  final OpsRecord? record;
  final RecordType? initialType;

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _referenceController;
  late final TextEditingController _contactController;
  late final TextEditingController _notesController;
  late RecordType _type;
  late OpsStatus _status;
  late int _dueDays;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _type = record?.type ?? widget.initialType ?? RecordType.shipment;
    _status = record?.status ?? OpsStatus.planned;
    final storedDueDays = record?.dueDate.difference(DateTime.now()).inDays;
    _dueDays = record == null
        ? 1
        : _normalizeDueDays((storedDueDays?.clamp(0, 30) ?? 1).toInt());
    _titleController = TextEditingController(text: record?.title ?? '');
    _referenceController = TextEditingController(text: record?.reference ?? '');
    _contactController = TextEditingController(text: record?.contact ?? '');
    _notesController = TextEditingController(text: record?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _referenceController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final record = OpsRecord(
      id: widget.record?.id ?? now.microsecondsSinceEpoch.toString(),
      type: _type,
      title: _titleController.text.trim(),
      reference: _referenceController.text.trim(),
      contact: _contactController.text.trim(),
      status: _status,
      dueDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: _dueDays)),
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'New record' : 'Edit record'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              DropdownButtonFormField<RecordType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Record type'),
                items: [
                  for (final type in RecordType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('titleField'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Container arrival, lead name, or visitor purpose',
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('referenceField'),
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  hintText: 'Container ID, lead code, or badge number',
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('contactField'),
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Owner or contact',
                  hintText: 'Internal owner, carrier, host, or client',
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OpsStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final status in OpsStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _dueDays,
                decoration: const InputDecoration(labelText: 'Follow-up'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Today')),
                  DropdownMenuItem(value: 1, child: Text('Tomorrow')),
                  DropdownMenuItem(value: 3, child: Text('In 3 days')),
                  DropdownMenuItem(value: 7, child: Text('Next week')),
                  DropdownMenuItem(value: 14, child: Text('In 2 weeks')),
                  DropdownMenuItem(value: 30, child: Text('In 30 days')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _dueDays = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('notesField'),
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
                minLines: 4,
                maxLines: 6,
                validator: _required,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save record'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  int _normalizeDueDays(int days) {
    const choices = [0, 1, 3, 7, 14, 30];
    return choices.reduce((closest, choice) {
      final currentDistance = (choice - days).abs();
      final closestDistance = (closest - days).abs();
      return currentDistance < closestDistance ? choice : closest;
    });
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  const RecordCard({required this.record, required this.onTap, super.key});

  final OpsRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      record.type.icon,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${record.reference} - ${record.contact}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusChip(status: record.status),
                  const Spacer(),
                  Icon(
                    Icons.event_outlined,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(formatDate(record.dueDate)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final OpsStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF173343),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color statusColor(OpsStatus status) {
  switch (status) {
    case OpsStatus.planned:
      return const Color(0xFF426076);
    case OpsStatus.active:
      return const Color(0xFF0D7C66);
    case OpsStatus.waiting:
      return const Color(0xFF9B6B14);
    case OpsStatus.completed:
      return const Color(0xFF59616A);
  }
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

List<OpsRecord> sampleRecords(DateTime baseDate) {
  final base = DateTime(baseDate.year, baseDate.month, baseDate.day);
  return [
    OpsRecord(
      id: 'shipment-1',
      type: RecordType.shipment,
      title: 'Marseille inbound container',
      reference: 'MSCU-742918',
      contact: 'Port operations',
      status: OpsStatus.active,
      dueDate: base.add(const Duration(days: 1)),
      notes:
          'Confirm seal number, customs file, and yard slot before afternoon dispatch.',
    ),
    OpsRecord(
      id: 'shipment-2',
      type: RecordType.shipment,
      title: 'Lyon retail pallet group',
      reference: 'LYN-8840',
      contact: 'Carrier desk',
      status: OpsStatus.waiting,
      dueDate: base.add(const Duration(days: 3)),
      notes:
          'Await carrier confirmation and keep the consignee updated after the depot scan.',
    ),
    OpsRecord(
      id: 'lead-1',
      type: RecordType.lead,
      title: 'New exporter onboarding',
      reference: 'LEAD-204',
      contact: 'Claire Martin',
      status: OpsStatus.planned,
      dueDate: base.add(const Duration(days: 2)),
      notes:
          'Prepare first quote, shipment profile, and a simple next-step checklist.',
    ),
    OpsRecord(
      id: 'lead-2',
      type: RecordType.lead,
      title: 'Renew warehouse service',
      reference: 'LEAD-219',
      contact: 'Benoit Finance',
      status: OpsStatus.active,
      dueDate: base.add(const Duration(days: 5)),
      notes:
          'Compare last quarter handling volume with proposed monthly service bands.',
    ),
    OpsRecord(
      id: 'visitor-1',
      type: RecordType.visitor,
      title: 'Carrier yard check-in',
      reference: 'VIS-1187',
      contact: 'Gate host',
      status: OpsStatus.active,
      dueDate: base,
      notes:
          'Driver is expected with container paperwork and needs a loading bay badge.',
    ),
    OpsRecord(
      id: 'visitor-2',
      type: RecordType.visitor,
      title: 'Supplier audit visit',
      reference: 'VIS-1202',
      contact: 'Operations office',
      status: OpsStatus.planned,
      dueDate: base.add(const Duration(days: 7)),
      notes:
          'Reserve meeting room, visitor badges, and a short warehouse safety brief.',
    ),
  ];
}

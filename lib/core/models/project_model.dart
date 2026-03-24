import 'package:uuid/uuid.dart';

// Project model for Dashboard screen
class ForgeProject {
  final String id;
  String name;
  String description;
  DateTime lastEdited;
  int screenCount;
  int widgetCount;
  String? thumbnailColor; // for colored card preview

  ForgeProject({
    String? id,
    required this.name,
    this.description = '',
    DateTime? lastEdited,
    this.screenCount = 1,
    this.widgetCount = 0,
    this.thumbnailColor,
  })  : id = id ?? const Uuid().v4(),
        lastEdited = lastEdited ?? DateTime.now();

  String get lastEditedLabel {
    final diff = DateTime.now().difference(lastEdited);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'lastEdited': lastEdited.toIso8601String(),
    'screenCount': screenCount, 'widgetCount': widgetCount,
    'thumbnailColor': thumbnailColor,
  };

  factory ForgeProject.fromJson(Map<String, dynamic> j) => ForgeProject(
    id: j['id'], name: j['name'],
    description: j['description'] ?? '',
    lastEdited: DateTime.parse(j['lastEdited']),
    screenCount: j['screenCount'] ?? 1,
    widgetCount: j['widgetCount'] ?? 0,
    thumbnailColor: j['thumbnailColor'],
  );

  // Sample projects for first run
  static List<ForgeProject> samples() => [
    ForgeProject(name: 'E-commerce App', description: 'Shopping UI',
        thumbnailColor: '#1976D2', screenCount: 5, widgetCount: 32),
    ForgeProject(name: 'Task Manager', description: 'Todo app',
        thumbnailColor: '#43A047', screenCount: 3, widgetCount: 18),
    ForgeProject(name: 'Social App', description: 'Social feed',
        thumbnailColor: '#E53935', screenCount: 4, widgetCount: 24),
    ForgeProject(name: 'Sorix Media', description: 'Media player',
        thumbnailColor: '#7B1FA2', screenCount: 2, widgetCount: 15),
  ];
}

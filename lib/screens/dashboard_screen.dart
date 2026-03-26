import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/project_model.dart';
import '../core/providers/forge_provider.dart';
import '../ui/theme.dart';
import '../core/models/widget_node.dart' show parseColor;
import 'builder_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ForgeProject> _projects = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadProjects(); }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('gax_projects');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        setState(() {
          _projects = list.map((e) => ForgeProject.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
        return;
      } catch (_) {}
    }
    setState(() { _projects = ForgeProject.samples(); _loading = false; });
    _saveProjects();
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gax_projects', jsonEncode(_projects.map((p) => p.toJson()).toList()));
  }

  void _openProject(ForgeProject project) {
    context.read<ForgeProvider>().clearAll();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => BuilderScreen(project: project),
    )).then((_) {
      final provider = context.read<ForgeProvider>();
      setState(() {
        final idx = _projects.indexWhere((p) => p.id == project.id);
        if (idx >= 0) {
          _projects[idx].lastEdited = DateTime.now();
          _projects[idx].widgetCount = provider.currentScreen.nodes.length;
          _projects[idx].screenCount = provider.screens.length;
        }
      });
      _saveProjects();
    });
  }

  Future<void> _createProject() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('New Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl, autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. E-commerce App', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Create')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      const colors = ['#1976D2','#43A047','#E53935','#7B1FA2','#FF7043','#00ACC1','#F9A825'];
      final project = ForgeProject(name: result.trim(), thumbnailColor: colors[_projects.length % colors.length]);
      setState(() => _projects.insert(0, project));
      _saveProjects();
      _openProject(project);
    }
  }

  Future<void> _deleteProject(ForgeProject project) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('"${project.name}" permanently delete ho jayega.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: ForgeTheme.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) { setState(() => _projects.removeWhere((p) => p.id == project.id)); _saveProjects(); }
  }

  Future<void> _renameProject(ForgeProject project) async {
    final ctrl = TextEditingController(text: project.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() { final idx = _projects.indexWhere((p) => p.id == project.id); if (idx >= 0) _projects[idx].name = result.trim(); });
      _saveProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgeTheme.bg,
      appBar: AppBar(
        backgroundColor: ForgeTheme.primary,
        leading: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.menu, color: Colors.white, size: 22)),
        title: const Text('My Flutter Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _createProject),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? _EmptyState(onCreate: _createProject)
              : GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82,
                  ),
                  itemCount: _projects.length,
                  itemBuilder: (_, i) => _ProjectCard(
                    project: _projects[i],
                    onTap: () => _openProject(_projects[i]),
                    onDelete: () => _deleteProject(_projects[i]),
                    onRename: () => _renameProject(_projects[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        backgroundColor: ForgeTheme.fabColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ForgeProject project;
  final VoidCallback onTap, onDelete, onRename;
  const _ProjectCard({required this.project, required this.onTap, required this.onDelete, required this.onRename});

  @override
  Widget build(BuildContext context) {
    final color = parseColor(project.thumbnailColor, fallback: ForgeTheme.primary);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ForgeTheme.surface1,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 75, height: 105,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
                          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10)],
                        ),
                        child: Column(children: [
                          Container(height: 18, decoration: BoxDecoration(
                            color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))),
                          const SizedBox(height: 6),
                          ...List.generate(4, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Container(height: 5,
                              decoration: BoxDecoration(color: color.withOpacity(i == 0 ? 0.35 : 0.12),
                                  borderRadius: BorderRadius.circular(3))),
                          )),
                          const SizedBox(height: 5),
                          Container(height: 10, width: 44,
                            decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(5))),
                        ]),
                      ),
                    ),
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                        child: Text('${project.screenCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: const TextStyle(color: ForgeTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('Last Edit: ${project.lastEditedLabel}', style: const TextStyle(color: ForgeTheme.textMuted, fontSize: 10)),
                    ],
                  )),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 16, color: ForgeTheme.textMuted),
                    onSelected: (v) { if (v == 'rename') onRename(); if (v == 'delete') onDelete(); },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'rename', height: 36, child: Text('Rename', style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(value: 'delete', height: 36, child: Text('Delete', style: TextStyle(color: ForgeTheme.danger, fontSize: 13))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.folder_open_outlined, size: 64, color: ForgeTheme.textMuted),
      const SizedBox(height: 16),
      const Text('No projects yet', style: TextStyle(color: ForgeTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('New Project')),
    ]),
  );
}

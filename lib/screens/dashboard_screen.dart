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
  String _search = '';
  final _searchCtrl = TextEditingController();
  bool _searchMode = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('gax_projects');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        final loaded = list
            .map((e) => ForgeProject.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() { _projects = loaded; _loading = false; });
        return;
      } catch (_) {}
    }
    // First run — only ONE sample project "Test1"
    setState(() {
      _projects = [
        ForgeProject(
          name: 'Test1',
          description: 'My first project',
          thumbnailColor: '#1976D2',
          screenCount: 1,
          widgetCount: 0,
        ),
      ];
      _loading = false;
    });
    _saveProjects();
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'gax_projects', jsonEncode(_projects.map((p) => p.toJson()).toList()));
  }

  void _openProject(ForgeProject project) async {
    final provider = context.read<ForgeProvider>();
    await provider.clearAll();
    await provider.loadProject(project.id);

    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => BuilderScreen(project: project),
    ));

    if (!mounted) return;
    setState(() {
      final idx = _projects.indexWhere((p) => p.id == project.id);
      if (idx >= 0) {
        _projects[idx].lastEdited = DateTime.now();
        _projects[idx].widgetCount = provider.currentScreen.nodes.length;
        _projects[idx].screenCount = provider.screens.length;
      }
    });
    _saveProjects();
  }

  Future<void> _createProject() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('New Project',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. My App',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      const colors = ['#1976D2','#43A047','#E53935','#7B1FA2',
                      '#FF7043','#00ACC1','#F9A825','#AD1457'];
      final project = ForgeProject(
        name: result.trim(),
        thumbnailColor: colors[_projects.length % colors.length],
      );
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
        content: Text('"${project.name}" delete ho jayega.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: ForgeTheme.danger),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Also delete saved canvas data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gax_project_${project.id}');
      setState(() => _projects.removeWhere((p) => p.id == project.id));
      _saveProjects();
    }
  }

  Future<void> _renameProject(ForgeProject project) async {
    final ctrl = TextEditingController(text: project.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        final idx = _projects.indexWhere((p) => p.id == project.id);
        if (idx >= 0) _projects[idx].name = result.trim();
      });
      _saveProjects();
    }
  }

  List<ForgeProject> get _filtered => _search.isEmpty
      ? _projects
      : _projects
          .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgeTheme.bg,
      drawer: _AppDrawer(
        projects: _projects,
        onOpenProject: _openProject,
        onCreateProject: _createProject,
      ),
      appBar: _searchMode ? _buildSearchBar() : _buildNormalBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? _EmptyState(onCreate: _createProject)
              : GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _ProjectCard(
                    project: _filtered[i],
                    onTap: () => _openProject(_filtered[i]),
                    onDelete: () => _deleteProject(_filtered[i]),
                    onRename: () => _renameProject(_filtered[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        backgroundColor: ForgeTheme.fabColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildNormalBar() {
    return AppBar(
      backgroundColor: ForgeTheme.primary,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text('My Flutter Projects',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => setState(() { _searchMode = true; }),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: _createProject,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return AppBar(
      backgroundColor: ForgeTheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => setState(() {
          _searchMode = false;
          _search = '';
          _searchCtrl.clear();
        }),
      ),
      title: TextField(
        controller: _searchCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
        onChanged: (v) => setState(() => _search = v),
      ),
      actions: [
        if (_search.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() {
              _search = '';
              _searchCtrl.clear();
            }),
          ),
      ],
    );
  }
}

// ── Hamburger Drawer ──────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final List<ForgeProject> projects;
  final ValueChanged<ForgeProject> onOpenProject;
  final VoidCallback onCreateProject;

  const _AppDrawer({
    required this.projects,
    required this.onOpenProject,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(color: ForgeTheme.primary),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 28),
                ),
                SizedBox(height: 12),
                Text('GAX Forge',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text('Flutter UI Builder',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.add_circle_outline,
                  label: 'New Project',
                  onTap: () {
                    Navigator.pop(context);
                    onCreateProject();
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Recent Projects',
                      style: TextStyle(
                          fontSize: 11,
                          color: ForgeTheme.textMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                ),
                ...projects.take(6).map((p) {
                  final color = parseColor(
                      p.thumbnailColor, fallback: ForgeTheme.primary);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.phone_android,
                          size: 16, color: color),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(p.lastEditedLabel,
                        style: const TextStyle(
                            fontSize: 11, color: ForgeTheme.textMuted)),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenProject(p);
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  );
                }),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'About GAX Forge',
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'GAX Forge',
                      applicationVersion: 'v2.0',
                      applicationIcon: const Icon(
                          Icons.auto_awesome_rounded,
                          color: ForgeTheme.primary, size: 40),
                      children: const [
                        Text('Professional Flutter UI Builder\nby ArnabLabZ Studio'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'GAX Forge v2.0 • ArnabLabZ',
              style: TextStyle(color: ForgeTheme.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ForgeTheme.textSecondary, size: 22),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: ForgeTheme.textPrimary)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ── Project Card ──────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final ForgeProject project;
  final VoidCallback onTap, onDelete, onRename;
  const _ProjectCard(
      {required this.project,
      required this.onTap,
      required this.onDelete,
      required this.onRename});

  @override
  Widget build(BuildContext context) {
    final color =
        parseColor(project.thumbnailColor, fallback: ForgeTheme.primary);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(children: [
                  Center(
                    child: Container(
                      width: 75, height: 106,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                            color: color.withOpacity(0.22), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(children: [
                        Container(
                          height: 18,
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5)))),
                        const SizedBox(height: 6),
                        ...List.generate(
                            4,
                            (i) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  child: Container(
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: color.withOpacity(
                                              i == 0 ? 0.35 : 0.12),
                                          borderRadius:
                                              BorderRadius.circular(3))),
                                )),
                        const SizedBox(height: 5),
                        Container(
                            height: 10, width: 44,
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(5))),
                      ]),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${project.screenCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: const TextStyle(
                            color: ForgeTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Last Edit: ${project.lastEditedLabel}',
                        style: const TextStyle(
                            color: ForgeTheme.textMuted, fontSize: 10)),
                  ],
                )),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 16, color: ForgeTheme.textMuted),
                  onSelected: (v) {
                    if (v == 'rename') onRename();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'rename',
                        height: 36,
                        child: Text('Rename',
                            style: TextStyle(fontSize: 13))),
                    const PopupMenuItem(
                        value: 'delete',
                        height: 36,
                        child: Text('Delete',
                            style: TextStyle(
                                color: ForgeTheme.danger,
                                fontSize: 13))),
                  ],
                ),
              ]),
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open_outlined,
                  size: 64, color: ForgeTheme.textMuted),
              const SizedBox(height: 16),
              const Text('No projects',
                  style: TextStyle(
                      color: ForgeTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('New Project')),
            ]),
      );
}

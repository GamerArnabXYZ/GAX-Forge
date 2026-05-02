// lib/screens/home/home_screen.dart
// GAX Forge - Home / Dashboard Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_models.dart';
import '../../providers/project_provider.dart';
import '../editor/editor_screen.dart';
import 'widgets/project_card.dart';
import 'widgets/create_project_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isGrid = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final scheme = Theme.of(context).colorScheme;

    final filtered = projects
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: _buildDrawer(context, projects),
      body: CustomScrollView(
        slivers: [
          // ── Large App Bar ──────────────────
          SliverAppBar.large(
            title: const Text(
              'GAX Forge',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Menu',
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => _isGrid = !_isGrid),
                tooltip: _isGrid ? 'List View' : 'Grid View',
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: _searchCtrl,
                  hintText: 'Search projects...',
                  leading: const Icon(Icons.search_rounded),
                  trailing: _searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        ]
                      : null,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
          ),

          // ── Stats Row ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.folder_rounded,
                    label: '${projects.length} Projects',
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  if (_searchQuery.isNotEmpty)
                    _StatChip(
                      icon: Icons.filter_list_rounded,
                      label: '${filtered.length} Results',
                      color: scheme.secondary,
                    ),
                ],
              ),
            ),
          ),

          // ── Projects ──────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 80, color: scheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No projects found'
                          : 'No projects yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first project',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.outlineVariant,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else if (_isGrid)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ProjectCard(
                    project: filtered[i],
                    onTap: () => _openProject(filtered[i]),
                    onDelete: () => _deleteProject(filtered[i]),
                    onRename: () => _renameProject(filtered[i]),
                  ),
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ProjectCard(
                    project: filtered[i],
                    onTap: () => _openProject(filtered[i]),
                    onDelete: () => _deleteProject(filtered[i]),
                    onRename: () => _renameProject(filtered[i]),
                    listMode: true,
                  ),
                ),
                childCount: filtered.length,
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
        heroTag: 'fab_home',
      ),
    );
  }

  // ── Drawer ────────────────────────────────
  Widget _buildDrawer(BuildContext context, List<GaxProject> projects) {
    final scheme = Theme.of(context).colorScheme;
    final recent = projects.take(5).toList();

    return NavigationDrawer(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 8),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.architecture_rounded,
                    color: scheme.onPrimaryContainer, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GAX Forge',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                  ),
                  Text(
                    'v1.0.0 • by ArnabLabZ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(indent: 28, endIndent: 28),

        // Navigation items
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_rounded),
          label: const Text('Home'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.info_outline_rounded),
          label: const Text('About App'),
        ),

        // Recent Projects
        if (recent.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
            child: Text(
              'Recent Projects',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.outline,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
            ),
          ),
          ...recent.map((p) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                leading: CircleAvatar(
                  backgroundColor: Color(p.thumbnailColor),
                  radius: 18,
                  child: Text(
                    p.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(p.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${p.screens.length} screen${p.screens.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openProject(p);
                },
              )),
        ],
      ],
      onDestinationSelected: (i) {
        Navigator.pop(context);
        if (i == 1) _showAbout(context);
      },
      selectedIndex: 0,
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GAX Forge',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 52),
      applicationLegalese: '© 2025 ArnabLabZ Studio',
      children: [
        const SizedBox(height: 12),
        const Text(
          'GAX Forge is a professional Flutter UI design maker for mobile devices. '
          'Design, preview, and export Flutter UI code directly from your phone.',
        ),
      ],
    );
  }

  void _openProject(GaxProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(projectId: project.id),
      ),
    );
  }

  Future<void> _createProject() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const CreateProjectDialog(),
    );
    if (result == null) return;

    final project = GaxProject(
      name: result['name']!,
      description: result['description'] ?? '',
      thumbnailColor: int.tryParse(result['color'] ?? '') ?? 0xFF6750A4,
    );
    await ref.read(projectsProvider.notifier).addProject(project);
  }

  Future<void> _deleteProject(GaxProject project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(projectsProvider.notifier).deleteProject(project.id);
    }
  }

  Future<void> _renameProject(GaxProject project) async {
    final ctrl = TextEditingController(text: project.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Project Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final updated = project.copyWith(name: result.trim());
      await ref.read(projectsProvider.notifier).updateProject(updated);
    }
    ctrl.dispose();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide.none,
    );
  }
}

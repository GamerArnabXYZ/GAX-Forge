import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'widgets_tab.dart';
import 'canvas_tab.dart';
import 'preview_tab.dart';

/// Project Screen - main editor screen with bottom navigation
/// Yahan se 3 tabs access hain: Widgets, Canvas, Preview
class ProjectScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  int _currentIndex = 1; // Start with Canvas tab

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() {
    final project = ref.read(projectByIdProvider(widget.projectId));
    if (project != null) {
      ref.read(canvasProvider.notifier).initializeFromProject(project);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectByIdProvider(widget.projectId));

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Not Found')),
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(project),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          WidgetsTab(),
          CanvasTab(),
          PreviewTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Build app bar with project name and export button
  PreferredSizeWidget _buildAppBar(ProjectModel project) {
    return AppBar(
      title: GestureDetector(
        onTap: () => _renameProject(project),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(project.name),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
      actions: [
        // Undo button
        Consumer(
          builder: (context, ref, _) {
            final canUndo = ref.watch(canUndoProvider);
            return IconButton(
              icon: Icon(Icons.undo, color: canUndo ? null : Colors.grey.shade400),
              onPressed: canUndo ? () => ref.read(canvasProvider.notifier).undo() : null,
              tooltip: 'Undo',
            );
          },
        ),
        // Redo button
        Consumer(
          builder: (context, ref, _) {
            final canRedo = ref.watch(canRedoProvider);
            return IconButton(
              icon: Icon(Icons.redo, color: canRedo ? null : Colors.grey.shade400),
              onPressed: canRedo ? () => ref.read(canvasProvider.notifier).redo() : null,
              tooltip: 'Redo',
            );
          },
        ),
        // Export button
        IconButton(
          icon: const Icon(Icons.code),
          onPressed: () => _showExportSheet(project),
          tooltip: 'Export Code',
        ),
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, project),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Save Project'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear Canvas'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'properties',
              child: Row(
                children: [
                  Icon(Icons.tune),
                  SizedBox(width: 8),
                  Text('Canvas Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.widgets_outlined),
          selectedIcon: Icon(Icons.widgets),
          label: 'Widgets',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(Icons.edit),
          label: 'Canvas',
        ),
        NavigationDestination(
          icon: Icon(Icons.visibility_outlined),
          selectedIcon: Icon(Icons.visibility),
          label: 'Preview',
        ),
      ],
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action, ProjectModel project) {
    switch (action) {
      case 'save':
        _saveProject(project);
        break;
      case 'clear':
        _clearCanvas();
        break;
      case 'properties':
        _showCanvasSettings();
        break;
    }
  }

  /// Rename project dialog
  void _renameProject(ProjectModel project) {
    final controller = TextEditingController(text: project.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              project.name = value.trim();
              ref.read(projectListProvider.notifier).saveProject(project);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                project.name = name;
                ref.read(projectListProvider.notifier).saveProject(project);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  /// Save project
  void _saveProject(ProjectModel project) {
    // Update project with current canvas widgets
    project.widgets = ref.read(canvasProvider).widgets;
    ref.read(projectListProvider.notifier).saveProject(project);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved successfully')),
    );
  }

  /// Clear canvas with confirmation
  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear all widgets? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(canvasProvider.notifier).clearCanvas();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Show canvas settings
  void _showCanvasSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canvas Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final canvasState = ref.watch(canvasProvider);
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Show Grid'),
                      value: canvasState.showGrid,
                      onChanged: (_) => ref.read(canvasProvider.notifier).toggleGrid(),
                    ),
                    SwitchListTile(
                      title: const Text('Show Rulers'),
                      value: canvasState.showRulers,
                      onChanged: (_) => ref.read(canvasProvider.notifier).toggleRulers(),
                    ),
                    ListTile(
                      title: const Text('Zoom Level'),
                      trailing: Text('${(canvasState.zoom * 100).toInt()}%'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show export bottom sheet
  void _showExportSheet(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExportBottomSheet(project: project),
    );
  }
}

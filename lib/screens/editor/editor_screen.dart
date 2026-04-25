// lib/screens/editor/editor_screen.dart
// GAX Forge - Main Editor Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../utils/export_utils.dart';
import '../../utils/json_io.dart';
import '../widgets/canvas/canvas_area.dart';
import '../widgets/panels/widget_library_panel.dart';
import '../widgets/panels/properties_panel.dart';

class EditorScreen extends ConsumerWidget {
  final String projectId;
  const EditorScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.watch(editorProvider(projectId));
    final notifier = ref.read(editorProvider(projectId).notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: _buildAppBar(context, ref, editor, notifier, scheme),
      body: IndexedStack(
        index: editor.activeTab == 0 ? 1 : 0,
        children: [
          // Canvas + Preview
          Stack(
            children: [
              CanvasArea(projectId: projectId),
              // Floating properties panel when widget is selected
              if (editor.canvasLocked && editor.selectedWidgetId != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PropertiesPanel(projectId: projectId),
                ),
            ],
          ),
          // Widget Library
          WidgetLibraryPanel(projectId: projectId),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(editor, notifier, scheme),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    EditorState editor,
    EditorNotifier notifier,
    ColorScheme scheme,
  ) {
    return AppBar(
      title: _ScreenSwitcher(
        projectId: projectId,
        editor: editor,
        notifier: notifier,
      ),
      actions: [
        // Undo
        IconButton(
          icon: const Icon(Icons.undo_rounded),
          onPressed:
              editor.undoStack.isNotEmpty ? notifier.undo : null,
          tooltip: 'Undo',
        ),
        // Redo
        IconButton(
          icon: const Icon(Icons.redo_rounded),
          onPressed:
              editor.redoStack.isNotEmpty ? notifier.redo : null,
          tooltip: 'Redo',
        ),
        // Lock
        IconButton(
          icon: Icon(editor.canvasLocked
              ? Icons.lock_rounded
              : Icons.lock_open_rounded),
          onPressed: notifier.toggleLock,
          tooltip: editor.canvasLocked ? 'Unlock Canvas' : 'Lock Canvas',
          color: editor.canvasLocked ? scheme.primary : null,
        ),
        // 3-dot menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (v) => _onMenuSelected(context, ref, v, notifier),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'save',
              child: ListTile(
                leading: Icon(Icons.save_rounded),
                title: Text('Save'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.code_rounded),
                title: Text('Export to Dart'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'json_export',
              child: ListTile(
                leading: Icon(Icons.upload_rounded),
                title: Text('Export JSON'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'json_import',
              child: ListTile(
                leading: Icon(Icons.download_rounded),
                title: Text('Import JSON'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'add_screen',
              child: ListTile(
                leading: Icon(Icons.add_to_photos_rounded),
                title: Text('Add Screen'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'bg_color',
              child: ListTile(
                leading: Icon(Icons.format_color_fill_rounded),
                title: Text('Canvas Background'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(
    EditorState editor,
    EditorNotifier notifier,
    ColorScheme scheme,
  ) {
    return NavigationBar(
      selectedIndex: editor.activeTab,
      onDestinationSelected: notifier.setTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.widgets_outlined),
          selectedIcon: Icon(Icons.widgets_rounded),
          label: 'Widgets',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(Icons.edit_rounded),
          label: 'Canvas',
        ),
        NavigationDestination(
          icon: Icon(Icons.visibility_outlined),
          selectedIcon: Icon(Icons.visibility_rounded),
          label: 'Preview',
        ),
      ],
    );
  }

  Future<void> _onMenuSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
    EditorNotifier notifier,
  ) async {
    switch (value) {
      case 'save':
        await notifier.save();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project saved!'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'export':
        final editor = ref.read(editorProvider(projectId));
        await ExportUtils.exportProject(context, editor.project);
        break;
      case 'add_screen':
        notifier.addScreen();
        break;
      case 'bg_color':
        _pickBgColor(context, notifier);
        break;
      case 'json_export':
        final proj = ref.read(editorProvider(projectId)).project;
        final idx = ref.read(editorProvider(projectId)).activeScreenIndex;
        JsonIO.showExportDialog(context, proj, idx);
        break;
      case 'json_import':
        final imported = await JsonIO.showImportDialog(context);
        if (imported != null && context.mounted) {
          await ref.read(projectsProvider.notifier).addProject(imported);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imported: ${imported.name}'),
                  behavior: SnackBarBehavior.floating));
          }
        }
        break;
    }
  }

  void _pickBgColor(BuildContext context, EditorNotifier notifier) {
    final colors = [
      Colors.white, Colors.black, Colors.grey.shade100,
      Colors.grey.shade900, const Color(0xFFFFFBFE),
      const Color(0xFF1C1B1F), Colors.blue.shade50, Colors.green.shade50,
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Canvas Background',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors
                  .map((c) => GestureDetector(
                        onTap: () {
                          notifier.setCanvasBackground(c.value);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Screen Switcher Dropdown ───────────────────
class _ScreenSwitcher extends ConsumerWidget {
  final String projectId;
  final EditorState editor;
  final EditorNotifier notifier;

  const _ScreenSwitcher({
    required this.projectId,
    required this.editor,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screens = editor.project.screens;

    return PopupMenuButton<int>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              screens[editor.activeScreenIndex].name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down_rounded),
        ],
      ),
      onSelected: (i) {
        if (i == -1) {
          notifier.addScreen();
        } else {
          notifier.switchScreen(i);
        }
      },
      itemBuilder: (_) => [
        ...screens.asMap().entries.map((e) => PopupMenuItem<int>(
              value: e.key,
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    size: 18,
                    color: e.key == editor.activeScreenIndex
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.value.name,
                    style: TextStyle(
                      fontWeight: e.key == editor.activeScreenIndex
                          ? FontWeight.bold
                          : null,
                      color: e.key == editor.activeScreenIndex
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            )),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          value: -1,
          child: Row(
            children: [
              Icon(Icons.add_rounded),
              SizedBox(width: 8),
              Text('Add Screen'),
            ],
          ),
        ),
      ],
    );
  }
}

// lib/screens/editor/editor_screen.dart
// GAX Forge - Main Editor Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/screen_sizes.dart';
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
    final isPreview = editor.previewMode || editor.activeTab == 2;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      // Hide appBar + bottomNav in preview mode
      appBar: isPreview
          ? null
          : _buildAppBar(context, ref, editor, notifier, scheme),
      body: IndexedStack(
        index: editor.activeTab == 0 ? 1 : 0,
        children: [
          // Canvas + Properties panel
          Stack(children: [
            CanvasArea(projectId: projectId),
            if (!isPreview && editor.canvasLocked && editor.selectedWidgetId != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: PropertiesPanel(projectId: projectId),
              ),
          ]),
          // Widget Library
          WidgetLibraryPanel(projectId: projectId),
        ],
      ),
      bottomNavigationBar: isPreview ? null : _buildBottomNav(editor, notifier),
    );
  }

  // ── AppBar ─────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
      EditorState editor, EditorNotifier notifier, ColorScheme scheme) {
    return AppBar(
      title: _ScreenSwitcher(projectId: projectId, editor: editor, notifier: notifier),
      actions: [
        // Undo
        IconButton(
          icon: const Icon(Icons.undo_rounded),
          onPressed: editor.undoStack.isNotEmpty ? notifier.undo : null,
          tooltip: 'Undo',
        ),
        // Redo
        IconButton(
          icon: const Icon(Icons.redo_rounded),
          onPressed: editor.redoStack.isNotEmpty ? notifier.redo : null,
          tooltip: 'Redo',
        ),
        // Lock
        IconButton(
          icon: Icon(editor.canvasLocked ? Icons.lock_rounded : Icons.lock_open_rounded),
          onPressed: notifier.toggleLock,
          tooltip: editor.canvasLocked ? 'Unlock Canvas' : 'Lock Canvas',
          color: editor.canvasLocked ? scheme.primary : null,
        ),
        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (v) => _onMenuSelected(context, ref, v, notifier),
          itemBuilder: (_) => [
            _menuItem('save', Icons.save_rounded, 'Save'),
            _menuItem('export', Icons.code_rounded, 'Export Dart'),
            _menuItem('json_export', Icons.upload_rounded, 'Export JSON'),
            _menuItem('json_import', Icons.download_rounded, 'Import JSON'),
            const PopupMenuDivider(),
            _menuItem('add_screen', Icons.add_to_photos_rounded, 'Add Screen'),
            _menuItem('bg_color', Icons.format_color_fill_rounded, 'Canvas Background'),
            _menuItem('preview', Icons.visibility_rounded, 'Preview Mode'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) =>
      PopupMenuItem(
        value: value,
        child: ListTile(
          leading: Icon(icon), title: Text(label),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      );

  // ── Bottom Nav ─────────────────────────────
  Widget _buildBottomNav(EditorState editor, EditorNotifier notifier) =>
      NavigationBar(
        selectedIndex: editor.activeTab,
        onDestinationSelected: notifier.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.widgets_outlined),
              selectedIcon: Icon(Icons.widgets_rounded), label: 'Widgets'),
          NavigationDestination(icon: Icon(Icons.edit_outlined),
              selectedIcon: Icon(Icons.edit_rounded), label: 'Canvas'),
          NavigationDestination(icon: Icon(Icons.visibility_outlined),
              selectedIcon: Icon(Icons.visibility_rounded), label: 'Preview'),
        ],
      );

  // ── Menu Handler ───────────────────────────
  Future<void> _onMenuSelected(BuildContext context, WidgetRef ref,
      String value, EditorNotifier notifier) async {
    switch (value) {
      case 'save':
        await notifier.save();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Project saved!'), behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2)));
        }
        break;
      case 'export':
        final ed = ref.read(editorProvider(projectId));
        await ExportUtils.exportProject(context, ed.project);
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Imported: ${imported.name}'),
              behavior: SnackBarBehavior.floating));
          }
        }
        break;
      case 'add_screen':
        notifier.addScreen();
        break;
      case 'bg_color':
        _pickBgColor(context, notifier);
        break;
      case 'preview':
        notifier.setTab(2);
        break;
    }
  }

  // ── Background Color Picker ─────────────────
  void _pickBgColor(BuildContext context, EditorNotifier notifier) {
    final colors = [
      Colors.white, Colors.black, Colors.grey.shade100, Colors.grey.shade900,
      const Color(0xFFFFFBFE), const Color(0xFF1C1B1F),
      Colors.blue.shade50, Colors.green.shade50, Colors.purple.shade50,
      Colors.orange.shade50,
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Canvas Background', style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: colors.map((c) =>
            GestureDetector(
              onTap: () { notifier.setCanvasBackground(c.value); Navigator.pop(ctx); },
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: c,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(ctx).colorScheme.outline))),
            )).toList()),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SCREEN SWITCHER — full rename/delete/add
// ══════════════════════════════════════════════
class _ScreenSwitcher extends ConsumerWidget {
  final String projectId;
  final EditorState editor;
  final EditorNotifier notifier;
  const _ScreenSwitcher({required this.projectId,
      required this.editor, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screens = editor.project.screens;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showScreenManager(context, screens, scheme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.phone_android_rounded, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              screens[editor.activeScreenIndex].name,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.arrow_drop_down_rounded, size: 18, color: scheme.onSurface),
        ]),
      ),
    );
  }

  void _showScreenManager(BuildContext context,
      List screens, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState2) {
          final currentScreens = editor.project.screens;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16,
                MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Handle
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2))),
              // Header
              Row(children: [
                Icon(Icons.layers_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Screens (${currentScreens.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  onPressed: () { notifier.addScreen(); Navigator.pop(ctx); },
                ),
              ]),
              const SizedBox(height: 10),
              // Screen list — reorderable
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentScreens.length,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  // reorder screens in state
                  final screens2 = List.from(currentScreens);
                  final item = screens2.removeAt(oldIdx);
                  screens2.insert(newIdx, item);
                  notifier.reorderScreens(List.from(screens2));
                },
                itemBuilder: (ctx2, i) {
                  final s = currentScreens[i];
                  final isActive = i == editor.activeScreenIndex;
                  final device = ScreenSizeCatalog.findById(s.screenSize);
                  return Card(
                    key: ValueKey(s.id),
                    margin: const EdgeInsets.only(bottom: 4),
                    color: isActive ? scheme.primaryContainer : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isActive ? scheme.primary : scheme.surfaceContainerHighest,
                        child: Icon(device.icon, size: 14,
                            color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant),
                      ),
                      title: Text(s.name, style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : null,
                          color: isActive ? scheme.onPrimaryContainer : null)),
                      subtitle: Text('${device.name}  •  ${s.widgets.length} widgets',
                          style: const TextStyle(fontSize: 10)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        // Rename
                        IconButton(
                          icon: Icon(Icons.edit_rounded, size: 16,
                              color: scheme.onSurfaceVariant),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Rename',
                          onPressed: () => _renameScreen(ctx2, i, s.name),
                        ),
                        // Delete (disable if only 1 screen)
                        IconButton(
                          icon: Icon(Icons.delete_rounded, size: 16,
                              color: currentScreens.length > 1
                                  ? scheme.error : scheme.outlineVariant),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Delete',
                          onPressed: currentScreens.length > 1
                              ? () => _deleteScreen(ctx2, i, s.name)
                              : null,
                        ),
                        // Drag handle
                        Icon(Icons.drag_handle_rounded, size: 18,
                            color: scheme.onSurfaceVariant),
                      ]),
                      onTap: () {
                        notifier.switchScreen(i);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ]),
          );
        },
      ),
    );
  }

  void _renameScreen(BuildContext context, int index, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.edit_rounded, size: 20),
          SizedBox(width: 8),
          Text('Rename Screen'),
        ]),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Screen name', border: OutlineInputBorder()),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              notifier.renameScreen(index, v.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                notifier.renameScreen(index, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteScreen(BuildContext context, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Screen'),
        content: Text('Delete "$name"? All widgets on this screen will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              notifier.deleteScreen(index);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(ctx); // close sheet
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

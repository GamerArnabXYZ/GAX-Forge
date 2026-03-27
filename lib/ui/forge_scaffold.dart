import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../canvas/forge_canvas.dart';
import '../panels/layers_panel.dart';
import '../panels/widget_palette.dart';
import '../panels/property_panel.dart';
import '../panels/screen_manager.dart';
import '../panels/code_export.dart';
import '../panels/mini_preview.dart';
import '../ui/theme.dart';
import '../ui/keyboard_handler.dart';
import '../core/models/widget_node.dart';

class ForgeScaffold extends StatelessWidget {
  const ForgeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ForgeKeyboardHandler(
      child: width >= 900 ? const _WideLayout() : const _MobileLayout(),
    );
  }
}

// ── Wide Layout ───────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgeTheme.bg,
      body: Column(
        children: [
          const _TopBar(),
          const ScreenTabBar(),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 220, child: _LeftSidebar()),
                Container(width: 1, color: ForgeTheme.border),
                const Expanded(child: ForgeCanvas()),
                Container(width: 1, color: ForgeTheme.border),
                const SizedBox(width: 260, child: PropertyPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftSidebar extends StatefulWidget {
  const _LeftSidebar();

  @override
  State<_LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<_LeftSidebar>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          color: ForgeTheme.surface1,
          child: TabBar(
            controller: _tab,
            indicatorColor: ForgeTheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: ForgeTheme.textPrimary,
            unselectedLabelColor: ForgeTheme.textMuted,
            labelStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            tabs: const [Tab(text: 'Layers'), Tab(text: 'Widgets')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [LayersPanel(), WidgetPalette()],
          ),
        ),
      ],
    );
  }
}

// ── Mobile Layout ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: ForgeTheme.bg,
          body: Column(
            children: [
              const _TopBar(),
              const ScreenTabBar(),
              Expanded(
                child: IndexedStack(
                  index: provider.activeSidePanel,
                  children: const [
                    LayersPanel(),
                    ForgeCanvas(),
                    PropertyPanel(),
                    WidgetPalette(),
                  ],
                ),
              ),
              _MobileNav(active: provider.activeSidePanel),
            ],
          ),
        );
      },
    );
  }
}

class _MobileNav extends StatelessWidget {
  final int active;
  const _MobileNav({required this.active});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ForgeProvider>();
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: ForgeTheme.surface1,
        border: Border(top: BorderSide(color: ForgeTheme.border)),
      ),
      child: Row(
        children: [
          _NavBtn(0, Icons.layers_outlined, 'Layers', active, provider),
          _NavBtn(1, Icons.phone_android_outlined, 'Canvas', active, provider),
          _NavBtn(2, Icons.tune_rounded, 'Props', active, provider),
          _NavBtn(3, Icons.widgets_outlined, 'Widgets', active, provider),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int active;
  final ForgeProvider provider;

  const _NavBtn(this.index, this.icon, this.label, this.active, this.provider);

  @override
  Widget build(BuildContext context) {
    final isActive = active == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSidePanel(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isActive ? ForgeTheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: isActive
                      ? ForgeTheme.primary : ForgeTheme.textMuted),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    color: isActive
                        ? ForgeTheme.primary : ForgeTheme.textMuted,
                    fontSize: 9,
                    fontWeight: isActive
                        ? FontWeight.w600 : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final isWide = MediaQuery.of(context).size.width >= 900;
        return Container(
          padding: EdgeInsets.only(
              top: topPad + 4, left: 12, right: 8, bottom: 6),
          decoration: const BoxDecoration(
            color: ForgeTheme.surface1,
            border: Border(bottom: BorderSide(color: ForgeTheme.border)),
          ),
          child: Row(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('GAX Forge',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Undo
              Tooltip(
                message: provider.canUndo
                    ? 'Undo: ${provider.undoDesc}  Ctrl+Z' : 'Nothing to undo',
                child: PanelIconBtn(
                  icon: Icons.undo_rounded,
                  onTap: provider.undo,
                  active: provider.canUndo,
                  color: provider.canUndo
                      ? ForgeTheme.textSecondary : ForgeTheme.textMuted,
                ),
              ),

              // Redo
              Tooltip(
                message: provider.canRedo
                    ? 'Redo: ${provider.redoDesc}  Ctrl+Y' : 'Nothing to redo',
                child: PanelIconBtn(
                  icon: Icons.redo_rounded,
                  onTap: provider.redo,
                  active: provider.canRedo,
                  color: provider.canRedo
                      ? ForgeTheme.textSecondary : ForgeTheme.textMuted,
                ),
              ),

              Container(
                  width: 1, height: 20,
                  color: ForgeTheme.border,
                  margin: const EdgeInsets.symmetric(horizontal: 6)),

              // Grid
              Tooltip(
                message: 'Grid  G',
                child: PanelIconBtn(
                  icon: Icons.grid_on_outlined,
                  onTap: provider.toggleGrid,
                  active: provider.showGrid,
                ),
              ),

              // Snap
              Tooltip(
                message: 'Snap to Grid',
                child: PanelIconBtn(
                  icon: Icons.grid_4x4_rounded,
                  onTap: provider.toggleSnap,
                  active: provider.snapToGrid,
                ),
              ),

              const Spacer(),

              // Selected node info
              if (provider.selectedNode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ForgeTheme.selectionBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ForgeTheme.selection
                        .withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.selectedNode!.type.widgetIcon,
                        size: 12,
                        color: ForgeTheme.forWidget(
                            provider.selectedNode!.type.name),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.selectedNode!.displayName,
                        style: const TextStyle(
                            color: ForgeTheme.textSecondary,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                PanelIconBtn(
                  icon: Icons.copy_outlined,
                  onTap: () =>
                      provider.duplicate(provider.selectedId!),
                  tooltip: 'Duplicate  Ctrl+D',
                ),
                PanelIconBtn(
                  icon: Icons.delete_outline_rounded,
                  onTap: provider.deleteSelected,
                  color: ForgeTheme.danger,
                  tooltip: 'Delete  Del',
                ),
                const SizedBox(width: 4),
              ],

              // Preview (wide only)
              if (isWide)
                Tooltip(
                  message: 'Mini preview',
                  child: PanelIconBtn(
                    icon: Icons.phone_iphone_rounded,
                    onTap: () => _showPreview(context),
                    color: ForgeTheme.secondary,
                  ),
                ),

              const SizedBox(width: 4),

              // Export
              GestureDetector(
                onTap: () => showCodeExport(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ForgeTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.code_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Export',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // More
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: ForgeTheme.textSecondary, size: 18),
                color: ForgeTheme.surface2,
                onSelected: (val) async {
                  if (val == 'clear') {
                    final ok = await _confirmClear(context);
                    if (ok == true && context.mounted) {
                      context.read<ForgeProvider>().clearAll();
                    }
                  }
                  if (val == 'shortcuts') _showShortcuts(context);
                },
                itemBuilder: (_) => [
                  _menuItem('shortcuts', Icons.keyboard_outlined,
                      'Shortcuts'),
                  const PopupMenuDivider(),
                  _menuItem('clear', Icons.delete_sweep_outlined,
                      'Clear All', color: ForgeTheme.danger),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: const MiniPreview(),
      ),
    );
  }

  void _showShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        title: const Text('Keyboard Shortcuts',
            style: TextStyle(
                color: ForgeTheme.textPrimary, fontSize: 14)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _shortcutRow('Ctrl+Z', 'Undo'),
              _shortcutRow('Ctrl+Y', 'Redo'),
              _shortcutRow('Ctrl+D', 'Duplicate'),
              _shortcutRow('Delete', 'Delete selected'),
              _shortcutRow('Escape', 'Deselect'),
              _shortcutRow('Arrow keys', 'Nudge 1px'),
              _shortcutRow('Ctrl+Arrow', 'Nudge 10px'),
              _shortcutRow('Ctrl+]', 'Bring to front'),
              _shortcutRow('Ctrl+[', 'Send to back'),
              _shortcutRow('Long press', 'Drag widget from palette'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: ForgeTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _shortcutRow(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ForgeTheme.surface3,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ForgeTheme.border),
            ),
            child: Text(key,
                style: const TextStyle(
                    color: ForgeTheme.textPrimary,
                    fontSize: 11,
                    fontFamily: 'monospace')),
          ),
          Text(action,
              style: const TextStyle(
                  color: ForgeTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Future<bool?> _confirmClear(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        title: const Text('Clear All?',
            style: TextStyle(
                color: ForgeTheme.textPrimary, fontSize: 14)),
        content: const Text('Saari screens aur widgets delete ho jayengi.',
            style: TextStyle(
                color: ForgeTheme.textSecondary, fontSize: 12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: ForgeTheme.danger),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String val, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem(
      value: val,
      height: 36,
      child: Row(
        children: [
          Icon(icon,
              size: 14, color: color ?? ForgeTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: color ?? ForgeTheme.textPrimary,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

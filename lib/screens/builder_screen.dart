import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/project_model.dart';
import '../core/models/widget_node.dart';
import '../core/providers/forge_provider.dart';
import '../canvas/forge_canvas.dart';
import '../panels/widget_palette.dart';
import '../panels/property_panel.dart';
import '../panels/screen_manager.dart';
import '../panels/code_export.dart';
import '../ui/theme.dart';
import '../ui/keyboard_handler.dart';

class BuilderScreen extends StatelessWidget {
  final ForgeProject project;
  const BuilderScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ForgeKeyboardHandler(
      child: Scaffold(
        backgroundColor: ForgeTheme.canvasBg,
        appBar: _BuilderAppBar(project: project),
        body: const _BuilderBody(),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────
class _BuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ForgeProject project;
  const _BuilderAppBar({required this.project});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        return AppBar(
          backgroundColor: ForgeTheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(project.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          actions: [
            // Grid toggle
            IconButton(
              icon: Icon(Icons.grid_on_outlined,
                  color: provider.showGrid
                      ? Colors.white : Colors.white54, size: 20),
              tooltip: 'Toggle Grid',
              onPressed: provider.toggleGrid,
            ),
            // Undo
            IconButton(
              icon: Icon(Icons.undo_rounded,
                  color: provider.canUndo
                      ? Colors.white : Colors.white30, size: 20),
              onPressed: provider.canUndo ? provider.undo : null,
            ),
            // Redo
            IconButton(
              icon: Icon(Icons.redo_rounded,
                  color: provider.canRedo
                      ? Colors.white : Colors.white30, size: 20),
              onPressed: provider.canRedo ? provider.redo : null,
            ),

            // 🔒 Lock button
            Tooltip(
              message: provider.canvasLocked
                  ? 'Unlock'
                  : 'Lock (preview mode)',
              child: IconButton(
                icon: Icon(
                  provider.canvasLocked
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: provider.canvasLocked
                      ? Colors.yellowAccent : Colors.white54,
                  size: 22,
                ),
                onPressed: provider.toggleCanvasLock,
              ),
            ),

            // Save
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () async {
                  await provider.saveProject();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Saved!'),
                        ]),
                        duration: Duration(milliseconds: 1200),
                        backgroundColor: ForgeTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_rounded,
                    color: Colors.white, size: 17),
                label: const Text('Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 13)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Builder Body ──────────────────────────────────────────────
class _BuilderBody extends StatelessWidget {
  const _BuilderBody();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return isWide ? const _WideLayout() : const _MobileLayout();
  }
}

// ── Wide Layout ───────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) => Column(
        children: [
          const ScreenTabBar(),
          // Lock banner
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 72, child: _VerticalPalette()),
                Container(width: 1, color: ForgeTheme.border),
                const Expanded(child: ForgeCanvas()),
                Container(width: 1, color: ForgeTheme.border),
                const SizedBox(width: 280, child: PropertyPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Vertical Palette ──────────────────────────────────────────
class _VerticalPalette extends StatelessWidget {
  const _VerticalPalette();

  static const _quickWidgets = [
    (Icons.text_fields_rounded, 'TEXT', WType.text),
    (Icons.image_outlined, 'IMAGE', WType.image),
    (Icons.emoji_emotions_outlined, 'ICON', WType.icon),
    (Icons.smart_button_outlined, 'BUTTON', WType.button),
    (Icons.format_list_bulleted, 'LIST', WType.listView),
    (Icons.crop_square_rounded, 'BOX', WType.container),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ForgeTheme.surface1,
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(_quickWidgets.length, (idx) {
            final item = _quickWidgets[idx];
            return _PaletteIconBtn(
              icon: item.$1,
              label: item.$2,
              onTap: () {
                final provider = context.read<ForgeProvider>();
                final screen = provider.screen;
                provider.addNode(item.$3,
                    x: screen.canvasWidth / 2 - 60,
                    y: 80.0 + (idx * 60.0));
              },
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => _showFullPalette(context),
            child: Container(
              width: 56, height: 44,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: ForgeTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_view, size: 18, color: ForgeTheme.primary),
                  SizedBox(height: 2),
                  Text('More',
                      style: TextStyle(
                          fontSize: 8, color: ForgeTheme.primary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPalette(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ForgeProvider>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              color: ForgeTheme.surface1,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const WidgetPalette(),
          ),
        ),
      ),
    );
  }
}

class _PaletteIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PaletteIconBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Icon(icon, size: 24, color: ForgeTheme.textSecondary),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 8, color: ForgeTheme.textMuted,
                  fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}

// ── Mobile Layout ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) => Column(
        children: [
          const ScreenTabBar(),
          Expanded(
            child: IndexedStack(
              index: provider.activeSidePanel,
              children: const [
                ForgeCanvas(),
                WidgetPalette(),
                PropertyPanel(),
              ],
            ),
          ),
          _MobileBottomNav(active: provider.activeSidePanel),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final int active;
  const _MobileBottomNav({required this.active});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ForgeProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: ForgeTheme.surface1,
        border: Border(top: BorderSide(color: ForgeTheme.border)),
      ),
      child: Row(children: [
        _BottomBtn(0, Icons.phone_android_outlined, 'Canvas', active, provider),
        _BottomBtn(1, Icons.widgets_outlined, 'Widgets', active, provider),
        _BottomBtn(2, Icons.tune_rounded, 'Properties', active, provider),
      ]),
    );
  }
}

class _BottomBtn extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int active;
  final ForgeProvider provider;
  const _BottomBtn(this.index, this.icon, this.label, this.active, this.provider);

  @override
  Widget build(BuildContext context) {
    final isActive = active == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSidePanel(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(
                color: isActive ? ForgeTheme.primary : Colors.transparent,
                width: 2)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20,
                color: isActive ? ForgeTheme.primary : ForgeTheme.textMuted),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: isActive ? ForgeTheme.primary : ForgeTheme.textMuted,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
            )),
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../ui/theme.dart';

// Top screen tab bar
class ScreenTabBar extends StatelessWidget {
  const ScreenTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 36,
          decoration: const BoxDecoration(
            color: ForgeTheme.surface1,
            border: Border(bottom: BorderSide(color: ForgeTheme.border)),
          ),
          child: Row(
            children: [
              // Screen tabs
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: provider.screens.length,
                  itemBuilder: (_, i) => _ScreenTab(index: i),
                ),
              ),
              // Add screen
              GestureDetector(
                onTap: provider.addScreen,
                child: Tooltip(
                  message: 'Add screen',
                  child: Container(
                    width: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(color: ForgeTheme.border)),
                    ),
                    child: const Icon(Icons.add,
                        size: 16, color: ForgeTheme.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScreenTab extends StatelessWidget {
  final int index;
  const _ScreenTab({required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgeProvider>();
    final screen = provider.screens[index];
    final isActive = provider.currentScreenIndex == index;

    return GestureDetector(
      onTap: () => provider.switchScreen(index),
      onLongPress: () => _showRename(context, provider, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? ForgeTheme.surface3 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isActive
              ? Border.all(color: ForgeTheme.border)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_android_outlined,
              size: 11,
              color: isActive
                  ? ForgeTheme.primary : ForgeTheme.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              screen.name,
              style: TextStyle(
                color: isActive
                    ? ForgeTheme.textPrimary : ForgeTheme.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (provider.screens.length > 1) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => provider.deleteScreen(index),
                child: const Icon(Icons.close,
                    size: 10, color: ForgeTheme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRename(BuildContext context, ForgeProvider provider, int index) {
    final ctrl = TextEditingController(
        text: provider.screens[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        title: const Text('Rename Screen',
            style: TextStyle(
                color: ForgeTheme.textPrimary, fontSize: 14)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: ForgeTheme.textPrimary),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ForgeTheme.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ForgeTheme.primary)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.renameScreen(index, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Rename',
                style: TextStyle(color: ForgeTheme.primary)),
          ),
        ],
      ),
    );
  }
}

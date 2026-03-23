import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';

// Keyboard shortcuts wrapper — entire app ko wrap karta hai
class ForgeKeyboardHandler extends StatefulWidget {
  final Widget child;
  const ForgeKeyboardHandler({super.key, required this.child});

  @override
  State<ForgeKeyboardHandler> createState() => _ForgeKeyboardHandlerState();
}

class _ForgeKeyboardHandlerState extends State<ForgeKeyboardHandler> {
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final provider = context.read<ForgeProvider>();
    final ctrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    switch (event.logicalKey) {
      // Delete / Backspace — delete selected
      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        if (provider.selectedNodeId != null) {
          provider.deleteSelected();
          return KeyEventResult.handled;
        }

      // Ctrl+Z — undo
      case LogicalKeyboardKey.keyZ:
        if (ctrl) {
          provider.undo();
          return KeyEventResult.handled;
        }

      // Ctrl+Y / Ctrl+Shift+Z — redo
      case LogicalKeyboardKey.keyY:
        if (ctrl) {
          provider.redo();
          return KeyEventResult.handled;
        }

      // Ctrl+D — duplicate selected
      case LogicalKeyboardKey.keyD:
        if (ctrl && provider.selectedNodeId != null) {
          provider.duplicateNode(provider.selectedNodeId!);
          return KeyEventResult.handled;
        }

      // Escape — deselect
      case LogicalKeyboardKey.escape:
        provider.clearSelection();
        return KeyEventResult.handled;

      // Arrow keys — nudge selected node
      case LogicalKeyboardKey.arrowLeft:
        _nudge(provider, dx: ctrl ? -10 : -1, dy: 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _nudge(provider, dx: ctrl ? 10 : 1, dy: 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _nudge(provider, dx: 0, dy: ctrl ? -10 : -1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _nudge(provider, dx: 0, dy: ctrl ? 10 : 1);
        return KeyEventResult.handled;

      // Ctrl+] — bring to front
      case LogicalKeyboardKey.bracketRight:
        if (ctrl && provider.selectedNodeId != null) {
          provider.bringToFront(provider.selectedNodeId!);
          return KeyEventResult.handled;
        }

      // Ctrl+[ — send to back
      case LogicalKeyboardKey.bracketLeft:
        if (ctrl && provider.selectedNodeId != null) {
          provider.sendToBack(provider.selectedNodeId!);
          return KeyEventResult.handled;
        }

      default:
        break;
    }

    return KeyEventResult.ignored;
  }

  void _nudge(ForgeProvider provider,
      {required double dx, required double dy}) {
    final node = provider.selectedNode;
    if (node == null) return;
    provider.updateNodePos(node.id, node.x + dx, node.y + dy);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        onTap: () => _focus.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}

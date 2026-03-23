import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../canvas/widget_renderer.dart';
import '../ui/theme.dart';

// Floating mini-preview — current design ka phone-frame preview
class MiniPreview extends StatelessWidget {
  const MiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final screen = provider.currentScreen;
        const previewW = 180.0;
        final scale = previewW / screen.canvasWidth;
        final previewH = screen.canvasHeight * scale;

        return Container(
          width: previewW + 24,
          decoration: BoxDecoration(
            color: ForgeTheme.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ForgeTheme.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: ForgeTheme.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android,
                        size: 13, color: ForgeTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(screen.name,
                          style: const TextStyle(
                              color: ForgeTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                        '${screen.canvasWidth.round()}×${screen.canvasHeight.round()}',
                        style: const TextStyle(
                            color: ForgeTheme.textMuted,
                            fontSize: 9,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),

              // Phone frame
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: previewW + 16,
                  height: previewH + 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: ForgeTheme.surface4, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Notch
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(
                          color: ForgeTheme.surface4,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Screen preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: previewW,
                          height: previewH,
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: screen.canvasWidth,
                              height: screen.canvasHeight,
                              child: Stack(
                                children: [
                                  // BG color
                                  Positioned.fill(
                                    child: Container(
                                      color: parseColor(
                                          screen.backgroundColor,
                                          fallback: Colors.white),
                                    ),
                                  ),
                                  // Widgets
                                  ...screen.sortedNodes
                                      .where((n) => n.visible)
                                      .map((n) => Positioned(
                                            left: n.x,
                                            top: n.y,
                                            width: n.width,
                                            height: n.height,
                                            child: IgnorePointer(
                                              child: WidgetRenderer(
                                                  node: n),
                                            ),
                                          )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Home bar
                      Container(
                        margin: const EdgeInsets.only(
                            top: 8, bottom: 6),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ForgeTheme.surface4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Widget count
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${screen.nodes.length} widget${screen.nodes.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: ForgeTheme.textMuted, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

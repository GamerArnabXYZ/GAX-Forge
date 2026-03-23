import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../codegen/dart_codegen.dart';
import '../codegen/stateful_codegen.dart';
import '../ui/theme.dart';

void showCodeExport(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ForgeProvider>(),
      child: const _CodeExportSheet(),
    ),
  );
}

class _CodeExportSheet extends StatefulWidget {
  const _CodeExportSheet();

  @override
  State<_CodeExportSheet> createState() => _CodeExportSheetState();
}

class _CodeExportSheetState extends State<_CodeExportSheet> {
  int _mode = 0;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgeProvider>();

    String code;
    if (_mode == 1) {
      code = DartCodeGen.generateProject(provider.screens);
    } else if (_mode == 2) {
      code = StatefulCodeGen.generateStatefulScreen(provider.currentScreen);
    } else {
      code = DartCodeGen.generateScreen(provider.currentScreen);
    }

    final lineCount = code.split('\n').length;
    final charCount = code.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.4,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: ForgeTheme.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: const Border(top: BorderSide(color: ForgeTheme.border)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: ForgeTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: ForgeTheme.border))),
                child: Row(
                  children: [
                    const Icon(Icons.code_rounded, color: ForgeTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    const Text('Export Dart Code',
                        style: TextStyle(color: ForgeTheme.textPrimary,
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: ForgeTheme.surface3,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('$lineCount lines · $charCount chars',
                          style: const TextStyle(color: ForgeTheme.textMuted,
                              fontSize: 10, fontFamily: 'monospace')),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        setState(() => _copied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _copied = false);
                        });
                      },
                      icon: Icon(_copied ? Icons.check : Icons.copy, size: 14),
                      label: Text(_copied ? 'Copied!' : 'Copy',
                          style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copied ? Colors.green : ForgeTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ModeBtn(label: '📄 Screen', active: _mode == 0,
                          onTap: () => setState(() => _mode = 0)),
                      const SizedBox(width: 8),
                      _ModeBtn(label: '📦 Full Project', active: _mode == 1,
                          onTap: () => setState(() => _mode = 1)),
                      const SizedBox(width: 8),
                      _ModeBtn(label: '⚡ StatefulWidget', active: _mode == 2,
                          onTap: () => setState(() => _mode = 2)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070710),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ForgeTheme.border),
                  ),
                  child: SingleChildScrollView(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      code,
                      style: const TextStyle(fontFamily: 'monospace',
                          fontSize: 12, height: 1.7, color: Color(0xFF98E4FF)),
                    ),
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

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? ForgeTheme.primary : ForgeTheme.surface3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? ForgeTheme.primary : ForgeTheme.border),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : ForgeTheme.textSecondary,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }
}

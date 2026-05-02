// lib/utils/json_io.dart
// GAX Forge - JSON Import/Export for projects

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';

class JsonIO {
  // ── Export project to JSON file and share ──
  static Future<void> exportProject(BuildContext context, GaxProject project) async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(project.toJson());
      final dir = await getTemporaryDirectory();
      final safeName = project.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final file = File('${dir.path}/${safeName}_gaxforge.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: '${project.name} - GAX Forge Project',
        text: 'GAX Forge project: ${project.name}\n'
            '${project.screens.length} screen(s), '
            '${project.screens.fold(0, (s, sc) => s + sc.widgets.length)} widget(s)',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ── Export single screen ──
  static Future<void> exportScreen(BuildContext context, GaxProject project, int screenIndex) async {
    try {
      final screen = project.screens[screenIndex];
      final data = screen.toJson();
      data['_gaxforge_type'] = 'screen';
      data['_project_name'] = project.name;
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final safeName = screen.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final file = File('${dir.path}/${safeName}_screen.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/json')],
          subject: '${screen.name} - GAX Forge Screen');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ── Export as JSON string (for copy) ──
  static String exportToString(GaxProject project) {
    return const JsonEncoder.withIndent('  ').convert(project.toJson());
  }

  // ── Import project from JSON string ──
  static GaxProject? importFromString(String jsonStr) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return GaxProject.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Show import dialog with text paste ──
  static Future<GaxProject?> showImportDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    GaxProject? result;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.upload_file_rounded),
          SizedBox(width: 8),
          Text('Import Project'),
        ]),
        content: SizedBox(
          width: 320, height: 220,
          child: TextField(
            controller: ctrl,
            maxLines: null, expands: true,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
              border: OutlineInputBorder(), isDense: true,
            ),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Import'),
            onPressed: () {
              final project = importFromString(ctrl.text.trim());
              if (project != null) {
                result = project;
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Invalid JSON format'), backgroundColor: Colors.red));
              }
            },
          ),
        ],
      ),
    );
    return result;
  }

  // ── Show export options dialog ──
  static void showExportDialog(BuildContext context, GaxProject project, int currentScreenIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Text('Export', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.folder_zip_rounded)),
            title: const Text('Export Full Project'),
            subtitle: Text('${project.screens.length} screens, '
                '${project.screens.fold(0, (s, sc) => s + sc.widgets.length)} widgets'),
            onTap: () { Navigator.pop(ctx); exportProject(context, project); },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.layers_rounded)),
            title: const Text('Export Current Screen'),
            subtitle: Text(project.screens[currentScreenIndex].name),
            onTap: () { Navigator.pop(ctx); exportScreen(context, project, currentScreenIndex); },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.copy_rounded)),
            title: const Text('Copy JSON to Clipboard'),
            onTap: () {
              Navigator.pop(ctx);
              final json = exportToString(project);
              // Copy to clipboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${json.length} chars copied!'),
                  action: SnackBarAction(label: 'OK', onPressed: () {}),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

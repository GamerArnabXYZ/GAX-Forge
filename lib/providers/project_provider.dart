import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

/// Project list state - all saved projects yahan store hain
class ProjectListNotifier extends StateNotifier<List<ProjectModel>> {
  ProjectListNotifier() : super([]);

  /// Load all projects from storage
  Future<void> loadProjects() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/gax_forge_projects');

      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
        state = [];
        return;
      }

      final projects = <ProjectModel>[];
      await for (var entity in projectsDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final content = await entity.readAsString();
            final json = jsonDecode(content) as Map<String, dynamic>;
            projects.add(ProjectModel.fromJson(json));
          } catch (e) {
            // Skip corrupted files
            print('Error loading project: ${entity.path} - $e');
          }
        }
      }

      // Sort by updated date (newest first)
      projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = projects;
    } catch (e) {
      print('Error loading projects: $e');
      state = [];
    }
  }

  /// Create new project
  Future<ProjectModel> createProject(String name) async {
    final project = ProjectModel(name: name);
    await _saveProjectToStorage(project);
    state = [project, ...state];
    return project;
  }

  /// Save project to storage
  Future<void> saveProject(ProjectModel project) async {
    project.touch();
    await _saveProjectToStorage(project);

    // Update state
    final index = state.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      final newState = List<ProjectModel>.from(state);
      newState[index] = project;
      // Re-sort by updated date
      newState.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = newState;
    }
  }

  /// Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gax_forge_projects/$projectId.json');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting project file: $e');
    }

    state = state.where((p) => p.id != projectId).toList();
  }

  /// Duplicate project
  Future<ProjectModel> duplicateProject(ProjectModel project) async {
    final duplicate = project.duplicate();
    await _saveProjectToStorage(duplicate);
    state = [duplicate, ...state];
    return duplicate;
  }

  /// Internal method to save project to file
  Future<void> _saveProjectToStorage(ProjectModel project) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/gax_forge_projects');

      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      final file = File('${projectsDir.path}/${project.id}.json');
      await file.writeAsString(jsonEncode(project.toJson()));
    } catch (e) {
      print('Error saving project: $e');
      rethrow;
    }
  }
}

/// Provider for project list
final projectListProvider = StateNotifierProvider<ProjectListNotifier, List<ProjectModel>>((ref) {
  return ProjectListNotifier();
});

/// Provider to get single project by ID
final projectByIdProvider = Provider.family<ProjectModel?, String>((ref, id) {
  final projects = ref.watch(projectListProvider);
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

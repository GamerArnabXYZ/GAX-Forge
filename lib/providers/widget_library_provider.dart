import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Widget library provider - available widgets ki list maintain karta hai
/// User is library se widgets select karke canvas pe add kar sakta hai

/// Widget library item - ek widget type ka metadata
class WidgetLibraryItem {
  final WidgetType type;
  final String displayName;
  final IconData icon;
  final WidgetCategory category;

  const WidgetLibraryItem({
    required this.type,
    required this.displayName,
    required this.icon,
    required this.category,
  });
}

/// Icon mapping for widget types
IconData getIconForWidgetType(WidgetType type) {
  switch (type) {
    case WidgetType.container:
      return Icons.crop_square;
    case WidgetType.row:
      return Icons.view_week;
    case WidgetType.column:
      return Icons.view_agenda;
    case WidgetType.stack:
      return Icons.layers;
    case WidgetType.wrap:
      return Icons.wrap_text;
    case WidgetType.padding:
      return Icons.padding;
    case WidgetType.center:
      return Icons.center_focus_strong;
    case WidgetType.expanded:
      return Icons.open_in_full;
    case WidgetType.flexible:
      return Icons.swap_horiz;
    case WidgetType.text:
      return Icons.text_fields;
    case WidgetType.icon:
      return Icons.star;
    case WidgetType.image:
      return Icons.image;
    case WidgetType.iconButton:
      return Icons.smart_button;
    case WidgetType.elevatedButton:
      return Icons.smart_button;
    case WidgetType.textButton:
      return Icons.text_fields;
    case WidgetType.outlinedButton:
      return Icons.border_button;
    case WidgetType.card:
      return Icons.credit_card;
    case WidgetType.containerDecorated:
      return Icons.crop_square;
    case WidgetType.appBar:
      return Icons.app_settings_alt;
    case WidgetType.scaffold:
      return Icons.web;
    case WidgetType.listTile:
      return Icons.list;
    case WidgetType.circleAvatar:
      return Icons.account_circle;
    case WidgetType.divider:
      return Icons.horizontal_rule;
    case WidgetType.chip:
      return Icons.label;
    case WidgetType.badge:
      return Icons.notification_add;
    case WidgetType.linearProgressIndicator:
      return Icons.linear_scale;
    case WidgetType.circularProgressIndicator:
      return Icons.autorenew;
    case WidgetType.switchWidget:
      return Icons.toggle_on;
    case WidgetType.checkbox:
      return Icons.check_box;
    case WidgetType.radio:
      return Icons.radio_button_checked;
  }
}

/// All available widgets in library
final widgetLibraryProvider = Provider<List<WidgetLibraryItem>>((ref) {
  return WidgetType.values.map((type) {
    return WidgetLibraryItem(
      type: type,
      displayName: type.displayName,
      icon: getIconForWidgetType(type),
      category: type.category,
    );
  }).toList();
});

/// Widgets filtered by category
final widgetByCategoryProvider = Provider.family<List<WidgetLibraryItem>, WidgetCategory?>((ref, category) {
  final allWidgets = ref.watch(widgetLibraryProvider);
  if (category == null) return allWidgets;
  return allWidgets.where((w) => w.category == category).toList();
});

/// Search filter provider
final widgetSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered widgets based on search
final filteredWidgetLibraryProvider = Provider<List<WidgetLibraryItem>>((ref) {
  final query = ref.watch(widgetSearchQueryProvider).toLowerCase();
  final allWidgets = ref.watch(widgetLibraryProvider);

  if (query.isEmpty) return allWidgets;
  return allWidgets.where((w) {
    return w.displayName.toLowerCase().contains(query) ||
           w.type.category.displayName.toLowerCase().contains(query);
  }).toList();
});

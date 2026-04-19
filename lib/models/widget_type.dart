import 'package:flutter/material.dart';

/// Widget type enumeration - yahan se available widgets define hain
enum WidgetType {
  // Layout widgets
  container('Container', WidgetCategory.layout),
  row('Row', WidgetCategory.layout),
  column('Column', WidgetCategory.layout),
  stack('Stack', WidgetCategory.layout),
  wrap('Wrap', WidgetCategory.layout),
  padding('Padding', WidgetCategory.layout),
  center('Center', WidgetCategory.layout),
  expanded('Expanded', WidgetCategory.layout),
  flexible('Flexible', WidgetCategory.layout),

  // Basic widgets
  text('Text', WidgetCategory.basic),
  icon('Icon', WidgetCategory.basic),
  image('Image', WidgetCategory.basic),
  iconButton('IconButton', WidgetCategory.basic),
  elevatedButton('ElevatedButton', WidgetCategory.basic),
  textButton('TextButton', WidgetCategory.basic),
  outlinedButton('OutlinedButton', WidgetCategory.basic),
  card('Card', WidgetCategory.basic),
  containerDecorated('Container(Decorated)', WidgetCategory.basic),

  // Complex widgets
  appBar('AppBar', WidgetCategory.complex),
  scaffold('Scaffold', WidgetCategory.complex),
  listTile('ListTile', WidgetCategory.complex),
  circleAvatar('CircleAvatar', WidgetCategory.complex),
  divider('Divider', WidgetCategory.complex),
  chip('Chip', WidgetCategory.complex),
  badge('Badge', WidgetCategory.complex),
  linearProgressIndicator('LinearProgressIndicator', WidgetCategory.complex),
  circularProgressIndicator('CircularProgressIndicator', WidgetCategory.complex),
  switchWidget('Switch', WidgetCategory.complex),
  checkbox('Checkbox', WidgetCategory.complex),
  radio('Radio', WidgetCategory.complex);

  final String displayName;
  final WidgetCategory category;

  const WidgetType(this.displayName, this.category);

  /// Widget type se Flutter widget create karne ke liye helper method
  static Widget createDefaultWidget(WidgetType type, {String? widgetId}) {
    switch (type) {
      case WidgetType.container:
        return Container(color: Colors.grey.shade200);
      case WidgetType.row:
        return Row(children: []);
      case WidgetType.column:
        return Column(children: []);
      case WidgetType.stack:
        return Stack(children: []);
      case WidgetType.wrap:
        return Wrap(children: []);
      case WidgetType.padding:
        return Padding(padding: EdgeInsets.all(8), child: Container());
      case WidgetType.center:
        return Center(child: Container());
      case WidgetType.expanded:
        return Expanded(child: Container());
      case WidgetType.flexible:
        return Flexible(child: Container());
      case WidgetType.text:
        return Text('Text Sample', style: TextStyle(fontSize: 16));
      case WidgetType.icon:
        return Icon(Icons.star, size: 24, color: Colors.grey);
      case WidgetType.image:
        return Image.network('https://picsum.photos/100', width: 100, height: 100, errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey.shade300, child: Icon(Icons.image, color: Colors.grey)));
      case WidgetType.iconButton:
        return IconButton(icon: Icon(Icons.add), onPressed: () {});
      case WidgetType.elevatedButton:
        return ElevatedButton(onPressed: () {}, child: Text('Button'));
      case WidgetType.textButton:
        return TextButton(onPressed: () {}, child: Text('Text Button'));
      case WidgetType.outlinedButton:
        return OutlinedButton(onPressed: () {}, child: Text('Outlined'));
      case WidgetType.card:
        return Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Card Content')));
      case WidgetType.containerDecorated:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: Center(child: Text('Decorated')),
        );
      case WidgetType.appBar:
        return AppBar(title: Text('AppBar'), automaticallyImplyLeading: false);
      case WidgetType.scaffold:
        return Scaffold(
          appBar: AppBar(title: Text('Scaffold')),
          body: Container(color: Colors.white),
        );
      case WidgetType.listTile:
        return ListTile(title: Text('ListTile'), leading: Icon(Icons.list));
      case WidgetType.circleAvatar:
        return CircleAvatar(child: Text('A'), backgroundColor: Colors.blue);
      case WidgetType.divider:
        return Divider();
      case WidgetType.chip:
        return Chip(label: Text('Chip'));
      case WidgetType.badge:
        return Badge(label: Text('1'), child: Icon(Icons.notifications));
      case WidgetType.linearProgressIndicator:
        return LinearProgressIndicator();
      case WidgetType.circularProgressIndicator:
        return CircularProgressIndicator();
      case WidgetType.switchWidget:
        return Switch(value: false, onChanged: (_) {});
      case WidgetType.checkbox:
        return Checkbox(value: false, onChanged: (_) {});
      case WidgetType.radio:
        return Radio(value: 'a', groupValue: null, onChanged: (_) {});
    }
  }
}

/// Widget categories for organization
enum WidgetCategory {
  layout('Layout'),
  basic('Basic'),
  complex('Complex');

  final String displayName;
  const WidgetCategory(this.displayName);
}

# 🔥 GAX Forge v2 — Professional Flutter UI Builder

> FlutterFlow-inspired visual UI builder — 100% native Flutter APK

---

## 🚀 Setup

```bash
cd gax_forge_v2
flutter pub get
flutter run
```

**Build APK:**
```bash
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── models/
│   │   ├── widget_node.dart           # WidgetNode, WType (20 widget types)
│   │   └── screen_model.dart          # ForgeScreen, multi-screen support
│   ├── providers/
│   │   └── forge_provider.dart        # Full state manager (drag/resize/undo)
│   └── commands/
│       └── forge_commands.dart        # Command pattern (undo/redo history)
├── canvas/
│   ├── forge_canvas.dart              # Main zoom/pan/drag canvas
│   ├── widget_renderer.dart           # Live preview of all 20 widget types
│   └── selection_handles.dart        # 8-point resize handles
├── panels/
│   ├── layers_panel.dart             # Figma-style layers panel
│   ├── widget_palette.dart           # Searchable widget library
│   ├── property_panel.dart           # Full property editor
│   ├── screen_manager.dart           # Multi-screen tab bar
│   └── code_export.dart              # Dart code export
├── codegen/
│   └── dart_codegen.dart             # Dart code generator
└── ui/
    ├── theme.dart                    # Pro dark theme + reusable components
    └── forge_scaffold.dart           # Main layout (wide + mobile)
```

---

## ✨ Features

### Canvas
- 🎯 **Drag & Drop** — widgets ko touch karke move karo
- 📐 **8-point Resize** — kisi bhi corner/edge se resize
- 🔍 **Pinch Zoom** — 20% to 400% zoom, InteractiveViewer
- 📏 **Grid & Snap** — 8px grid with snap-to-grid
- 📍 **Position display** — real-time X, Y, W, H info bar

### Layers Panel (Figma-style)
- 👁️ **Show/Hide** widgets
- 🔒 **Lock/Unlock** layers
- ↕️ **Reorder** via drag
- ✏️ **Rename** layers
- 🗑️ Right-click context menu (duplicate, front/back, delete)

### Widget Library (20 types)
| Category | Widgets |
|----------|---------|
| Layout | Container, Row, Column, Stack, ListView, GridView |
| Basic | Text, Image, Icon, Divider, CircleAvatar |
| Input | Button, IconButton, TextField, Switch, Slider, Checkbox |
| Material | Card, ListTile, AppBar |

### Property Editor
- Every widget has type-specific properties
- Color picker (flutter_colorpicker)
- Sliders for numeric values
- Toggle switches for booleans
- Dropdowns for enums
- X/Y/W/H direct input

### Undo / Redo
- 50-step history
- Covers: add, delete, move, resize, property change, layer reorder

### Multi-Screen
- Unlimited screens
- Long-press tab to rename
- Delete screens

### Code Export
- Current screen Dart code
- Full project code (all screens)
- Syntax-highlighted preview
- One-tap copy to clipboard

---

## 📱 Responsive Layout

| Width | Layout |
|-------|--------|
| ≥ 900px | Desktop: Left sidebar (Layers+Palette) + Canvas + Right props |
| < 900px | Mobile: Bottom nav (Layers / Canvas / Props / Widgets) |

---

## 🛠️ Dependencies

```yaml
provider: ^6.1.2
shared_preferences: ^2.2.3
uuid: ^4.4.0
flutter_colorpicker: ^1.1.0
```

---

*GAX Forge v2 — Built by ArnabLabZ Studio*

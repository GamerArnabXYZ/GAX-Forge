# GAX Forge 🔧
### Professional Flutter UI Design Maker
**by ArnabLabZ Studio**

---

## 📁 Project Structure

```
gax_forge/
├── lib/
│   ├── main.dart                          # App entry point (Hive + Riverpod init)
│   ├── theme/
│   │   └── app_theme.dart                 # Material 3 light/dark themes
│   ├── models/
│   │   ├── app_models.dart               # GaxProject, CanvasScreen, WidgetProperty, WidgetCatalog
│   │   └── app_models.g.dart             # Hive TypeAdapters (pre-generated)
│   ├── providers/
│   │   └── project_provider.dart         # Riverpod StateNotifiers (projects + editor state)
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart          # Dashboard with search, grid/list, drawer
│   │   │   └── widgets/
│   │   │       ├── project_card.dart     # Project card (grid + list modes)
│   │   │       └── create_project_dialog.dart  # New project dialog with color picker
│   │   ├── editor/
│   │   │   └── editor_screen.dart        # Main editor: AppBar, BottomNav, screen switcher
│   │   └── widgets/
│   │       ├── canvas/
│   │       │   ├── canvas_area.dart      # InteractiveViewer + drag/resize/selection
│   │       │   └── canvas_widget_renderer.dart  # Renders all 40+ widget types
│   │       └── panels/
│   │           ├── widget_library_panel.dart    # Categorized widget picker
│   │           └── properties_panel.dart        # Widget property editor
│   └── utils/
│       └── export_utils.dart             # Dart code generator + file sharing
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── res/xml/file_paths.xml
├── .github/workflows/
│   └── build.yml                         # GitHub Actions CI/CD → APK releases
└── pubspec.yaml
```

---

## 🚀 Setup & Build

### 1. Clone & Install
```bash
git clone https://github.com/GamerArnabXYZ/gax-forge
cd gax_forge
flutter pub get
```

### 2. Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release --split-per-abi
```

---

## 🔧 Tech Stack

| Layer | Package |
|-------|---------|
| State Management | `flutter_riverpod 2.x` |
| Local Storage | `hive_flutter` |
| Code Export | `path_provider` + `share_plus` |
| Color Picker | `flutter_colorpicker` |
| UI | Material 3 |

---

## 📱 Features

- **40+ Widgets** across 8 categories
- **Multi-screen** project support
- **Drag & Drop** on canvas with pinch-to-zoom
- **Canvas Lock** for precise widget editing
- **Properties Panel** — color, size, text, radius, etc.
- **Undo / Redo** (30 levels)
- **Preview Mode** — clean UI without editor chrome
- **Export to Dart** — generates complete `.dart` files
- **Hive Storage** — fast, offline, no internet needed
- **Material 3** — light + dark theme

---

## ☁️ CI/CD

Push to `main` → GitHub Actions builds and releases APKs automatically.
No manual build steps needed from mobile.

---

*Made with ❤️ by ArnabLabZ Studio*

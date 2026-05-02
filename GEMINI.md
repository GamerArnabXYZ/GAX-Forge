# GAX Forge - Project Context & Guidelines

## 🚀 Project Overview
**GAX Forge** is a professional Flutter UI Design Maker built for mobile devices. It allows users to design, preview, and export Flutter UI code directly from their phones.

## 🛠 Tech Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod (StateNotifier)
- **Local Storage:** Hive (Manual Adapters)
- **Target Platform:** Android (Optimized for low-end devices / Termux)

## 🏗 Project Structure
- `lib/models/app_models.dart`: Core data models (`WidgetProperty`, `CanvasScreen`, `GaxProject`). **Note:** Hive adapters are maintained manually to avoid `build_runner` (RAM saving).
- `lib/providers/project_provider.dart`: Riverpod providers. `EditorNotifier` handles the canvas logic, undo/redo, and widget manipulation.
- `lib/screens/widgets/canvas/`:
  - `canvas_area.dart`: Handles interactive gestures, dragging, and scaling.
  - `canvas_widget_renderer.dart`: Maps `WidgetProperty` models to actual Flutter widgets (Supports 100+ widgets).
- `lib/utils/`:
  - `export_utils.dart`: Generates professional Dart code from the design. Supports `StatefulWidget` generation for interactive widgets.
  - `json_io.dart`: Handles project Import/Export via JSON strings and files.

## 🔧 Recent Fixes & Improvements
1. **Selection Logic:** Widgets can now be selected regardless of canvas lock state. Background tap deselects the current widget.
2. **Properties Panel:** Visibility logic updated to show the panel whenever a widget is selected (except in Preview mode).
3. **Renderer Stability:** Fixed `num_` helper to safely handle `double` to `int` conversions from Hive. Fixed invalid hexadecimal icon codes.
4. **Export Engine Overhaul:**
   - Changed generated screens from `StatelessWidget` to `StatefulWidget`.
   - Added state persistence for `Switch`, `Checkbox`, and `Slider` in exported code.
   - Added missing widget generators: `DropdownButton`, `DatePicker`, `TimePicker`, `SegmentedButton`, and `BottomNavigationBar`.
5. **Bug Fixes:** Resolved color parsing issue during project creation (`int.parse` vs `hex string`).

## ⚠️ Critical Constraints (For AI Agents)
- **RAM Limit:** The host device has **3GB RAM**. Avoid running heavy commands like `flutter run` or `build_runner` unless explicitly requested.
- **No Codegen:** Do NOT add dependencies that require `build_runner` (like `freezed` or `hive_generator`). Keep Hive adapters manual.
- **Hinglish Communication:** The user prefers responses in **Hinglish**.

## 🎯 Future Roadmap
- Implement more complex layout widgets (Nested Columns/Rows).
- Add support for custom asset image uploads.
- Enhance the responsiveness of exported code (currently uses absolute positioning).

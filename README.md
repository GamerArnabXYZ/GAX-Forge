# Gax Forge

A Flutter UI Builder App - Design Flutter screens with drag and drop widgets.

## Features

- 🎨 **Drag & Drop Widgets** - 30+ ready-made Flutter widgets
- ✏️ **Property Editor** - Edit widget properties with live preview
- 📱 **Device Preview** - Pixel 6, iPhone, Samsung support
- 📋 **Code Export** - Generate working Dart code
- 🌙 **Dark Mode** - Material 3 design
- 💾 **Project Save/Load** - Persistent storage

## Screenshots

Coming soon...

## Getting Started

```bash
# Clone the repository
git clone https://github.com/yourusername/gax_forge.git

# Navigate to project
cd gax_forge

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Building

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

### Web
```bash
flutter build web --release
```

## CI/CD

This project uses GitHub Actions for automated builds:

- **Android Build**: Builds debug and release APKs on push/PR
- **Web Build**: Builds and deploys web app
- **Tests**: Runs Flutter analyze and tests

## Project Structure

```
lib/
├── main.dart
├── models/           # Data models
├── providers/         # State management (Riverpod)
├── screens/           # UI screens
├── widgets/           # Custom widgets
├── utils/             # Utilities
└── theme/             # App theme
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For bugs and feature requests, please use GitHub Issues.

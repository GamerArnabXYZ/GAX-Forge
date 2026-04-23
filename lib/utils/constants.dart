/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Gax Forge';
  static const String appVersion = '1.0.0';

  // Canvas Defaults
  static const double defaultCanvasWidth = 412.0;  // Pixel 6
  static const double defaultCanvasHeight = 915.0; // Pixel 6
  static const double minWidgetSize = 20.0;
  static const double maxWidgetSize = 2000.0;
  static const double defaultWidgetWidth = 100.0;
  static const double defaultWidgetHeight = 50.0;

  // Device Frame Presets
  static const Map<String, Map<String, double>> devicePresets = {
    'Pixel 6': {'width': 412.0, 'height': 915.0},
    'iPhone 14': {'width': 390.0, 'height': 844.0},
    'Samsung S23': {'width': 360.0, 'height': 780.0},
    'Tablet 7"': {'width': 600.0, 'height': 1024.0},
    'Tablet 10"': {'width': 800.0, 'height': 1280.0},
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Dimensions
  static const double widgetLibraryWidth = 280.0;
  static const double propertyPanelWidth = 320.0;
  static const double bottomNavHeight = 60.0;
  static const double fabSize = 56.0;
  static const double borderRadius = 12.0;

  // Grid Settings
  static const double gridSize = 10.0;
  static const double snapThreshold = 5.0;

  // Colors (hex format)
  static const Map<String, String> defaultColors = {
    'primary': '#6750A4',
    'secondary': '#03DAC6',
    'white': '#FFFFFF',
    'black': '#000000',
    'grey': '#9E9E9E',
    'lightGrey': '#E0E0E0',
    'red': '#F44336',
    'blue': '#2196F3',
    'green': '#4CAF50',
    'orange': '#FF9800',
  };
}

/// Icon name to code point mapping for common Flutter icons
/// Yeh map karne ke liye ki user icon name se actual IconData create kar sake
class IconMapping {
  static const Map<String, int> iconCodes = {
    'Icons.star': 0xe838,
    'Icons.star_border': 0xe839,
    'Icons.star_half': 0xe83a,
    'Icons.favorite': 0xe87d,
    'Icons.favorite_border': 0xe87e,
    'Icons.home': 0xe88e,
    'Icons.settings': 0xe8b8,
    'Icons.search': 0xe8b6,
    'Icons.person': 0xe7fd,
    'Icons.shopping_cart': 0xea5d,
    'Icons.menu': 0xe5d2,
    'Icons.more_vert': 0xe5d4,
    'Icons.more_horiz': 0xe5d3,
    'Icons.add': 0xe145,
    'Icons.edit': 0xe3c9,
    'Icons.delete': 0xe872,
    'Icons.check': 0xe5ca,
    'Icons.close': 0xe5cd,
    'Icons.arrow_back': 0xe5de,
    'Icons.arrow_forward': 0xe5df,
    'Icons.arrow_upward': 0xe5d8,
    'Icons.arrow_downward': 0xe5db,
    'Icons.notifications': 0xe7f7,
    'Icons.image': 0xe3f4,
    'Icons.photo_camera': 0xe3b0,
    'Icons.email': 0xe0be,
    'Icons.phone': 0xe0b0,
    'Icons.location_on': 0xe0c8,
    'Icons.share': 0xe80d,
    'Icons.download': 0xf090,
    'Icons.upload': 0xf09b,
    'Icons.cloud': 0xe42d,
    'Icons.cloud_upload': 0xe2c6,
    'Icons.cloud_download': 0xe2c5,
    'Icons.visibility': 0xe8f4,
    'Icons.visibility_off': 0xe8f5,
    'Icons.lock': 0xe897,
    'Icons.lock_open': 0xe898,
    'Icons.refresh': 0xe5d5,
    'Icons.sync': 0xe628,
    'Icons.build': 0xe1c2,
    'Icons.code': 0xe86f,
    'Icons.flutter_dash': 0xe900,
  };

  /// Get code point from icon name
  static int? getCodePoint(String iconName) {
    return iconCodes[iconName];
  }

  /// Get all available icon names
  static List<String> get availableIcons => iconCodes.keys.toList();
}

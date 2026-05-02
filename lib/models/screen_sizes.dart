// lib/models/screen_sizes.dart
// GAX Forge - All device screen sizes catalog

import 'package:flutter/material.dart';

class DeviceScreenSize {
  final String id;
  final String name;
  final String brand;
  final double width;
  final double height;
  final IconData icon;
  final String category;

  const DeviceScreenSize({
    required this.id, required this.name, required this.brand,
    required this.width, required this.height,
    required this.icon, required this.category,
  });

  double get aspectRatio => width / height;
  String get resolution => '${width.round()}×${height.round()}';
}

class ScreenSizeCatalog {
  static const List<DeviceScreenSize> all = [

    // ── iPhone ─────────────────────────────────
    DeviceScreenSize(id: 'iphone_15_pro_max', name: 'iPhone 15 Pro Max', brand: 'Apple',
        width: 430, height: 932, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_15_pro', name: 'iPhone 15 Pro', brand: 'Apple',
        width: 393, height: 852, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_15', name: 'iPhone 15', brand: 'Apple',
        width: 390, height: 844, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_14_plus', name: 'iPhone 14 Plus', brand: 'Apple',
        width: 428, height: 926, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_13_mini', name: 'iPhone 13 Mini', brand: 'Apple',
        width: 375, height: 812, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_se_3', name: 'iPhone SE (3rd)', brand: 'Apple',
        width: 375, height: 667, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_6s_plus', name: 'iPhone 6s Plus', brand: 'Apple',
        width: 414, height: 736, icon: Icons.phone_iphone_rounded, category: 'iPhone'),
    DeviceScreenSize(id: 'iphone_6s', name: 'iPhone 6s', brand: 'Apple',
        width: 375, height: 667, icon: Icons.phone_iphone_rounded, category: 'iPhone'),

    // ── Android Flagship ──────────────────────
    DeviceScreenSize(id: 'pixel_8_pro', name: 'Pixel 8 Pro', brand: 'Google',
        width: 412, height: 915, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 'pixel_8', name: 'Pixel 8', brand: 'Google',
        width: 412, height: 892, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 'pixel_7a', name: 'Pixel 7a', brand: 'Google',
        width: 412, height: 892, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 's24_ultra', name: 'Galaxy S24 Ultra', brand: 'Samsung',
        width: 412, height: 915, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 's24', name: 'Galaxy S24', brand: 'Samsung',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 's23_fe', name: 'Galaxy S23 FE', brand: 'Samsung',
        width: 412, height: 892, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 'oneplus_12', name: 'OnePlus 12', brand: 'OnePlus',
        width: 412, height: 919, icon: Icons.phone_android_rounded, category: 'Android'),
    DeviceScreenSize(id: 'oneplus_nord_3', name: 'OnePlus Nord 3', brand: 'OnePlus',
        width: 412, height: 919, icon: Icons.phone_android_rounded, category: 'Android'),

    // ── Mid-range / Budget ────────────────────
    DeviceScreenSize(id: 'vivo_y11', name: 'Vivo Y11', brand: 'Vivo',
        width: 360, height: 780, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'vivo_v29', name: 'Vivo V29', brand: 'Vivo',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'vivo_y36', name: 'Vivo Y36', brand: 'Vivo',
        width: 393, height: 873, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'realme_c55', name: 'Realme C55', brand: 'Realme',
        width: 393, height: 873, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'realme_narzo_60', name: 'Realme Narzo 60', brand: 'Realme',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'redmi_note_13', name: 'Redmi Note 13', brand: 'Xiaomi',
        width: 393, height: 873, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'redmi_12', name: 'Redmi 12', brand: 'Xiaomi',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'poco_x6', name: 'POCO X6 Pro', brand: 'Xiaomi',
        width: 393, height: 873, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'infinix_hot_40', name: 'Infinix Hot 40', brand: 'Infinix',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'tecno_spark_20', name: 'Tecno Spark 20', brand: 'Tecno',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),
    DeviceScreenSize(id: 'nokia_g42', name: 'Nokia G42', brand: 'Nokia',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Budget'),

    // ── Foldable ──────────────────────────────
    DeviceScreenSize(id: 'fold_open', name: 'Galaxy Z Fold 5 (Open)', brand: 'Samsung',
        width: 768, height: 898, icon: Icons.tablet_android_rounded, category: 'Fold'),
    DeviceScreenSize(id: 'fold_closed', name: 'Galaxy Z Fold 5 (Closed)', brand: 'Samsung',
        width: 360, height: 824, icon: Icons.phone_android_rounded, category: 'Fold'),
    DeviceScreenSize(id: 'flip_open', name: 'Galaxy Z Flip 5 (Open)', brand: 'Samsung',
        width: 393, height: 851, icon: Icons.phone_android_rounded, category: 'Fold'),
    DeviceScreenSize(id: 'flip_closed', name: 'Galaxy Z Flip 5 (Closed)', brand: 'Samsung',
        width: 260, height: 512, icon: Icons.watch_rounded, category: 'Fold'),
    DeviceScreenSize(id: 'pixel_fold_open', name: 'Pixel Fold (Open)', brand: 'Google',
        width: 748, height: 832, icon: Icons.tablet_android_rounded, category: 'Fold'),
    DeviceScreenSize(id: 'pixel_fold_closed', name: 'Pixel Fold (Closed)', brand: 'Google',
        width: 412, height: 892, icon: Icons.phone_android_rounded, category: 'Fold'),

    // ── Tablet ────────────────────────────────
    DeviceScreenSize(id: 'ipad_pro_13', name: 'iPad Pro 13"', brand: 'Apple',
        width: 1032, height: 1376, icon: Icons.tablet_mac_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'ipad_pro_11', name: 'iPad Pro 11"', brand: 'Apple',
        width: 834, height: 1194, icon: Icons.tablet_mac_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'ipad_air', name: 'iPad Air (M2)', brand: 'Apple',
        width: 820, height: 1180, icon: Icons.tablet_mac_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'ipad_mini', name: 'iPad Mini', brand: 'Apple',
        width: 768, height: 1024, icon: Icons.tablet_mac_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'tab_s9_ultra', name: 'Galaxy Tab S9 Ultra', brand: 'Samsung',
        width: 1080, height: 1600, icon: Icons.tablet_android_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'tab_s9', name: 'Galaxy Tab S9', brand: 'Samsung',
        width: 800, height: 1280, icon: Icons.tablet_android_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'pixel_tablet', name: 'Pixel Tablet', brand: 'Google',
        width: 960, height: 1280, icon: Icons.tablet_android_rounded, category: 'Tablet'),
    DeviceScreenSize(id: 'tab_a9_plus', name: 'Galaxy Tab A9+', brand: 'Samsung',
        width: 800, height: 1340, icon: Icons.tablet_android_rounded, category: 'Tablet'),

    // ── Desktop / Web ─────────────────────────
    DeviceScreenSize(id: 'desktop_1920', name: 'Desktop Full HD', brand: 'Web',
        width: 1920, height: 1080, icon: Icons.desktop_windows_rounded, category: 'Desktop'),
    DeviceScreenSize(id: 'desktop_1440', name: 'Desktop 2K', brand: 'Web',
        width: 1440, height: 900, icon: Icons.desktop_windows_rounded, category: 'Desktop'),
    DeviceScreenSize(id: 'laptop_1366', name: 'Laptop', brand: 'Web',
        width: 1366, height: 768, icon: Icons.laptop_rounded, category: 'Desktop'),

    // ── Wearable ──────────────────────────────
    DeviceScreenSize(id: 'watch_44', name: 'Apple Watch 44mm', brand: 'Apple',
        width: 198, height: 242, icon: Icons.watch_rounded, category: 'Watch'),
    DeviceScreenSize(id: 'watch_pixel', name: 'Pixel Watch 2', brand: 'Google',
        width: 384, height: 384, icon: Icons.watch_rounded, category: 'Watch'),
  ];

  static DeviceScreenSize findById(String id) =>
      all.firstWhere((s) => s.id == id,
          orElse: () => all.firstWhere((s) => s.id == 'pixel_8'));

  static List<String> get categories =>
      all.map((s) => s.category).toSet().toList();

  static List<DeviceScreenSize> byCategory(String cat) =>
      all.where((s) => s.category == cat).toList();
}

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Device Frame - realistic device preview dikhata hai
/// Pixel 6 / iPhone style frame ke saath
class DeviceFrame extends StatelessWidget {
  final Widget child;
  final String deviceName;
  final double width;
  final double height;

  const DeviceFrame({
    super.key,
    required this.child,
    this.deviceName = 'Pixel 6',
    this.width = 412,
    this.height = 915,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width + 32,
      height: height + 32,
      decoration: BoxDecoration(
        color: CanvasColors.deviceFrame,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Device body
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // Screen
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),

          // Notch / Camera
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Home indicator
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Device name label
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                deviceName,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple device frame without notch/camera
class SimpleDeviceFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color backgroundColor;

  const SimpleDeviceFrame({
    super.key,
    required this.child,
    this.width = 412,
    this.height = 915,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

/// Phone skeleton for loading states
class PhoneSkeleton extends StatelessWidget {
  const PhoneSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Status bar
          Container(
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Content skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Image placeholder
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Text lines
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Button placeholder
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

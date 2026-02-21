import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission states
enum PermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  provisional,
  unknown,
}

/// Permission request result
class PermissionResult {
  const PermissionResult({
    required this.state,
    this.message,
    this.shouldShowRationale = false,
  });

  final PermissionState state;
  final String? message;
  final bool shouldShowRationale;

  bool get isGranted => state == PermissionState.granted;
  bool get isDenied => state == PermissionState.denied;
  bool get isPermanentlyDenied => state == PermissionState.permanentlyDenied;
}

class PermissionManager {
  static bool _isRequestingPermissions = false;
  static bool _isDialogShowing = false;

  static PermissionState _convertStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionState.granted;
      case PermissionStatus.denied:
        return PermissionState.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionState.restricted;
      case PermissionStatus.limited:
        return PermissionState.limited;
      case PermissionStatus.provisional:
        return PermissionState.provisional;
    }
  }

  /// Request location permission
  static Future<PermissionResult> requestLocationPermission() async {
    try {
      final isServiceEnabled =
          await Permission.location.serviceStatus.isEnabled;
      if (!isServiceEnabled) {
        return const PermissionResult(
          state: PermissionState.denied,
          message: 'Location services are disabled.',
        );
      }
      final currentStatus = await Permission.location.status;
      if (currentStatus.isGranted) {
        return const PermissionResult(state: PermissionState.granted);
      }
      if (currentStatus.isPermanentlyDenied) {
        return const PermissionResult(
          state: PermissionState.permanentlyDenied,
          message: 'Location access is required. Please enable it in Settings.',
        );
      }
      final status = await Permission.location.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Location access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting location permission: \$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request camera permission
  static Future<PermissionResult> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Camera access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting camera permission: \$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request photo library permission
  static Future<PermissionResult> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Photo library access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting photos permission: \$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Generic permission request
  static Future<PermissionResult> requestPermission(
    Permission permission,
  ) async {
    try {
      final status = await permission.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Permission is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting permission: \$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request permission with automatic dialog handling
  static Future<bool> requestPermissionWithDialog({
    required BuildContext context,
    required Permission permission,
    required String permissionName,
    String? customPermanentlyDeniedMessage,
  }) async {
    try {
      final result = await requestPermission(permission);
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
        await _showPermissionSettingsDialog(
          context: context,
          permissionName: permissionName,
          message: customPermanentlyDeniedMessage ??
              '\$permissionName access is required. Please enable it in Settings.',
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting permission with dialog: \$e');
      return false;
    }
  }

  /// Check if a permission is granted
  static Future<bool> isGranted(Permission permission) async {
    try {
      return await permission.status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionResult>>
      requestMultiplePermissions(List<Permission> permissions) async {
    if (_isRequestingPermissions) return {};
    try {
      _isRequestingPermissions = true;
      final statusMap = await permissions.request();
      final resultMap = <Permission, PermissionResult>{};
      for (final entry in statusMap.entries) {
        resultMap[entry.key] = PermissionResult(
          state: _convertStatus(entry.value),
          shouldShowRationale: entry.value.isDenied,
        );
      }
      return resultMap;
    } finally {
      _isRequestingPermissions = false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettingsPage() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  static Future<void> _showPermissionSettingsDialog({
    required BuildContext context,
    required String permissionName,
    required String message,
  }) async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('\$permissionName Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettingsPage();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
    _isDialogShowing = false;
  }
}

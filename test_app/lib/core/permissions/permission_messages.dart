import 'dart:io';

import 'package:flutter/material.dart';

class PermissionMessages {
  static String getCameraSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Camera access is required. Please enable it in Settings > Privacy & Security > Camera.'
        : 'Camera access is required. Please enable it in Settings > Apps > Permissions.';
  }

  static String getNotificationSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Notification access is required. Please enable it in Settings > Notifications.'
        : 'Notification access is required. Please enable it in Settings > Apps > Notifications.';
  }

  static String getLocationSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Location access is required. Please enable it in Settings > Privacy & Security > Location Services.'
        : 'Location access is required. Please enable it in Settings > Apps > Permissions.';
  }

  static String getPhotoLibrarySettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Photo library access is required. Please enable it in Settings > Privacy & Security > Photos.'
        : 'Photo library access is required. Please enable it in Settings > Apps > Permissions.';
  }
}

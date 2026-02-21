const iosPodfileTemplate = r'''
platform :ios, '15.6'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|

      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',

        ## dart: PermissionGroup.calendar
        'PERMISSION_EVENTS=0',

        ## dart: PermissionGroup.calendarFullAccess
        'PERMISSION_EVENTS_FULL_ACCESS=0',

        ## dart: PermissionGroup.reminders
        'PERMISSION_REMINDERS=0',

        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=0',

        ## dart: PermissionGroup.camera
        'PERMISSION_CAMERA=1',

        ## dart: PermissionGroup.microphone
        'PERMISSION_MICROPHONE=0',

        ## dart: PermissionGroup.speech
        'PERMISSION_SPEECH_RECOGNIZER=0',

        ## dart: PermissionGroup.photos
        'PERMISSION_PHOTOS=1',

        ## dart: PermissionGroup.location
        'PERMISSION_LOCATION=1',
        'PERMISSION_LOCATION_WHENINUSE=0',

        ## dart: PermissionGroup.notification
        'PERMISSION_NOTIFICATIONS=1',

        ## dart: PermissionGroup.mediaLibrary
        'PERMISSION_MEDIA_LIBRARY=1',

        ## dart: PermissionGroup.sensors
        'PERMISSION_SENSORS=0',

        ## dart: PermissionGroup.bluetooth
        'PERMISSION_BLUETOOTH=0',

        ## dart: PermissionGroup.appTrackingTransparency
        'PERMISSION_APP_TRACKING_TRANSPARENCY=0',

        ## dart: PermissionGroup.criticalAlerts
        'PERMISSION_CRITICAL_ALERTS=0',

        ## dart: PermissionGroup.assistant
        'PERMISSION_ASSISTANT=0',
      ]

    end
  end
end
''';

const iosInfoPlistTemplate = r'''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>NSCameraUsageDescription</key>
		<string>This app requires camera access to allow you to take photos and videos.</string>
		<key>NSPhotoLibraryUsageDescription</key>
		<string>This app requires access to your photo library to let you select and upload images.</string>
		<key>NSPhotoLibraryAddUsageDescription</key>
		<string>This app requires permission to save photos to your library.</string>
		<key>NSLocationWhenInUseUsageDescription</key>
		<string>This app uses your location while the app is in use to provide location-based features.</string>
		<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
		<string>This app needs continuous location access to enable location-based functionality even in the background.</string>
		<key>NSLocationAlwaysUsageDescription</key>
		<string>This app needs location access at all times to support background location features.</string>
		<key>NSUserTrackingUsageDescription</key>
		<string>This identifier will be used to deliver a better, more personalized experience.</string>
		<key>NSAppleMusicUsageDescription</key>
		<string>This app requires access to your media library to play music and media content.</string>
		<key>UNUserNotificationAlert</key>
		<string>This app uses notifications to keep you updated with important alerts.</string>
		<key>CFBundleLocalizations</key>
		<array>
			<string>en</string>
			<string>es</string>
		</array>
		<key>CFBundleDevelopmentRegion</key>
		<string>$(DEVELOPMENT_LANGUAGE)</string>
		<key>CFBundleDisplayName</key>
		<string>{{ProjectName}}</string>
		<key>CFBundleExecutable</key>
		<string>$(EXECUTABLE_NAME)</string>
		<key>CFBundleIdentifier</key>
		<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
		<key>CFBundleInfoDictionaryVersion</key>
		<string>6.0</string>
		<key>CFBundleName</key>
		<string>{{ProjectName}}</string>
		<key>CFBundlePackageType</key>
		<string>APPL</string>
		<key>CFBundleShortVersionString</key>
		<string>$(FLUTTER_BUILD_NAME)</string>
		<key>CFBundleSignature</key>
		<string>????</string>
		<key>CFBundleVersion</key>
		<string>$(FLUTTER_BUILD_NUMBER)</string>
		<key>LSRequiresIPhoneOS</key>
		<true/>
		<key>UILaunchStoryboardName</key>
		<string>LaunchScreen</string>
		<key>UIMainStoryboardFile</key>
		<string>Main</string>
		<key>UISupportedInterfaceOrientations</key>
		<array>
			<string>UIInterfaceOrientationPortrait</string>
			<string>UIInterfaceOrientationLandscapeLeft</string>
			<string>UIInterfaceOrientationLandscapeRight</string>
		</array>
		<key>UISupportedInterfaceOrientations~ipad</key>
		<array>
			<string>UIInterfaceOrientationPortrait</string>
			<string>UIInterfaceOrientationPortraitUpsideDown</string>
			<string>UIInterfaceOrientationLandscapeLeft</string>
			<string>UIInterfaceOrientationLandscapeRight</string>
		</array>
		<key>UIViewControllerBasedStatusBarAppearance</key>
		<false/>
		<key>CADisableMinimumFrameDurationOnPhone</key>
		<true/>
		<key>UIApplicationSupportsIndirectInputEvents</key>
		<true/>
		<key>UIStatusBarHidden</key>
		<false/>
	</dict>
</plist>
''';

const iosEntitlementsTemplate = r'''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
</plist>
''';

const iosReleaseEntitlementsTemplate = r'''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>production</string>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
</plist>
''';

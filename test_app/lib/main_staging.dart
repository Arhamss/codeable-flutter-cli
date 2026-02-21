import 'package:device_preview/device_preview.dart';
import 'package:test_app/app/view/app_page.dart';
import 'package:test_app/bootstrap.dart';
import 'package:test_app/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig(flavor: Flavor.staging);
  await bootstrap(
    () => DevicePreview(
      enabled: false,
      builder: (context) {
        return const App();
      },
    ),
  );
}

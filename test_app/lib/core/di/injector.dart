import 'package:get_it/get_it.dart';
import 'package:test_app/core/di/modules/app_modules.dart';

abstract class Injector {
  static late final GetIt _container;

  static Future<void> setup() async {
    _container = GetIt.instance;
    await AppModule.setup(_container);
  }

  static T resolve<T extends Object>() => _container.get<T>();
}

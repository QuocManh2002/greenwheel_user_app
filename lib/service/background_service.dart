import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration:
        AndroidConfiguration(onStart: onStart, isForegroundMode: true),
  );

  await service.startService();
  // service.invoke('setAsBackground');
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {}

    Future.delayed(const Duration(seconds: 20), () async {
      Timer.periodic(const Duration(hours: 12), (timer) async {
        final OfflineService offlineService = OfflineService();
        await offlineService.savePlanToHive();
      });
    });
  }
}

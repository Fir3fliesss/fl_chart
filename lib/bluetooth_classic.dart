import 'dart:async';
import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

// Platform messages are asynchronous, so we initialize in an async method.
Future<String> initPlatformState(
    BluetoothClassic _bluetoothClassicPlugin) async {
  String platformVersion;
  // Platform messages may fail, so we use a try/catch PlatformException.
  // We also handle the message potentially returning null.
  try {
    platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
        'Unknown platform version';
  } on PlatformException {
    platformVersion = 'Failed to get platform version.';
  }

  return platformVersion;
}

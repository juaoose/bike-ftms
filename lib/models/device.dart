import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device.g.dart';

@riverpod
class Device extends _$Device {
  @override
  BluetoothDevice? build() => null;

  void setConnectedDevice(BluetoothDevice device) {
    state = device;
  }

  void disconnect() {
    state?.disconnect(queue: false);
    state = null;
  }
}

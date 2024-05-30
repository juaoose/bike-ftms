import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';

Widget scanBluetoothButton(bool? isScanning) {
  if (isScanning == null) {
    return Container();
  }

  return ElevatedButton(
    onPressed:
        isScanning ? null : () async => await FTMS.scanForBluetoothDevices(),
    child: isScanning
        ? const Text("Scanning...")
        : const Text("Scan FTMS Devices"),
  );
}
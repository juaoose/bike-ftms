import 'package:bike_ftms/bloc.dart';
import 'package:bike_ftms/models/device.dart';
import 'package:bike_ftms/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlutterFTMSApp extends ConsumerStatefulWidget {
  const FlutterFTMSApp({super.key});

  @override
  ConsumerState<FlutterFTMSApp> createState() => _FlutterFTMSAppState();
}

class _FlutterFTMSAppState extends ConsumerState<FlutterFTMSApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices Manager"),
      ),
      body: const ScanPage(),
    );
  }
}

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  @override
  Widget build(BuildContext context) {
    final device = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (device != null) Text(device.advName),
        if (device != null)
          ElevatedButton(
              onPressed: () => deviceNotifier.disconnect(),
              child: const Text("Disconnect")),
        Center(
          child: StreamBuilder<bool>(
            stream: FTMS.isScanning,
            builder: (c, snapshot) =>
                scanBluetoothButton(snapshot.data ?? false),
          ),
        ),
        StreamBuilder<List<ScanResult>>(
            stream: FTMS.scanResults,
            initialData: const [],
            builder: (c, snapshot) => Column(
                  children: (snapshot.data ?? [])
                      .where(
                          (element) => element.device.platformName.isNotEmpty)
                      .toList()
                      .map(
                        (d) => ListTile(
                          title: FutureBuilder<bool>(
                              future:
                                  FTMS.isBluetoothDeviceFTMSDevice(d.device),
                              initialData: false,
                              builder: (c, snapshot) {
                                return Text(
                                  d.device.platformName.isEmpty
                                      ? "(unknown device)"
                                      : d.device.platformName,
                                );
                              }),
                          trailing: StreamBuilder<BluetoothConnectionState>(
                              stream: d.device.connectionState,
                              builder: (c, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text("...");
                                }
                                var deviceState = snapshot.data!;
                                switch (deviceState) {
                                  case BluetoothConnectionState.disconnected:
                                    return ElevatedButton(
                                      child: const Text("Pair"),
                                      onPressed: () async {
                                        final snackBar = SnackBar(
                                          content: Text(
                                              'Connecting to ${d.device.platformName}...'),
                                          duration: const Duration(seconds: 2),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        await FTMS
                                            .connectToFTMSDevice(d.device);
                                        deviceNotifier
                                            .setConnectedDevice(d.device);
                                        d.device.connectionState
                                            .listen((state) async {
                                          if (state ==
                                              BluetoothConnectionState
                                                  .disconnected) {
                                            ftmsBloc
                                                .ftmsDeviceDataControllerSink
                                                .add(null);
                                            return;
                                          }
                                        });
                                      },
                                    );
                                  case BluetoothConnectionState.connected:
                                    return SizedBox(
                                      width: 250,
                                      child: Wrap(
                                        spacing: 2,
                                        alignment: WrapAlignment.end,
                                        direction: Axis.horizontal,
                                        children: [
                                          OutlinedButton(
                                            child: const Text("Disconnect"),
                                            onPressed: () =>
                                                FTMS.disconnectFromFTMSDevice(
                                                    d.device),
                                          )
                                        ],
                                      ),
                                    );
                                  default:
                                    return Text(deviceState.name);
                                }
                              }),
                        ),
                      )
                      .toList(),
                )),
      ],
    );
  }
}

class FTMSPage extends StatefulWidget {
  final BluetoothDevice ftmsDevice;

  const FTMSPage({super.key, required this.ftmsDevice});

  @override
  State<FTMSPage> createState() => _FTMSPageState();
}

class _FTMSPageState extends State<FTMSPage> {
  void writeCommand(MachineControlPointOpcodeType opcodeType) async {
    MachineControlPoint? controlPoint;
    switch (opcodeType) {
      case MachineControlPointOpcodeType.requestControl:
        controlPoint = MachineControlPoint.requestControl();
        break;
      case MachineControlPointOpcodeType.reset:
        controlPoint = MachineControlPoint.reset();
        break;
      case MachineControlPointOpcodeType.setTargetSpeed:
        controlPoint = MachineControlPoint.setTargetSpeed(speed: 12);
        break;
      case MachineControlPointOpcodeType.setTargetInclination:
        controlPoint =
            MachineControlPoint.setTargetInclination(inclination: 23);
        break;
      case MachineControlPointOpcodeType.setTargetResistanceLevel:
        controlPoint =
            MachineControlPoint.setTargetResistanceLevel(resistanceLevel: 3);
        break;
      case MachineControlPointOpcodeType.setTargetPower:
        controlPoint = MachineControlPoint.setTargetPower(power: 75);
        break;
      case MachineControlPointOpcodeType.setTargetHeartRate:
        controlPoint = MachineControlPoint.setTargetHeartRate(heartRate: 45);
        break;
      case MachineControlPointOpcodeType.startOrResume:
        controlPoint = MachineControlPoint.startOrResume();
        break;
      case MachineControlPointOpcodeType.stopOrPause:
        controlPoint = MachineControlPoint.stopOrPause(pause: true);
        break;
      default:
        throw 'MachineControlPointOpcodeType $opcodeType is not implemented in this example';
    }

    await FTMS.writeMachineControlPointCharacteristic(
        widget.ftmsDevice, controlPoint);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.ftmsDevice.platformName} (${FTMS.getDeviceDataType(widget.ftmsDevice)})'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Data',
                icon: Icon(Icons.data_object),
              ),
              Tab(
                text: 'Device Data Features',
                icon: Icon(Icons.featured_play_list_outlined),
              ),
              Tab(
                text: 'Machine Features',
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: StreamBuilder<DeviceData?>(
                stream: ftmsBloc.ftmsDeviceDataControllerStream,
                builder: (c, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        const Center(child: Text("No FTMSData found!")),
                        ElevatedButton(
                          onPressed: () async {
                            await FTMS.useDeviceDataCharacteristic(
                                widget.ftmsDevice, (DeviceData data) {
                              ftmsBloc.ftmsDeviceDataControllerSink.add(data);
                            });
                          },
                          child: const Text("use FTMS"),
                        ),
                      ],
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          FTMS.convertDeviceDataTypeToString(
                              snapshot.data!.deviceDataType),
                          textScaler: const TextScaler.linear(4),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!
                              .getDeviceDataParameterValues()
                              .map((parameterValue) => Text(
                                    parameterValue.toString(),
                                    textScaler: const TextScaler.linear(2),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SingleChildScrollView(
              child: StreamBuilder<DeviceData?>(
                stream: ftmsBloc.ftmsDeviceDataControllerStream,
                builder: (c, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        const Center(child: Text("No FTMSData found!")),
                        ElevatedButton(
                          onPressed: () async {
                            await FTMS.useDeviceDataCharacteristic(
                                widget.ftmsDevice, (DeviceData data) {
                              ftmsBloc.ftmsDeviceDataControllerSink.add(data);
                            });
                          },
                          child: const Text("use FTMS"),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Text(
                        "Device Data Features",
                        textScaler: const TextScaler.linear(3),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Column(
                        children: snapshot.data!
                            .getDeviceDataFeatures()
                            .entries
                            .toList()
                            .map((entry) =>
                                Text('${entry.key.name}: ${entry.value}'))
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              children: [
                MachineFeatureWidget(ftmsDevice: widget.ftmsDevice),
                const Divider(
                  height: 2,
                ),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: MachineControlPointOpcodeType.values
                        .map(
                          (MachineControlPointOpcodeType opcodeType) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: OutlinedButton(
                              onPressed: () => writeCommand(opcodeType),
                              child: Text(opcodeType.name),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MachineFeatureWidget extends StatefulWidget {
  final BluetoothDevice ftmsDevice;

  const MachineFeatureWidget({super.key, required this.ftmsDevice});

  @override
  State<MachineFeatureWidget> createState() => _MachineFeatureWidgetState();
}

class _MachineFeatureWidgetState extends State<MachineFeatureWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ftmsBloc.ftmsMachineFeaturesControllerStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            children: [
              const Text("No Machine Features found!"),
              ElevatedButton(
                  onPressed: () async {
                    MachineFeature? machineFeature = await FTMS
                        .readMachineFeatureCharacteristic(widget.ftmsDevice);
                    ftmsBloc.ftmsMachineFeaturesControllerSink
                        .add(machineFeature);
                  },
                  child: const Text("get Machine Features")),
            ],
          );
        }
        return Column(
          children: snapshot.data!
              .getFeatureFlags()
              .entries
              .toList()
              .where((element) => element.value)
              .map((entry) => Text('${entry.key.name}: ${entry.value}'))
              .toList(),
        );
      },
    );
  }
}

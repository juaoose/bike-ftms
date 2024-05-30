import 'package:bike_ftms/bloc.dart';
import 'package:bike_ftms/models/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutPlayerScreen extends ConsumerWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceProvider);
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
        ),
        body: device == null
            ? const Text("No connected device")
            : SingleChildScrollView(
                child: StreamBuilder<DeviceData?>(
                  stream: ftmsBloc.ftmsDeviceDataControllerStream,
                  builder: (c, snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                        children: [
                          const Center(child: Text("No FTMSData found!")),
                          ElevatedButton(
                            onPressed: () async {
                              await FTMS.useDeviceDataCharacteristic(device,
                                  (DeviceData data) {
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
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
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
              ));
  }
}

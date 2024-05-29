import 'package:bike_ftms/models/fit_workout.dart';
import 'package:fit_tool/fit_tool.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StaticWorkoutGraph extends StatelessWidget {
  final FitFileState state;

  const StaticWorkoutGraph({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3,
          child: LineChart(
            LineChartData(
                minX: 0,
                maxX: workoutDuration(state.workoutSteps),
                minY: 0,
                maxY: 500,
                lineBarsData: [
                  LineChartBarData(
                    isStepLineChart: true,
                    isCurved: false,
                    spots: mapSteps(state.workoutSteps),
                    barWidth: 1,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue,
                    ),
                  ),
                ]),
          ),
        ),
      ],
    );
  }

  double workoutDuration(List<WorkoutStepMessage>? steps) {
    if (steps == null) {
      return 0;
    }

    double duration = 0;

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.durationType == WorkoutStepDuration.time) {
        duration += step.durationTime!.toDouble();
      } else if (step.durationType ==
          WorkoutStepDuration.repeatUntilStepsCmplt) {
        final numRepeats = step.targetValue!;
        final startRepeatIndex = step.durationValue!;
        final endRepeatIndex = i;

        for (int j = 0; j < numRepeats; j++) {
          for (int k = startRepeatIndex; k < endRepeatIndex; k++) {
            final repeatStep = steps[k];
            if (repeatStep.durationType == WorkoutStepDuration.time) {
              duration += repeatStep.durationTime!.toDouble();
            }
          }
        }
      }
    }
    return duration;
  }

  // Converts the FIT file steps to spots on a graph
  List<FlSpot> mapSteps(List<WorkoutStepMessage>? steps) {
    List<FlSpot> spots = [];

    if (steps == null) {
      return spots;
    }

    double initialX = 0;
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.durationType == WorkoutStepDuration.time) {
        final power = step.customTargetPowerHigh!.toDouble() - 1000;
        double durationTime = step.durationTime!.toDouble();
        spots.add(FlSpot(initialX, power));
        initialX += durationTime;
        spots.add(FlSpot(initialX, power));
      } else if (step.durationType ==
          WorkoutStepDuration.repeatUntilStepsCmplt) {
        // These messages signal that we repeat intervals
        final numRepeats = step.targetValue!;
        final startRepeatIndex = step.durationValue!;
        final endRepeatIndex = i;

        for (int j = 0; j < numRepeats; j++) {
          for (int k = startRepeatIndex; k < endRepeatIndex; k++) {
            final repeatStep = steps[k];
            final power = repeatStep.customTargetPowerHigh!.toDouble() - 1000;
            double durationTime = repeatStep.durationTime!.toDouble();
            spots.add(FlSpot(initialX, power));
            initialX += durationTime;
            spots.add(FlSpot(initialX, power));
          }
        }
      }
    }
    return spots;
  }
}

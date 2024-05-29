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
                maxX: 9000,
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
    //TODO
    return 2000;
  }

  // Converts the FIT file steps to spots on a graph
  List<FlSpot> mapSteps(List<WorkoutStepMessage>? steps) {
    List<FlSpot> spots = [];

    if (steps == null) {
      return spots;
    }

    double initialX = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.durationType == WorkoutStepDuration.time) {
        final power = step.customTargetPowerHigh!.toDouble() - 1000;
        spots.add(FlSpot(initialX, power));
        var finalX = initialX + step.durationTime!.toDouble();
        spots.add(FlSpot(finalX, power));
        initialX = initialX + step.durationTime!.toDouble();
      } else if (step.durationType ==
          WorkoutStepDuration.repeatUntilStepsCmplt) {
        // We need to repeat the previous X steps
        final numRepeats = step.targetValue!;
        final stepsToRepeat = steps.sublist(step.durationValue!, i);
        for (int j = 0; j < numRepeats; j++) {
          for (int k = 0; k < stepsToRepeat.length; k++) {
            final repeatStep = stepsToRepeat[k];
            final power = repeatStep.customTargetPowerHigh!.toDouble() - 1000;
            spots.add(FlSpot(initialX, power));
            var finalX = initialX + repeatStep.durationTime!.toDouble();
            spots.add(FlSpot(finalX, power));
            initialX = finalX;
          }
        }
      }
    }
    return spots;
  }
}

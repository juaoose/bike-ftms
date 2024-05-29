import 'package:bike_ftms/models/fit_workout.dart';
import 'package:bike_ftms/screens/workout.dart';
import 'package:bike_ftms/static_workout_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileSelectionScreen extends ConsumerWidget {
  const FileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fitFileState = ref.watch(fitFileProvider);
    final fitFileNotifier = ref.read(fitFileProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => fitFileNotifier.pickFile(),
          child: const Text('Pick File'),
        ),
        if (fitFileState.isLoading)
          const CircularProgressIndicator()
        else if (fitFileState.workoutName != null)
          Text(
              'FIT File Result: ${fitFileState.workoutName} ${fitFileState.workoutSteps?.length}')
        else if (fitFileState.errorMessage != null)
          Text('Error: ${fitFileState.errorMessage}'),
        if (fitFileState.selectedFile != null)
          StaticWorkoutGraph(state: fitFileState),
        if (fitFileState.selectedFile != null)
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkoutPlayerScreen()),
                );
              },
              child: const Text("Start!"))
      ],
    );
  }
}

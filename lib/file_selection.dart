import 'package:bike_ftms/models/fit_workout.dart';
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
        const SizedBox(height: 20),
        if (fitFileState.selectedFile != null)
          Text('Selected File: ${fitFileState.selectedFile!.name}')
        else
          const Text('No file selected'),
        const SizedBox(height: 20),
        if (fitFileState.isLoading)
          const CircularProgressIndicator()
        else if (fitFileState.workoutName != null)
          Text(
              'FIT File Result: ${fitFileState.workoutName} ${fitFileState.workoutSteps?.length}')
        else if (fitFileState.errorMessage != null)
          Text('Error: ${fitFileState.errorMessage}'),
      ],
    );
  }
}

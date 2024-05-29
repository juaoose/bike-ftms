import 'package:fit_tool/fit_tool.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class FitFileState {
  final PlatformFile? selectedFile;
  final String? workoutName;
  final List<WorkoutStepMessage>? workoutSteps;
  final bool isLoading;
  final String? errorMessage;

  FitFileState({
    this.selectedFile,
    this.workoutName,
    this.workoutSteps,
    this.isLoading = false,
    this.errorMessage,
  });

  FitFileState copyWith({
    PlatformFile? selectedFile,
    String? workoutName,
    List<WorkoutStepMessage>? workoutSteps,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FitFileState(
      selectedFile: selectedFile ?? this.selectedFile,
      workoutName: workoutName ?? this.workoutName,
      workoutSteps: workoutSteps ?? this.workoutSteps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FitFileNotifier extends StateNotifier<FitFileState> {
  FitFileNotifier() : super(FitFileState());

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withReadStream: true);

    if (result != null) {
      state = state.copyWith(
        selectedFile: result.files.first,
        isLoading: true,
        errorMessage: null,
      );
      _processFitFile(result.files.first);
    }
  }

  Future<void> _processFitFile(PlatformFile file) async {
    try {
      final stream = file.readStream;

      if (stream == null) {
        throw Exception('Cannot read file from null stream');
      }

      final fitStream = stream.transform(FitDecoder());

      String? workoutName = "Undefined";
      final List<WorkoutStepMessage> steps = [];
      await for (final message in fitStream) {
        if (message is WorkoutMessage) {
          workoutName = message.workoutName;
        } else if (message is WorkoutStepMessage) {
          steps.add(message);
        }
      }

      state = state.copyWith(
        workoutName: workoutName,
        workoutSteps: steps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error processing file',
        isLoading: false,
      );
    }
  }
}

final fitFileProvider = StateNotifierProvider<FitFileNotifier, FitFileState>(
  (ref) => FitFileNotifier(),
);

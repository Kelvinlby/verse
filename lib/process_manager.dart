import 'dart:async';
import 'dart:io';


typedef ProcessCompletionCallback = void Function();
bool xlaPreAllocatingStatus = true;
int preAllocationRate = 75;


abstract class ProcessManager {
  static Process? _process;
  static StreamSubscription? _stdoutSubscription;
  static StreamSubscription? _stderrSubscription;
  static ProcessCompletionCallback? _onNaturalCompletion;

  static Future<bool> start(String interpreterPath, String scriptPath, Map<String, String> env, {ProcessCompletionCallback? callback, Function? error}) async {
    try {
      await stop();
      _onNaturalCompletion = callback;

      // Start the process with proper environment setup
      env.addAll({'PYTHONUNBUFFERED': '1'});

      _process = await Process.start(
        interpreterPath,
        ['-u', scriptPath],
        environment: env,
        workingDirectory: Directory(scriptPath).parent.path,
      );

      // Set up output handling
      _stdoutSubscription = _process?.stdout.listen((data) {
          // print('Python stdout: ${String.fromCharCodes(data)}');
        },
        onError: (error) {} // print('stdout error: $error'),
      );

      _stderrSubscription = _process?.stderr.listen((data) {
          error?.call(String.fromCharCodes(data));
        },
        onError: (error) {} // print('stderr error: $error'),
      );

      // Set up process exit handling
      _process?.exitCode.then((code) {
        _onNaturalCompletion?.call();
        // print('Process exited with code: $code');
        _cleanup();
      }).catchError((error) {
        // print('Process error: $error');
        _cleanup();
      });

      return true;
    }
    catch (e) {
      // print('Failed to start process: $e');
      await _cleanup();
      return false;
    }
  }

  static Future<void> stop() async {
    await _cleanup();
  }

  static Future<void> _cleanup() async {
    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();
    _process?.kill();
    _process = null;
  }

  static bool get isRunning => _process != null;
}
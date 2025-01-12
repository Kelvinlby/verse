import 'dart:async';
import 'dart:io';


abstract class ProcessManager {
  static Process? _process;
  static StreamSubscription? _stdoutSubscription;
  static StreamSubscription? _stderrSubscription;

  static Future<bool> start(String interpreterPath, String scriptPath, Map<String, String> env, {Function? listener, Function? finish, Function? error}) async {
    try {
      await stop();

      _process = await Process.start(
        interpreterPath,
        ['-u', scriptPath],
        environment: env,
        workingDirectory: Directory(scriptPath).parent.path,
      );

      _stdoutSubscription = _process?.stdout.listen((data) {
          listener?.call(String.fromCharCodes(data));
        },
        onError: (e) {}
      );

      _stderrSubscription = _process?.stderr.listen((data) {
          error?.call(String.fromCharCodes(data));
        },
        onError: (e) {}
      );

      _process?.exitCode.then((code) {
        finish?.call();
        _cleanup();
      }).catchError((e) {
        _cleanup();
      });

      return true;
    }
    catch (e) {
      error?.call('Launch Failed: \n$e');
      await _cleanup();
      return false;
    }
  }

  static void input(String str) {
    _process?.stdin.writeln(str);
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
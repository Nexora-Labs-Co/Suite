import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _CompareVersionsC = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _CompareVersionsDart = int Function(Pointer<Utf8>, Pointer<Utf8>);

typedef _IsOnPathC = Int32 Function(Pointer<Utf8>);
typedef _IsOnPathDart = int Function(Pointer<Utf8>);

/// Thin, optional binding to the Rust `nexora_core` library.
///
/// The library is loaded lazily. If it is not available (for example in a
/// pure-Dart run) every method falls back to a Dart implementation so the
/// application keeps working.
class NexoraCore {
  NexoraCore._();

  static DynamicLibrary? _lib;

  static DynamicLibrary? get _instance {
    if (_lib != null) return _lib;
    try {
      if (Platform.isLinux) {
        _lib = DynamicLibrary.open('libnexora_core.so');
      } else if (Platform.isWindows) {
        _lib = DynamicLibrary.open('nexora_core.dll');
      }
    } catch (_) {
      _lib = null;
    }
    return _lib;
  }

  static bool get isAvailable => _instance != null;

  static int compareVersions(String a, String b) {
    final lib = _instance;
    if (lib == null) {
      return _dartCompareVersions(a, b);
    }
    final fn = lib.lookupFunction<_CompareVersionsC, _CompareVersionsDart>(
      'nexora_compare_versions',
    );
    final pa = a.toNativeUtf8();
    final pb = b.toNativeUtf8();
    final result = fn(pa, pb);
    malloc.free(pa);
    malloc.free(pb);
    return result;
  }

  static bool isOnPath(String name) {
    final lib = _instance;
    if (lib == null) {
      return _dartIsOnPath(name);
    }
    final fn = lib.lookupFunction<_IsOnPathC, _IsOnPathDart>('nexora_is_on_path');
    final pn = name.toNativeUtf8();
    final result = fn(pn) == 1;
    malloc.free(pn);
    return result;
  }

  static int _dartCompareVersions(String a, String b) {
    final pa = a.split('.').map((x) => int.tryParse(x.trim()) ?? 0).toList();
    final pb = b.split('.').map((x) => int.tryParse(x.trim()) ?? 0).toList();
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va < vb) return -1;
      if (va > vb) return 1;
    }
    return 0;
  }

  static bool _dartIsOnPath(String name) {
    final pathVar = Platform.environment['PATH'] ?? '';
    final sep = Platform.isWindows ? ';' : ':';
    for (final dir in pathVar.split(sep)) {
      final candidate = File('$dir/$name');
      if (candidate.existsSync()) return true;
    }
    return false;
  }
}

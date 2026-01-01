import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/di/injection_container.dart';

final backendConnectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  Timer? _timer;
  final Dio _dio = sl<Dio>();

  ConnectivityNotifier() : super(false) {
    _statusCheck();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _statusCheck());
  }

  Future<void> _statusCheck() async {
    try {
      final response = await _dio.get('http://localhost:8000/health').timeout(const Duration(seconds: 2));
      state = response.statusCode == 200 && response.data['ollama_connected'] == true;
    } catch (_) {
      state = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Some versions of StateNotifier may not have a dispose method to override or call super on.
    // If you are using a version where super.dispose() is required, uncomment it.
    // super.dispose();
  }
}

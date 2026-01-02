import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/di/injection_container.dart';

class ConnectivityNotifier extends Notifier<bool> {
  Timer? _timer;
  late final Dio _dio;

  @override
  bool build() {
    _dio = sl<Dio>();
    _startTimer();
    return false; // Initial state
  }

  void _startTimer() {
    _timer?.cancel();
    _statusCheck();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _statusCheck());
  }

  Future<void> _statusCheck() async {
    try {
      final response = await _dio.get('http://127.0.0.1:8000/health').timeout(const Duration(seconds: 2));
      // Even if ollama is not connected, the Aura backend itself is online.
      state = response.statusCode == 200;
      
      // We could ideally emit a more complex state (Online, AI-Disconnected, Offline)
      // but for now, if the server answers, we are "Online".
    } catch (_) {
      state = false;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}

final backendConnectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);

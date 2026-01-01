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
      final response = await _dio.get('http://localhost:8000/health').timeout(const Duration(seconds: 2));
      state = response.statusCode == 200 && response.data['ollama_connected'] == true;
    } catch (_) {
      state = false;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}

final backendConnectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);

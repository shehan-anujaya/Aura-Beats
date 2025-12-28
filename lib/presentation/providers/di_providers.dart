import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ollama_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OllamaRepositoryImpl(dio);
});

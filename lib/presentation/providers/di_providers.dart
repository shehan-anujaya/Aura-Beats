import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/ollama_service.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';

// Framework/External Services
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Data Sources
final ollamaServiceProvider = Provider<OllamaService>((ref) {
  final dio = ref.watch(dioProvider);
  return OllamaService(dio);
});

// Repositories
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final ollamaService = ref.watch(ollamaServiceProvider);
  return AIRepositoryImpl(ollamaService);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return ChatRepositoryImpl(localStorage);
});

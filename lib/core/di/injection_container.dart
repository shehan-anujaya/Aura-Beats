import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/remote/ollama_service.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_song_suggestions.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/save_chat_message.dart';
import '../../domain/usecases/clear_chat_history.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use cases
  sl.registerLazySingleton(() => GetSongSuggestions(sl()));
  sl.registerLazySingleton(() => GetChatHistory(sl()));
  sl.registerLazySingleton(() => SaveChatMessage(sl()));
  sl.registerLazySingleton(() => ClearChatHistory(sl()));

  // Repositories
  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton(() => OllamaService(sl()));
  sl.registerLazySingleton(() => LocalStorageService());

  // External
  sl.registerLazySingleton(() => Dio());
}

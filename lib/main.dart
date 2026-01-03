import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/chat_screen.dart';
import 'data/datasources/local_storage_service.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/theme_provider.dart';
import 'presentation/services/system_tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  // Init DI
  await di.init();
  
  try {
    // Init Hive via DI
    await di.sl<LocalStorageService>().init();
    // Init System Tray
    await SystemTrayService().init();
  } catch (e) {
    debugPrint("Initialization error: $e");
    if (e.toString().contains('lock failed')) {
      debugPrint("AuraBeats is already running. Please check your system tray.");
      // In a real app we might show a native dialog here.
      // For now, exiting gracefully to avoid crash dumps.
      return; 
    }
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // Custom window frame
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AuraBeats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeMode),
      home: const ChatScreen(),
    );
  }
}

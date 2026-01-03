import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/chat_screen.dart';
import 'data/datasources/local_storage_service.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/services/system_tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  // Init DI
  await di.init();
  
  // Init Hive via DI
  await di.sl<LocalStorageService>().init();

  // Init System Tray
  await SystemTrayService().init();

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

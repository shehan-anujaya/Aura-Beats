import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../widgets/song_card.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/glass_container.dart';
import '../providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final themeMode = ref.watch(themeProvider);
    final isSpotify = themeMode == AuraThemeMode.spotify;

    return Scaffold(
      body: Stack(
        children: [
          // Background (Matching ChatScreen)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSpotify 
                    ? [const Color(0xFF121212), const Color(0xFF181818)]
                    : [
                        const Color(0xFF0F0C29),
                        const Color(0xFF302B63),
                        const Color(0xFF24243E),
                      ],
              ),
            ),
          ),
          
          Column(
            children: [
              const CustomTitleBar(showBackButton: true),
              
              Expanded(
                child: favorites.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          return SongCard(song: favorites[index]);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              "No favorites yet",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start exploring your vibes and like some tracks!",
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

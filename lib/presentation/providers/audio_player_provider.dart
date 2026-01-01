import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlaybackState {
  final String? playingUrl;
  final bool isPlaying;
  final bool isLoading;

  AudioPlaybackState({
    this.playingUrl,
    this.isPlaying = false,
    this.isLoading = false,
  });

  AudioPlaybackState copyWith({
    String? playingUrl,
    bool? isPlaying,
    bool? isLoading,
  }) {
    return AudioPlaybackState(
      playingUrl: playingUrl ?? this.playingUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlaybackState> {
  late final AudioPlayer _player;

  @override
  AudioPlaybackState build() {
    _player = AudioPlayer();
    
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        this.state = this.state.copyWith(isPlaying: false);
      }
    });

    // Cleanup when provider is disposed
    ref.onDispose(() {
      _player.dispose();
    });

    return AudioPlaybackState();
  }

  Future<void> playPreview(String url) async {
    if (state.playingUrl == url && state.isPlaying) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    try {
      state = state.copyWith(isLoading: true, playingUrl: url);
      await _player.stop();
      await _player.play(UrlSource(url));
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, isPlaying: false);
      print("Error playing audio: $e");
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, playingUrl: null);
  }
}

final audioPlaybackProvider = NotifierProvider<AudioPlayerNotifier, AudioPlaybackState>(AudioPlayerNotifier.new);

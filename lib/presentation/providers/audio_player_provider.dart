import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlaybackState {
  final String? playingUrl;
  final String? currentMood;
  final bool isPlaying;
  final bool isLoading;
  final bool hasJustFinished;
  final Duration position;
  final Duration duration;

  AudioPlaybackState({
    this.playingUrl,
    this.currentMood,
    this.isPlaying = false,
    this.isLoading = false,
    this.hasJustFinished = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioPlaybackState copyWith({
    String? playingUrl,
    String? currentMood,
    bool? isPlaying,
    bool? isLoading,
    bool? hasJustFinished,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlaybackState(
      playingUrl: playingUrl ?? this.playingUrl,
      currentMood: currentMood ?? this.currentMood,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      hasJustFinished: hasJustFinished ?? this.hasJustFinished,
      position: position ?? this.position,
      duration: duration ?? this.duration,
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
        this.state = this.state.copyWith(
          isPlaying: false,
          hasJustFinished: true,
          position: Duration.zero,
        );
      }
    });

    _player.onPositionChanged.listen((p) {
      this.state = this.state.copyWith(position: p);
    });

    _player.onDurationChanged.listen((d) {
      this.state = this.state.copyWith(duration: d);
    });

    ref.onDispose(() {
      _player.dispose();
    });

    return AudioPlaybackState();
  }

  Future<void> playPreview(String url, String mood) async {
    if (state.playingUrl == url && state.isPlaying) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    if (state.playingUrl == url && !state.isPlaying && state.position != Duration.zero) {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true, 
        playingUrl: url, 
        currentMood: mood,
        hasJustFinished: false,
        position: Duration.zero,
        duration: Duration.zero,
      );
      await _player.stop();
      await _player.play(UrlSource(url));
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, isPlaying: false);
      print("Error playing audio: $e");
    }
  }

  void resetFinished() {
    state = state.copyWith(hasJustFinished: false);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      isPlaying: false, 
      playingUrl: null, 
      currentMood: null,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }
}

final audioPlaybackProvider = NotifierProvider<AudioPlayerNotifier, AudioPlaybackState>(AudioPlayerNotifier.new);

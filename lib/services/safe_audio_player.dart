import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Serializes [AudioPlayer] work so overlapping [play] / [stop] / [dispose]
/// calls do not leak Swift continuations in audioplayers_darwin.
final class SafeAudioPlayer {
  SafeAudioPlayer() : _player = AudioPlayer() {
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
  }

  final AudioPlayer _player;
  Future<void> _chain = Future.value();

  Future<void> playAsset(String assetPath) {
    _chain = _chain.then((_) async {
      try {
        await _player.stop();
        await _player.play(AssetSource(assetPath));
      } catch (_) {}
    });
    return _chain;
  }

  Future<void> stop() {
    _chain = _chain.then((_) async {
      try {
        await _player.stop();
      } catch (_) {}
    });
    return _chain;
  }

  Future<void> dispose() {
    _chain = _chain.then((_) async {
      try {
        await _player.stop();
      } catch (_) {}
      await _player.dispose();
    });
    return _chain;
  }
}

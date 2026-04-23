import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_storage.dart';

/// 🔊 Dịch vụ âm thanh toàn app: click + correct/wrong + nhạc nền
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _musicPlaying = false;

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Các asset audio dùng trong app
  static const String _musicAsset = 'audio/bg_music.mp3';
  static const String _clickAsset = 'audio/click.mp3';
  static const String _correctAsset = 'audio/amthanh_dung.mp3';
  static const String _wrongAsset = 'audio/amthanh_sai.mp3';

  /// Khởi tạo dịch vụ - gọi 1 lần ở main.dart sau Firebase.initializeApp
  /// Bọc toàn bộ trong try/catch để lỗi audio không chặn app khởi động
  Future<void> init() async {
    try {
      _soundEnabled = await LocalStorage.getSoundEnabled();
      _musicEnabled = await LocalStorage.getMusicEnabled();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService: đọc settings lỗi ($e)');
    }

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.35);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(0.8);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService: cấu hình player lỗi ($e)');
    }

    if (_musicEnabled) {
      // Không await — để app khởi động ngay, nhạc nền lên sau nếu được
      unawaited(startMusic());
    }
  }

  /// Phát âm thanh click (hệ thống, không cần asset)
  void playClick() {
    if (!_soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  /// Phat click.mp3 cho cac thao tac UI (vd: mua goi thanh cong)
  Future<void> playUiClickAsset() async {
    if (!_soundEnabled) return;
    HapticFeedback.selectionClick();
    await _playSfx(_clickAsset);
  }

  /// Phát âm thanh khi trả lời đúng (file mp3, fallback SystemSound)
  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
    await _playSfx(_correctAsset);
  }

  /// Phát âm thanh khi trả lời sai (file mp3, fallback SystemSound)
  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
    await _playSfx(_wrongAsset, fallback: SystemSoundType.alert);
  }

  Future<void> _playSfx(String asset,
      {SystemSoundType fallback = SystemSoundType.click}) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService: không phát được sfx $asset ($e)');
      }
      SystemSound.play(fallback);
    }
  }

  /// Bắt đầu phát nhạc nền (loop) — im lặng nếu không có file
  Future<void> startMusic() async {
    if (!_musicEnabled || _musicPlaying) return;
    try {
      await _musicPlayer.play(AssetSource(_musicAsset));
      _musicPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService: không phát được nhạc nền ($e)');
      }
      _musicPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    if (!_musicPlaying) return;
    await _musicPlayer.stop();
    _musicPlaying = false;
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    if (value) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

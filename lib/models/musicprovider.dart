import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SNAMP/models/cacheprovider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/pages/song.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'innertube.dart';
import 'dart:math';

class MusicProvider extends ChangeNotifier {
  final InnertubeProto innertube;
  final CacheProvider cacher;
  final rng = Random();

  // Constructor
  MusicProvider({required this.innertube, required this.cacher}) {
    listenToDuration();
  }

  List<SearchCard> _queue = [];
  int? _currentIndex;
  bool _isLoopActive = false;
  bool _isShuffleActive = false;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  bool _isLoading = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  int? get currentIndex => _currentIndex;
  List<SearchCard> get queue => _queue;
  bool get isPlaying => _isPlaying;
  bool get isLoopActive => _isLoopActive;
  bool get isShuffleActive => _isShuffleActive;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  double get currentSpeed => _currentSpeed;

  set currentSpeed(double newSpeed) {
    _currentSpeed = newSpeed;
    _audioPlayer.setSpeed(newSpeed);
    notifyListeners();
  }

  set currentIndex(int? index) {
    if (_isLoading) return; // Prevent setting index while loading
    setCurrentIndex(index);
  }

  Future<void> setCurrentIndex(int? index) async {
    if (index == null || index == _currentIndex) return; // Prevent setting the same index

    // Cancel loading if already loading a new track
    if (_isLoading) {
      await stop(); // Stop the current track if necessary
      _currentIndex = null; // Reset current index to indicate that we are not playing any track
    }

    SearchCard? newCard;

    try {
      _isLoading = true; // Set loading state to true
      notifyListeners(); // Notify UI about loading state change

      _currentIndex = index;

      // Wait for a short duration before loading the track
      await Future.delayed(const Duration(milliseconds: 500)); // Adjust the delay as needed

      // Load the new track
      newCard = await loadTrack(_queue[_currentIndex!]);
      if (newCard != null) {
        await _audioPlayer.setAudioSource(_createAudioSource(newCard));
        notifyListeners();
      }
    } catch (e) {
      print("Error in setCurrentIndex: $e");
      if (newCard != null) {
        await cacher.deleteTrack(newCard.id); // Await deletion if needed
      }
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners(); // Notify UI that loading is complete
    }

    await play(); // Play the new track
  }

  Future<void> setQueue(List<SearchCard> playlist) async {
    _queue = playlist;
    notifyListeners(); // Notify listeners about the new queue
  }

  Future<void> addToQueue(List<SearchCard> newTracks) async {
    _queue.addAll(newTracks);
    notifyListeners(); // Notify listeners about the updated queue
  }

  AudioSource _createAudioSource(SearchCard card) {
    return LockCachingAudioSource(
      Uri.parse(card.url),
      tag: MediaItem(
        id: card.id,
        artist: card.desc,
        title: card.name,
        artUri: Uri.parse(card.thumbnail),
      ),
    );
  }

  Future<void> goToSongPage(BuildContext context, List<SearchCard> playlist, int? index) async {
    await _audioPlayer.stop();
    await setQueue(playlist);
    currentIndex = index; // Use setter to notify listeners
    currentSpeed = 1.0; // Reset speed to default

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Song(), // Your Song page widget
      ),
    );
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      notifyListeners(); // Notify listeners about the stop state
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  Future<void> play() async {
    if (_currentIndex != null) {
      try {
        await _audioPlayer.seek(Duration.zero, index: _currentIndex!);
        _isPlaying = true;
        await _audioPlayer.play();
        notifyListeners(); // Notify listeners about the play state
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  Future<void> pause() async {
    try {
      _isPlaying = false;
      await _audioPlayer.pause();
      notifyListeners(); // Notify listeners about the pause state
    } catch (e) {
      print("Error pausing audio: $e");
    }
  }

  Future<void> resume() async {
    try {
      _isPlaying = true;
      await _audioPlayer.play();
      notifyListeners(); // Notify listeners about the resume state
    } catch (e) {
      print("Error resuming audio: $e");
    }
  }

  void toggle() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  Future<void> seek(Duration duration) async {
    try {
      await _audioPlayer.seek(duration);
    } catch (e) {
      print("Error seeking audio: $e");
    }
  }

  void playNext() {
    stop();
    if (_currentIndex != null) {
      if (_currentIndex! < _queue.length - 1) {
        currentIndex = _currentIndex! + 1;
      } else {
        currentIndex = 0; // Loop back to the first song if at the end
      }
      play();
    }
  }

  void playPrev() {
    if (_currentDuration.inSeconds >= 5) {
      seek(Duration.zero); // Go back to the start of the current track
    } else {
      stop();
      if (_currentIndex != null && _currentIndex! > 0) {
        currentIndex = _currentIndex! - 1;
      } else {
        currentIndex = _queue.length - 1; // Loop back to the last song if at the start
      }
    }
    play();
  }

  void toggleLoop() {
    _isLoopActive = !_isLoopActive;
    _isShuffleActive ? !_isShuffleActive : _isShuffleActive;
    _audioPlayer.setLoopMode(_isLoopActive ? LoopMode.one : LoopMode.off);
    notifyListeners(); // Notify listeners about the loop state change
  }

  void toggleShuffle() {
    _isShuffleActive = !_isShuffleActive;
    _isLoopActive ? !_isLoopActive : _isLoopActive;
    notifyListeners(); 
  }

  Future<void> changeSpeed(double speed) async {
    try {
      currentSpeed = speed; // This will also set the speed in the AudioPlayer
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      print("Error changing speed: $e");
    }
  }

  Future<SearchCard?> loadTrack(SearchCard selected, [int? recursiveCounter]) async {
   // var thumbnail = selected.thumbnail.contains("=w60-h60")
     //   ? selected.thumbnail.replaceAll("=w60-h60", "=w300-h300")
     //   : selected.thumbnail;

   // selected.thumbnail = thumbnail;

    var test = await cacher.containsSearchCard(selected.id);
    if (test == true) {
      print("MUSPROV: cached");
      var result = await cacher.getSearchCard(selected.id);
      return result;
    } else {
      var result = await innertube.player(selected.id, false);
      if (result != null && result.isNotEmpty) {
        selected.url = result;
        await cacher.addTrack(selected); // Await the add operation
        print("RETURNING");
        return selected;
      } else {
        print("Failed to fetch audio URL for track ID: ${selected.id}");
        return null;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.durationStream.listen((newDuration) {
      _totalDuration = newDuration ?? Duration.zero;
      notifyListeners(); // Notify listeners about the total duration change
    });

    _audioPlayer.positionStream.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners(); // Notify listeners about the current position change
    });

    _audioPlayer.currentIndexStream.listen((newIndex) {
      if (newIndex != _currentIndex) {
        currentIndex = newIndex; // Use setter to notify listeners
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          print("Player is idle.");
          _isLoading = false; // Reset loading state
          notifyListeners(); // Notify UI about loading state
          break;
        case ProcessingState.loading:
          print("Loading audio source...");
          _isLoading = true; // Set loading state
          notifyListeners(); // Notify UI about loading state
          break;
        case ProcessingState.buffering:
          print("Buffering audio...");
          _isLoading = true; // Set loading state
          notifyListeners(); // Notify UI about loading state
          break;
        case ProcessingState.ready:
          print("Ready to play.");
          _isLoading = false; // Reset loading state
          notifyListeners(); // Notify UI about loading state
          break;
        case ProcessingState.completed:
          print("Playback completed.");
          if (_isLoopActive) {
            play();
          } else if (_isShuffleActive) {
            currentIndex = rng.nextInt(_queue.length);
          } else {
            playNext();
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

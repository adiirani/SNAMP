import 'package:flutter/material.dart';
import 'package:SNAMP/models/cacheprovider.dart';
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:SNAMP/models/templates/searchCard.dart';

class PlaylistProvider extends ChangeNotifier {
  CacheProvider cacher;
  List<SearchPlaylist> playlists = [];

  // Constructor (Sync)
  PlaylistProvider({required this.cacher}) {
    _initPlaylists(); // Call the async method here
  }

  // Async method to load playlists
  Future<void> _initPlaylists() async {
    try {
      List<SearchPlaylist>? cachedPlaylists = await cacher.listPlaylists();
      print(cachedPlaylists);
      if (cachedPlaylists.isNotEmpty) {
        playlists = cachedPlaylists;
        print(playlists);
      } else {
        playlists = [
          SearchPlaylist(
            searchPlaylistName: "Favorites",
            searchPlaylistDesc: "Your favorite tracks",
            searchPlaylistQueue: [],
          ),
        ];
        cacher.addSearchPlaylist(playlists[0]);
      }
      notifyListeners(); // Notify listeners after playlists are loaded
    } catch (e) {
      // Handle errors gracefully if needed
      print("Error loading playlists: $e");
    }
  }

  // Other methods...

  void addPlaylist(String playlistName, String playlistDescription, String playlistImage) {
    bool playlistExists = playlists.any((playlist) => playlist.searchPlaylistName == playlistName);
    if (playlistExists) {
      throw Exception("ERROR: A playlist with the name '$playlistName' already exists.");
    }
    SearchPlaylist newPlaylist = SearchPlaylist(
      searchPlaylistName: playlistName,
      searchPlaylistDesc: playlistDescription,
      searchPlaylistQueue: [],
      searchPlaylistImage: playlistImage,
    );
    playlists.add(newPlaylist);
    cacher.addSearchPlaylist(newPlaylist);
    notifyListeners();
  }

  void removePlaylist(String playlistName) {
    if (playlistName == "Favorites") {
      throw Exception("ERROR: Cannot remove 'Favorites' playlist.");
    } else {
      playlists.removeWhere((playlist) => playlist.searchPlaylistName == playlistName);
      cacher.deleteSearchPlaylist(playlistName);
      notifyListeners();
    }
  }

  void addCardToPlaylist(String playlistName, SearchCard card) {
    final playlist = playlists.firstWhere(
      (playlist) => playlist.searchPlaylistName == playlistName,
      orElse: () => throw Exception("ERROR: Playlist not found."),
    );
    if (!_cardExistsInPlaylist(playlist, card)) {
      playlist.searchPlaylistQueue.add(card);
      playlist.searchPlaylistImage = card.thumbnail;
      
      cacher.addSearchPlaylist(playlist);
      notifyListeners();
    } else {
      throw Exception("ERROR: Card already exists in the playlist.");
    }
  }

  void removeCardFromPlaylist(String playlistName, String trackId) {
    final playlist = playlists.firstWhere(
      (playlist) => playlist.searchPlaylistName == playlistName,
      orElse: () => throw Exception("ERROR: Playlist not found."),
    );
    playlist.searchPlaylistQueue.removeWhere((card) => card.id == trackId);
    cacher.addSearchPlaylist(playlist);
    notifyListeners();
  }

  bool _cardExistsInPlaylist(SearchPlaylist playlist, SearchCard card) {
    return playlist.searchPlaylistQueue.any((existingCard) => existingCard.name == card.name);
  }

  bool playlistIsUserGenerated(SearchPlaylist playlist){
    return playlists.contains(playlist);
  }
}

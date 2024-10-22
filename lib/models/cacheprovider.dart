import 'package:hive/hive.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CacheProvider {
  static const String cacheBoxName = 'caches';
  static const String cachePlaylistName = 'searchPlaylists';
  static const int maxCacheSize = 100;

  // Add a SearchCard to the cache
  Future<void> addTrack(SearchCard track) async {
    final box = await Hive.openBox<SearchCard>(cacheBoxName);
    // Remove any existing occurrence of the track
    final existingKey = box.values.toList().indexWhere((t) => t.id == track.id);
    if (existingKey != -1) {
      print("CACHE: deleting duplicate");
      await box.deleteAt(existingKey);
    }

    // Add the new track at the end
    await box.put(track.id, track);

    // Enforce max size
    if (box.length > maxCacheSize) {
      await box.deleteAt(0); // Remove the oldest
    }
    print("CACHE: added");
    print(box.get(track.id));
  }

  // Retrieve a SearchCard by ID
  Future<SearchCard?> getSearchCard(String id) async {
    final box = await Hive.openBox<SearchCard>(cacheBoxName);
    print("CACHE: pulling");
    return box.get(id);
  }

  // Check if a specific SearchCard exists
  Future<bool> containsSearchCard(String id) async {
    final box = await Hive.openBox<SearchCard>(cacheBoxName);
    return box.containsKey(id);
  }

  // Delete a specific SearchCard from the cache
  Future<void> deleteTrack(String id) async {
    final box = await Hive.openBox<SearchCard>(cacheBoxName);
    if (box.containsKey(id)) {
      await box.delete(id);
      print("CACHE: deleted track with id: $id");
    } else {
      print("CACHE: track with id: $id not found");
    }
  }

  // Add a SearchPlaylist to the cache
  Future<void> addSearchPlaylist(SearchPlaylist playlist) async {
    final box = await Hive.openBox<SearchPlaylist>(cachePlaylistName);
    try{
      await box.delete(playlist.searchPlaylistName);
    } catch (e) {
      print("no box found, proceeding to add");
    }
    await box.put(playlist.searchPlaylistName, playlist);
    
    
  }

  // Retrieve a SearchPlaylist by name
  Future<SearchPlaylist?> getSearchPlaylist(String name) async {
    final box = await Hive.openBox<SearchPlaylist>(cachePlaylistName);
    return box.get(name);
  }

  // Delete a specific SearchPlaylist from the cache
  Future<void> deleteSearchPlaylist(String name) async {
    final box = await Hive.openBox<SearchPlaylist>(cachePlaylistName);
    if (box.containsKey(name)) {
      await box.delete(name);
      print("CACHE: deleted playlist with name: $name");
    } else {
      print("CACHE: playlist with name: $name not found");
    }
  }

  // Clear cache (for both SearchCard and SearchPlaylist)
  Future<void> clearCache() async {
    final cardBox = await Hive.openBox<SearchCard>(cacheBoxName);
    await cardBox.clear();
    print("CACHE: cleared caches");
    try {final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      // List all files in the temporary directory
      final tempFiles = Directory(tempPath).listSync();

      for (var file in tempFiles) {
        if (file is File) {
          // Delete each file
          await file.delete();
          print("Deleted temporary file: ${file.path}");
        }
      }
      print("TEMP DIRECTORY: Cleared all temporary files.");
      } catch (e) {
        print("Error clearing temp directory: $e");
      }
    
  }

  Future<void> nuke() async { //nukes everything, playlists etc
    await clearCache();
    try {
      final playlistsBox = await Hive.openBox<SearchCard>(cachePlaylistName);
      await playlistsBox.clear();
    } catch (e) {
      print("Error nuking cache data");
    }

  }

  // List all cached SearchCards
  Future<List<SearchCard>> listCache() async {
    final box = await Hive.openBox<SearchCard>(cacheBoxName);
    return box.values.toList();
  }

  // List all cached SearchPlaylists
  Future<List<SearchPlaylist>> listPlaylists() async {
    final box = await Hive.openBox<SearchPlaylist>(cachePlaylistName);
    return box.values.toList();
  }
}

import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:hive/hive.dart';

part 'searchPlaylist.g.dart';

@HiveType(typeId: 2)
class SearchPlaylist {
  @HiveField(1)
  final String searchPlaylistName;
  @HiveField(2)
  final String searchPlaylistDesc;
  @HiveField(3)
  List<SearchCard> searchPlaylistQueue;  // Mutable list of tracks
  @HiveField(4)
  String  searchPlaylistImage;       // Change dynamic to Widget for better type safety

  SearchPlaylist({
    required this.searchPlaylistName,
    required this.searchPlaylistDesc,
    required this.searchPlaylistQueue,
    this.searchPlaylistImage = ""
  });// Initialize mutable lis
}

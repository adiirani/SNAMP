import 'package:hive/hive.dart';


part 'searchCard.g.dart';

@HiveType(typeId: 1)
class SearchCard {
  @HiveField(1)
  final String name;      // Name of the track
  @HiveField(2)
  final String desc;  // Description of the track
  @HiveField(3)    
  String thumbnail;  // URL of the thumbnail image
  @HiveField(4)
  final String type;      // Type of the content (e.g., song, video)
  @HiveField(5)
  final String id;
  @HiveField(6)
  String url;        // ID of the track

  SearchCard({
    required this.name,
    required this.desc,
    required this.thumbnail,
    required this.type,
    required this.id,
    this.url = ""
  });
}

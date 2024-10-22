import 'dart:io';
import 'package:flutter/material.dart';
import 'package:SNAMP/models/innertube.dart';
import 'package:SNAMP/models/musicprovider.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:SNAMP/pages/subpages/artistDetails.dart';
import 'package:SNAMP/pages/subpages/fetchedPlaylistDetails.dart';
import 'package:provider/provider.dart';

const Map<String, String> filters = {
  "Songs": "FILTER_SONG",
  "Videos": "FILTER_VIDEO",
  "Albums": "FILTER_ALBUM",
  "Artists": "FILTER_ARTIST",
  "Featured Playlists": "FILTER_FEATURED_PLAYLIST",
  "Community Playlists": "FILTER_COMMUNITY_PLAYLIST",
};


//god all of this code is a mess
//i would compartmentalize and add a parse function to deal with the json but for they cant return data in a single standardized format


class SearchProvider extends ChangeNotifier {
  MusicProvider musicProvider;
  InnertubeProto innertube;
  SearchProvider({required this.musicProvider, required this.innertube});

  String _query = '';
  List<String> suggestions = [];
  List<SearchCard> _displayList = [];
  String _selectedTag = filters.keys.first; // Default to the first filter
   final Map<String, Map<String, List<SearchCard>>> _cache = {}; // Cache for search results

  String get query => _query;
  List<SearchCard> get displayList => _displayList;
  String get selectedTag => _selectedTag;

  set query(String newQuery) {
    _query = newQuery;
    clearCache();
    notifyListeners();
  }

  set displayList(List<SearchCard> newDisplayList) {
    _displayList = newDisplayList;
    notifyListeners();
  }

  set selectedTag(String newTag) {
    _selectedTag = newTag;
    notifyListeners();
  }

  List<SearchCard> parseSearchQuery(dynamic result,{String? albumArtist,String? altTag}){ //i should have called this the musicResponsive renderer
    List<SearchCard> ret = [];
    if (result != null) {

      for (var item in result) {
        // Get the navigation endpoint
        String type;
        String id;

        if (item['musicResponsiveListItemRenderer'].containsKey('navigationEndpoint')){
          id = item['musicResponsiveListItemRenderer']['navigationEndpoint']['browseEndpoint']['browseId'];
        } else{
          try {
            id = item['musicResponsiveListItemRenderer']['flexColumns'][0]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
            ['navigationEndpoint']['watchEndpoint']['videoId'];
          } catch (NoSuchMethodError){
            continue;
          }
          
        }

        if (altTag != null){
          type = altTag;
        } else {
          type = selectedTag;
        }

        // Extract title, artist, and thumbnail
        String title = item['musicResponsiveListItemRenderer']['flexColumns'][0]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];
        

        String artists = item['musicResponsiveListItemRenderer']['flexColumns'][1]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];
        if (type == "Albums"){
          try {
          artists = item['musicResponsiveListItemRenderer']['flexColumns'][1]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][2]['text'];}
          catch (NullErrorException){
            continue; 
          }
        }

        

        String thumbnail = item['musicResponsiveListItemRenderer']['thumbnail']
            ['musicThumbnailRenderer']['thumbnail']['thumbnails'][0]['url'];

        thumbnail = thumbnail.contains("=w60-h60")
        ? thumbnail.replaceAll("=w60-h60", "=w300-h300")
        : thumbnail; //check to bump img quality to high res so we dont have a problem later

        
        ret.add(SearchCard(
          desc: artists,
          thumbnail: thumbnail,
          type: type,  
          name: title,
          id: id,
        ));
        
      }
    
    // Return
    return ret;
    } else {
      return [];
    }
  }

  List<SearchCard> parseMusicCarouselContents(dynamic result,int index,String artist){
    List<SearchCard> ret = [];
    if (result != null) {

      for (var item in result) {
        // Get the navigation endpoint
        String type;
        String id;
        String desc;

        if (item['musicTwoRowItemRenderer']['navigationEndpoint'].containsKey('browseEndpoint')){
          id = item['musicTwoRowItemRenderer']['navigationEndpoint']['browseEndpoint']['browseId'];

        } else{
          id = item['musicTwoRowItemRenderer']['navigationEndpoint']['watchEndpoint']['videoId'];
          desc = item['musicTwoRowItemRenderer']['subtitle']['runs'][0]['text'];

          
        }

        // Extract title, artist, and thumbnail
        String title = item["musicTwoRowItemRenderer"]["title"]["runs"][0]["text"];
        


        switch (index){
          case 1:
          case 2:
            type = "Albums";
            break;
          case 3:
            type = "Videos";
            break;
          case 4:
            type = "Featured Playlists";
            break;
          case 5:
            type = "Artists";
            break;
          default:
            continue;
        }

        String thumbnail = item["musicTwoRowItemRenderer"]["thumbnailRenderer"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][0]["url"];



        // Add the search result to the list
        
        ret.add(SearchCard(
          desc: artist,
          thumbnail: thumbnail,
          type: type,  // This could be dynamic if needed (e.g., "artist", "playlist")
          name: title,
          id: id,
        ));
        
      }
    
    // Return
    return ret;
    } else {
      return [];
    }
  }

  List<SearchCard> parsePlaylistPanelContents(dynamic result,{String? albumArtist,String? altTag}){ //i should have called this the musicResponsive renderer
    List<SearchCard> ret = [];
    if (result != null) {

      for (var item in result) {
        // Get the navigation endpoint
        String type;
        String id;

        

        type = "Videos";

        id = item["playlistPanelVideoRenderer"]["videoId"];
        // Extract title, artist, and thumbnail
        String title = item['playlistPanelVideoRenderer']['title']['runs'][0]['text'];
        

        String artists = item["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["text"];

        

        String thumbnail = item["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"];

        thumbnail = thumbnail.contains("=w60-h60")
        ? thumbnail.replaceAll("=w60-h60", "=w300-h300")
        : thumbnail; 
        // Add the search result to the list
        
        ret.add(SearchCard(
          desc: artists,
          thumbnail: thumbnail,
          type: type,  // This could be dynamic if needed (e.g., "artist", "playlist")
          name: title,
          id: id,
        ));
        
      }
    
    // Return
    return ret;
    } else {
      return [];
    }
  }




  // Inner tube search method that updates displayList
  Future<void> search() async {
    // Check if the current query and selected tag have cached results
    if (_cache.containsKey(_query) && 
        _cache[_query]!.containsKey(_selectedTag)) {
      displayList = _cache[_query]![_selectedTag]!; // Use cached results
      return; // Exit if using cache
    }

    // If not cached, perform the search
    var result = await innertube.search(_query, filters[_selectedTag]!);
    var ret = parseSearchQuery(result);

    // Initialize the cache for the current query if it doesn't exist
    if (!_cache.containsKey(_query)) {
      _cache[_query] = {};
    }

    // Cache the results for the current query and selected tag
    _cache[_query]![_selectedTag] = ret; 

    displayList = ret;
    notifyListeners();
  }

  Future<void> searchContinue() async {
  // Fetch continuation results from the API
  var result = await innertube.SearchCont();
  var newResults = parseSearchQuery(result);

  if (newResults.isNotEmpty) {
    displayList.addAll(newResults);
  }

  if (!_cache.containsKey(_query)) {
    _cache[_query] = {};
  }
  
  _cache[_query]![_selectedTag] = displayList;

  notifyListeners(); 
}


  //videos and songs only
  Future<void> goToVideo(BuildContext context, SearchCard selected,[List<SearchCard>? playlist,int? index,bool? fromSong]) async {

    selected.thumbnail = selected.thumbnail.contains("=w60-h60")
        ? selected.thumbnail.replaceAll("=w60-h60", "=w300-h300")
        : selected.thumbnail; 

    if (playlist != null){
      musicProvider.goToSongPage(context, playlist, index ?? 0);

    } else{
      musicProvider.goToSongPage(context, [selected], 0);
      List<SearchCard> result = await getRecommended(selected.id);
      musicProvider.addToQueue(result);
      

    }
    // Use MusicProvider to go to the song page
    

}

 //album only
  Future<void> goToAlbum(BuildContext context, SearchCard selected) async {
    var result = await innertube.browse(selected.id);
    var filtered = result['twoColumnBrowseResultsRenderer']['secondaryContents']['sectionListRenderer']['contents'][0]['musicShelfRenderer']['contents'];

    var thumbnail = selected.thumbnail.contains("=w60-h60")
      ? selected.thumbnail.replaceAll("=w60-h60", "=w450-h450")
      : selected.thumbnail;

    List<SearchCard> filterered = []; //todo refactor to use parsesearchquery with the album artist. also refactor parsesearchquery to acctuallly use that stuff.
    for (var item in filtered){
      String title = item['musicResponsiveListItemRenderer']['flexColumns'][0]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];
      String id = item['musicResponsiveListItemRenderer']['flexColumns'][0]
            ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
            ['navigationEndpoint']['watchEndpoint']['videoId'];
      

      filterered.add(SearchCard(name: title, desc: selected.desc, thumbnail: thumbnail, type: "Videos", id: id));


    }
    SearchPlaylist ret = SearchPlaylist(searchPlaylistName: selected.name, searchPlaylistDesc: selected.desc, searchPlaylistQueue: filterered, searchPlaylistImage: thumbnail);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FetchedPlaylistDetails(playlist: ret),
        ),
      );
  }

  //artist only
  Future<void> goToArtist(BuildContext context, SearchCard selected) async {
    var thumbnail = selected.thumbnail.contains("=w60-h60")
      ? selected.thumbnail.replaceAll("=w60-h60", "=w360-h360")
      : selected.thumbnail;
    var selected2 = SearchCard(name: selected.name, desc: selected.desc, thumbnail: thumbnail, type: selected.type, id: selected.id);
  try {
    // Fetch the browsing results for the selected artist
    var result = await innertube.browse(selected.id);

    // Extract the contents from the result
    var contents = result['singleColumnBrowseResultsRenderer']['tabs'][0]
        ['tabRenderer']['content']['sectionListRenderer']['contents'];

    // Extract the first music shelf header safely
    var musicShelfHeader = contents[0]["musicShelfRenderer"]["title"]["runs"][0];
    
    String musicShelfId = musicShelfHeader["navigationEndpoint"]["browseEndpoint"]["browseId"];

    // Create the initial headers list
    var headers = [
      SearchCard(
        name: musicShelfHeader["text"],
        desc: selected.name,
        thumbnail: selected.thumbnail,
        type: "Featured Playlists",
        id: musicShelfId, // Set to empty string if null
      ),
    ];
    
    // Extract the list of songs and parse them
    var songs = contents[0]["musicShelfRenderer"]["contents"];
    var artistContents = [parseSearchQuery(songs,altTag: "Videos")];

    // yes i know theres a range error here ill fix this later
    for (var x = 1; x <= 5; x++) {
      if (contents[x] == "musicDescriptionShelfRenderer"){
        break;
      }
      try {
        var musicCarouselHeader = contents[x]["musicCarouselShelfRenderer"]["header"]
            ["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0];

        String carouselId = musicCarouselHeader["navigationEndpoint"]?["browseEndpoint"]?["browseId"] ?? "";

        // Add to the headers list
        headers.add(SearchCard(
          name: musicCarouselHeader["text"],
          desc: selected.name,
          thumbnail: selected.thumbnail,
          type: "Featured Playlists",
          id: carouselId, // Set to empty string if null
        ));

        // Parse the contents of the carousel
        var carouselContents = contents[x]["musicCarouselShelfRenderer"]["contents"];
        artistContents.add(parseMusicCarouselContents(carouselContents, x, selected.name));

      } catch (e) {
        print("Error processing carousel at index $x: $e");
        // Safely add a fallback header if parsing fails
        headers.add(SearchCard(
          name: "Unknown Section",
          desc: selected.name,
          thumbnail: selected.thumbnail,
          type: "Featured Playlists",
          id: "", // Fallback ID if error occurs
        ));
      }
    }

    // Navigate to the ArtistDetailsPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: Provider.of<SearchProvider>(context, listen: false), // Pass existing instance
            child: ArtistDetailsPage(
              headers: headers,
              artistContents: artistContents,
              initialCard: selected2,
            ),
          );
        },
      ),
    );

  } catch (e) {
    print("Failed to load artist details: $e");
    // Handle any errors gracefully here (e.g., show a toast or alert)
  }
}

  
  Future<void> goToPlaylist(BuildContext context, SearchCard selected) async {
    var result = await innertube.browse(selected.id);
    result = result['twoColumnBrowseResultsRenderer']['secondaryContents']
        ['sectionListRenderer']['contents'][0]['musicPlaylistShelfRenderer']['contents'];
    var filtered = parseSearchQuery(result);

    var thumbnail = selected.thumbnail.contains("=w60-h60")
      ? selected.thumbnail.replaceAll("=w60-h60", "=w450-h450")
      : selected.thumbnail;

    SearchPlaylist ret = SearchPlaylist(searchPlaylistName: selected.name, searchPlaylistDesc: selected.desc, searchPlaylistQueue: filtered, searchPlaylistImage: thumbnail);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FetchedPlaylistDetails(playlist: ret),
        ),
      );

  }
  
  //routes
 Future<void> handleClick(BuildContext context, SearchCard selected) async {
  switch (selected.type) {
    case "Songs":
    case "Videos":
      await goToVideo(context, selected);
      break;
    case "Albums":
      await goToAlbum(context, selected);
      break;
    case "Community Playlists":
    case "Featured Playlists":
      await goToPlaylist(context, selected);
      break;
    case "Artists":
      await goToArtist(context, selected);
      break;
    default:
      print('Unknown type: ${selected.type}');
  }
}


  Future<List<SearchCard>> getRecommended(String videoId)async{
    var nextQueue = await innertube.next(videoId);
    var items = parsePlaylistPanelContents(nextQueue);
    return items;
  }

  Future<List<String>> getSuggestions(String query) async {
    var queries = await innertube.suggest(query);
    List<String> result = [];

    for (var item in queries){
      String line = item["searchSuggestionRenderer"]["navigationEndpoint"]["searchEndpoint"]["query"];
      result.add(line);
    }

    
    return result;
  }

   Future<void> suggest(String query) async {
    suggestions = await getSuggestions(query); // Update this with your suggestion fetching logic
    notifyListeners();
  }


void clearCache() {
  _cache.clear();
  notifyListeners(); 
}

 

}

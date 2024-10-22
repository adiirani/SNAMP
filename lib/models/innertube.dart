import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

const Map<String, String> WEB = {
  "client_name": "WEB",
  "client_version": "2.20230728",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36",
  "referer": "https://music.youtube.com/",
  "api_key": "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"
};

const Map<String, String> WEB_REMIX = {
  "client_name": "WEB_REMIX",
  "client_version": "1.20230724.00.00",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36",
  "referer": "https://music.youtube.com/",
  "api_key": "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
};

const Map<String, String> ANDROID_MUSIC = {
  "client_name": "ANDROID_MUSIC",
  "client_version": "5.26.1",
  "user_agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36",
  "api_key": "AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI"
};

const Map<String, String> TVEMBEDDED = {
  "client_name": "TVHTML5_SIMPLY_EMBEDDED_PLAYER",
  "client_version": "2.0",
  "user_agent": "Mozilla/5.0 (PlayStation 4 5.55) AppleWebKit/601.2 (KHTML, like Gecko)",
  "api_key": "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc"
};

const Map<String, String> filters = {
  "FILTER_SONG": "EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D",
  "FILTER_VIDEO": "EgWKAQIQAWoKEAkQChAFEAMQBA%3D%3D",
  "FILTER_ALBUM": "EgWKAQIYAWoKEAkQChAFEAMQBA%3D%3D",
  "FILTER_ARTIST": "EgWKAQIgAWoKEAkQChAFEAMQBA%3D%3D",
  "FILTER_FEATURED_PLAYLIST": "EgeKAQQoADgBagwQDhAKEAMQBRAJEAQ%3D",
  "FILTER_COMMUNITY_PLAYLIST": "EgeKAQQoAEABagoQAxAEEAoQCRAF",
};

class InnertubeProto {
  var continuation = '';
  var visitorData = 'CgswMTFJd3k3TzNDVSje_MC4BjIKCgJBRRIEGgAgQA%3D%3D'; //if this is b64 decodable im in trouble haha

  Future<dynamic> search(String query, String filter) async {
    if (query == "" || filter == ""){
      return null;
    }

    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json', // Make sure to set the content type
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
      "x-goog-fieldmask": "contents.tabbedSearchResultsRenderer.tabs.tabRenderer.content.sectionListRenderer.contents.musicShelfRenderer(title,continuations,contents)"
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
        }, 
      },
      "query": query,
      "params": filters[filter],
    };

    //todo handle no internet
    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/search?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data), // Convert the data map to JSON string
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try {
        continuation = result['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']['contents'][0]['musicShelfRenderer']['continuations'][0]['nextContinuationData']['continuation'];
    } catch (NoSuchMethodError) {
        continuation = '';
      }
      try{
        return result['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']['contents'][0]['musicShelfRenderer']['contents'];
      } //i mean look at this; who in gods name does this 
      catch (e) {
        return null;
      }
    } else {
      print('Failed to fetch results: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;  // Ensure a return value in case of error
    }
  }

    Future<dynamic> SearchCont() async{
    if (continuation == ''){
      return (null);
    }
    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json',
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
      "x-goog-fieldmask": "continuationContents.musicShelfContinuation(contents,continuations)"
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
          'visitorData': visitorData,
        },
      },
      "continuation": continuation
      
    };

    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/search?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try{
        continuation = result['continuationContents']['musicShelfContinuation']['continuations'][0]['nextContinuationData']['continuation'];
      } catch (NullErrorException) {
        continuation = '';
      }
      
      return result['continuationContents']['musicShelfContinuation']['contents'];
    } else {
      print('Failed to fetch results: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }

  }

  // New function to get continuation (next) results
  Future<dynamic> next(String videoId) async {
    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json',
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
        },
      },
      "videoId": videoId
    };

    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/next?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      data = jsonDecode(response.body)["contents"]["singleColumnMusicWatchNextResultsRenderer"]["tabbedRenderer"]["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]["playlistPanelRenderer"]["contents"][1]["automixPreviewVideoRenderer"]["content"]["automixPlaylistVideoRenderer"]["navigationEndpoint"]["watchPlaylistEndpoint"];
      return nextPlaylist(data['playlistId'], data['params']);
    } else {
      print('Failed to fetch continuation results: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  //handles playlists. im not using conditionals to check for if its a playlist or video because then that becomes too messed up.
  Future<dynamic> nextPlaylist(String playlistID, String params) async {
    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json',
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
        },
      },
      "playlistId": playlistID,
      "params": params
    };

    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/next?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      continuation = result["contents"]["singleColumnMusicWatchNextResultsRenderer"]["tabbedRenderer"]["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]["playlistPanelRenderer"]["continuations"][0]["nextRadioContinuationData"]["continuation"];
      return result["contents"]["singleColumnMusicWatchNextResultsRenderer"]["tabbedRenderer"]["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]["playlistPanelRenderer"]["contents"];
    } else {
      print('Failed to fetch continuation results: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  
  // browse func to get playlists, artists, compound crap
  Future<dynamic> browse(String browseId) async {
    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json',
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
        },
      },
      "browseId": browseId,
    };

    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/browse?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['contents'];
    } else {
      print('Failed to browse: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }
  
  //gets vids, checks for age restricted and then tries again with a broken client.
  Future<dynamic> player(String videoId, bool safe) async {
    // Switch between Android Music and TVEmbedded clients
    final client = safe ? TVEMBEDDED : ANDROID_MUSIC;

    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json',
      'User-Agent': client['user_agent']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": client['client_name'],
          "clientVersion": client['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": client['user_agent'],
        },
      },
      "videoId": videoId,
      "racyCheckOk": true,
      "contentCheckOk": true
      
    };

    if (safe) {
      data['context']['thirdParty'] = {
          "embedUrl": "https://www.youtube.com/"
        };
    } else{
      data['context']['client']['androidSdkVersion'] = "34";
    }

    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/player?key=${client['api_key']}'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['playabilityStatus']['status'] == "OK") {
        var formats = responseBody["streamingData"]["formats"];
        var link = formats[0]["url"];
        for (var format in formats){
          if (format["audioQuality"] == "AUDIO_QUALITY_MEDIUM"){
            link = format["url"];
        }
      }
      print("INNERTUBE: $videoId FOUND!\n");
        return link;
      } else if (safe) {
        visitorData = responseBody["responseContext"]["visitorData"];
        if (responseBody['playabilityStatus']['reason'] == "Please sign in") {
          print("INNERTUBE:RETRYING $videoId");
          return await player(videoId, false);
          
        }
        return null; // all options exhausted, return null. we will see a lot of this because i do not feel like writing a script to automatically reverse engineer their client decoder.
      } else {
        visitorData = '';
        print("INNERTUBE: Trying $videoId with safe mode...");
        return await player(videoId, true); // Recursive call with safe mode
      }
    } else {
      print('Failed to fetch player data: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  Future<dynamic> suggest(String query) async {
    if (query == ""){
      return null;
    }

    Map<String, String> headers = {
      "Accept": "*/*",
      "Content-Type": 'application/json', // Make sure to set the content type
      'User-Agent': WEB_REMIX['user_agent']!,
      'Referer': WEB_REMIX['referer']!,
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US",
    };

    Map<String, dynamic> data = {
      "context": {
        "client": {
          "clientName": WEB_REMIX['client_name'],
          "clientVersion": WEB_REMIX['client_version'],
          "hl": "en",
          "gl": "US",
          "userAgent": WEB_REMIX['user_agent'],
          "referer": WEB_REMIX['referer'],
        }, 
      },
      "input": query,
    };

    //todo handle no internet
    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/music/get_search_suggestions?key=${WEB_REMIX['api_key']}'),
      headers: headers,
      body: jsonEncode(data), // Convert the data map to JSON string
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result["contents"][0]["searchSuggestionsSectionRenderer"]["contents"];
    } else {
      print('Failed to fetch results: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;  // Ensure a return value in case of error
    }
  }


  
}


//for debugging purposes only
void main() async {
  var innertube = InnertubeProto();
  var searchResult = await innertube.search("tatu clowns", "FILTER_ALBUM");
  print(searchResult);

  var playerResult = await innertube.player("ujcveo2vJLc", false);
  print(playerResult);

  File file = File('search_results.json');
  await file.writeAsString(jsonEncode(playerResult), mode: FileMode.write);

  print("Search results saved to search_results.json");
}

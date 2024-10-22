import 'package:flutter/material.dart';
import 'package:SNAMP/components/neumorphicboxthin.dart';
import 'package:SNAMP/pages/subpages/fetchedPlaylistDetails.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/cacheprovider.dart';
import 'package:SNAMP/models/musicprovider.dart'; // Import the MusicProvider
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:SNAMP/models/templates/searchPlaylist.dart';

class Lander extends StatefulWidget {
  const Lander({super.key});

  @override
  _LanderState createState() => _LanderState();
}

class _LanderState extends State<Lander> {
  late MusicProvider musicProvider; // Declare MusicProvider
  late CacheProvider cacher; // Declare CacheProvider

  Future<List<SearchCard>>? cachedSongs; // Store cached songs as Future
  Future<List<SearchPlaylist>>? cachedPlaylists; // Store cached playlists as Future

  @override
  void initState() {
    super.initState();
    // Access the MusicProvider and CacheProvider
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    cacher = musicProvider.cacher;

    // Fetch cached songs and playlists asynchronously
    cachedSongs = cacher.listCache(); // Ensure this returns a Future<List<SearchCard>>
    cachedPlaylists = cacher.listPlaylists(); // Ensure this returns a Future<List<SearchPlaylist>>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
      ),
      body: FutureBuilder<List<SearchCard>>(
        future: cachedSongs, // Use the Future stored in the state
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading indicator while waiting
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error handling
          }

          final cachedSongsData = snapshot.data ?? []; // Safe null check for cached songs

          return SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding around the title
                  child: Align(
                    alignment: Alignment.centerLeft, // Align title to the left
                    child: Text(
                      'Songs', // Title text
                      style: TextStyle(
                        fontSize: 24, // Font size for the title
                        fontWeight: FontWeight.bold, // Bold font weight
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400, // Set a height for the PageView
                  child: PageView.builder(
                    itemCount: (cachedSongsData.length / 9).ceil(), // Calculate number of pages, each containing 9 items
                    itemBuilder: (context, pageIndex) {
                      // Get the songs for the current page
                      final startIndex = pageIndex * 9;
                      final endIndex = startIndex + 9;
                      final songsForPage = cachedSongsData.sublist(
                        startIndex,
                        endIndex > cachedSongsData.length ? cachedSongsData.length : endIndex,
                      );

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 items per row
                          childAspectRatio: 1, // Adjust aspect ratio for better UI
                          mainAxisSpacing: 0.0, // Space between rows
                          crossAxisSpacing: 0.0, // Space between columns
                        ),
                        itemCount: songsForPage.length,
                        itemBuilder: (context, index) {
                          final song = songsForPage[index];
                          return GestureDetector(
                            onTap: () {
                              // Call goToSongPage from MusicProvider
                              musicProvider.goToSongPage(context, cachedSongsData, startIndex + index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: NeuThinBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      child: CachedNetworkImage(
                                        imageUrl: song.thumbnail,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100, // Fixed height for images
                                        placeholder: (context, url) => SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: const Center(child: CircularProgressIndicator()), // Loading indicator
                                        ),
                                        errorWidget: (context, url, error) => SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: const Icon(Icons.error), // Error indicator
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), // Padding around the title
                  child: Align(
                    alignment: Alignment.centerLeft, // Align title to the left
                    child: Text(
                      'Playlists', // Title text
                      style: TextStyle(
                        fontSize: 24, // Font size for the title
                        fontWeight: FontWeight.bold, // Bold font weight
                      ),
                    ),
                  ),
                ),

                // PLAYLIST CAROUSEL GOES HERE
                FutureBuilder<List<SearchPlaylist>>(
                  future: cachedPlaylists,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 200,
                        child: const Center(child: CircularProgressIndicator()),
                      ); // Loading indicator while waiting
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}')); // Error handling
                    }

                    final cachedPlaylistsData = snapshot.data ?? []; // Safe null check for cached playlists

                    return SizedBox(
                      height: 300, // Set a height for the playlist carousel
                      child: PageView.builder(
                        itemCount: cachedPlaylistsData.length,
                        itemBuilder: (context, index) {
                          final playlist = cachedPlaylistsData[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FetchedPlaylistDetails(playlist: playlist),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: 150,
                                child: NeuThinBox(
                                  child: 
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                        child: CachedNetworkImage(
                                          imageUrl: playlist.searchPlaylistImage,
                                          fit: BoxFit.cover,
                                          width: 300, // Adjust width as needed
                                          height: 300, // Adjust height as needed
                                          placeholder: (context, url) => SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: const Center(child: CircularProgressIndicator()), // Loading indicator
                                          ),
                                          errorWidget: (context, url, error) => SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: const Icon(Icons.error), // Error indicator
                                          ),
                                        ),
                                      ),
                                     
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:SNAMP/components/neumorphicbox.dart';
import 'package:SNAMP/models/musicprovider.dart';
import 'package:SNAMP/models/playlistprovider.dart';
import 'package:SNAMP/models/searchprovider.dart';
import 'package:provider/provider.dart';

class Song extends StatelessWidget {
  const Song({super.key});

  String formatTime(Duration? duration) {
    if (duration == null) return "0:00";
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "${duration.inMinutes}:$seconds";
  }

  void _showPlaylistsBottomSheet(BuildContext context, dynamic currentTrack) {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final playlists = playlistProvider.playlists; // Assuming playlists is a List<Playlist>.

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0), // Add padding here
          child: ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index]; // Assuming Playlist has imageUrl and name
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: playlist.searchPlaylistImage, // Update this line
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                title: Text(playlist.searchPlaylistName), // Use the name property
                onTap: () {
                  playlistProvider.addCardToPlaylist(playlist.searchPlaylistName, currentTrack);
                  Navigator.pop(context); // Close the bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to ${playlist.searchPlaylistName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    return Consumer<MusicProvider>(
      builder: (context, value, child) {
        final currentIndex = value.currentIndex;
        final currentQueue = value.queue;
        final currentTrack = (currentIndex != null && currentIndex < currentQueue.length)
            ? currentQueue[currentIndex]
            : null;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          endDrawer: Drawer(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  "CURRENT QUEUE",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQueue.length,
                    itemBuilder: (context, index) {
                      final track = currentQueue[index];
                      final isCurrentTrack = currentIndex == index;

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                                  imageUrl: track.thumbnail,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                        ),
                        title: Text(
                          track.name,
                          style: TextStyle(
                            color: isCurrentTrack
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.inverseSurface,
                            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          track.desc,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                        ),
                        onTap: () {
                          value.currentIndex = index;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Text(
                          "CURRENT TRACK",
                          style: TextStyle(fontSize: 18),
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(Icons.menu),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    NeumorphicBox(
                      child: currentTrack != null
                          ? Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: currentTrack.thumbnail,
                                    height: 280,
                                    width: 320,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentTrack.name,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.fade,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currentTrack.desc,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.fade,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _showPlaylistsBottomSheet(context, currentTrack);
                                        },
                                        icon: const Icon(Icons.playlist_add, size: 30),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<PlaylistProvider>(context, listen: false)
                                              .addCardToPlaylist("Favorites", currentTrack);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Added to Favorites'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const Text("No track is playing"),
                    ),
                    const SizedBox(height: 25),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatTime(value.currentDuration)),
                              IconButton(
                                onPressed: value.toggleShuffle,
                                icon: const Icon(Icons.shuffle),
                                color: value.isShuffleActive
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.inverseSurface,
                              ),
                              IconButton(
                                onPressed: value.toggleLoop,
                                icon: const Icon(Icons.repeat),
                                color: value.isLoopActive
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.inverseSurface,
                              ),
                              Text(formatTime(value.totalDuration)),
                            ],
                          ),
                        ),
                        Slider(
                          min: 0,
                          max: value.totalDuration.inSeconds.toDouble() ?? 1.0,
                          value: value.currentDuration.inSeconds.toDouble() ?? 0.0,
                          activeColor: Theme.of(context).colorScheme.inverseSurface,
                          onChanged: (newValue) {
                            value.seek(Duration(seconds: newValue.toInt()));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: value.playPrev,
                            child: const NeumorphicBox(child: Icon(Icons.skip_previous)),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: GestureDetector(
                            onTap: value.toggle,
                            child: NeumorphicBox(
                              child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: GestureDetector(
                            onTap: value.playNext,
                            child: const NeumorphicBox(child: Icon(Icons.skip_next)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${value.currentSpeed.toStringAsFixed(2)}x"),
                          Expanded(
                            child: Slider(
                              min: 0.5,
                              max: 2.0,
                              value: value.currentSpeed,
                              activeColor: Theme.of(context).colorScheme.inverseSurface,
                              onChanged: value.changeSpeed,
                            ),
                          ),
                          const Text("2.0x"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

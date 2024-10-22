import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/models/musicprovider.dart'; // Import your MusicProvider
import 'package:SNAMP/components/neumorphicboxthin.dart'; // Import NeuThinBox
import 'package:cached_network_image/cached_network_image.dart';
import 'package:SNAMP/pages/song.dart'; // Replace with your player page

class MusicBar extends StatelessWidget {
  const MusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final isPlaying = musicProvider.isPlaying;
        final currentTrack = musicProvider.currentIndex != null
            ? musicProvider.queue[musicProvider.currentIndex!]
            : null;

        if (currentTrack == null) {
          return const SizedBox.shrink(); // Return empty widget if no track
        }

        final progress = musicProvider.totalDuration.inMilliseconds > 0
            ? musicProvider.currentDuration.inMilliseconds /
                musicProvider.totalDuration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () {
            // Navigate to the player page when the music bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Song()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: NeuThinBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Track image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: 
                          CachedNetworkImage(
                                          imageUrl: currentTrack.thumbnail,
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                          //placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                        
                    ),
                  ),
                  // Track details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTrack.desc,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Play/pause button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      isPlaying
                          ? context.read<MusicProvider>().pause()
                          : context.read<MusicProvider>().resume();
                    },
                  ),
                  // Next track button
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      context.read<MusicProvider>().playNext();
                    },
                    
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

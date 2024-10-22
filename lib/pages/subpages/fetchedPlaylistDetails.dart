import 'package:flutter/material.dart';
import 'package:SNAMP/models/searchprovider.dart';
import 'package:SNAMP/models/playlistprovider.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/components/neumorphicboxthin.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FetchedPlaylistDetails extends StatelessWidget {
  final SearchPlaylist playlist;

  const FetchedPlaylistDetails({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final isUserGenerated = playlistProvider.playlistIsUserGenerated(playlist);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.colorScheme.onSurface,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            NeuThinBox(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (playlist.searchPlaylistImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: playlist.searchPlaylistImage,
                          fit: BoxFit.cover,
                          height: 150,
                          width: 150,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.searchPlaylistName,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            playlist.searchPlaylistDesc ??
                                'No description available',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: playlist.searchPlaylistQueue.isEmpty
                  ? Center(
                      child: Text(
                        'No songs in this playlist',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: playlist.searchPlaylistQueue.length,
                      itemBuilder: (context, index) {
                        final track = playlist.searchPlaylistQueue[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: track.thumbnail,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            title: Text(
                              track.name,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              track.desc,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isUserGenerated
                                ? IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _showDeleteTrackConfirmationDialog(
                                          context, track, index);
                                    },
                                  )
                                : null,
                            onTap: () {
                              Provider.of<SearchProvider>(context,
                                      listen: false)
                                  .goToVideo(context, track,
                                      playlist.searchPlaylistQueue, index);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTrackConfirmationDialog(
      BuildContext context, SearchCard track, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Track'),
          content: Text(
              'Are you sure you want to delete "${track.name}" from this playlist?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Remove the track from the playlist
                Provider.of<PlaylistProvider>(context, listen: false)
                    .removeCardFromPlaylist(
                        playlist.searchPlaylistName, track.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

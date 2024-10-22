import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:SNAMP/models/playlistprovider.dart';
import 'package:SNAMP/pages/subpages/fetchedPlaylistDetails.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/pages/subpages/createPlaylistDetails.dart';

class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PLAYLISTS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreatePlaylistDetails(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          final playlists = playlistProvider.playlists;

          if (playlists.isEmpty) {
            return const Center(
              child: Text('No playlists available'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return ListTile(
                  title: Text(playlist.searchPlaylistName),
                  subtitle: Text(playlist.searchPlaylistDesc),
                  leading: (playlist.searchPlaylistImage != "")
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                            imageUrl: playlist.searchPlaylistImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                      )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(
                      context,
                      playlist.searchPlaylistName,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FetchedPlaylistDetails(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String playlistName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Playlist"),
          content: Text(
              "Are you sure you want to delete the playlist '$playlistName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                try {
                  Provider.of<PlaylistProvider>(context, listen: false)
                      .removePlaylist(playlistName);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

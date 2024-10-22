import 'package:flutter/material.dart';
import 'package:SNAMP/models/musicprovider.dart';
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:provider/provider.dart';

class PlaylistDetails extends StatelessWidget {
  final SearchPlaylist playlist;

  const PlaylistDetails({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.searchPlaylistName),
      ),
      body: playlist.searchPlaylistQueue.isEmpty
          ? const Center(child: Text('No items in this playlist'))
          : ListView.builder(
              itemCount: playlist.searchPlaylistQueue.length,
              itemBuilder: (context, index) {
                final SearchCard card = playlist.searchPlaylistQueue[index];
                return ListTile(
                  title: Text(card.name),  
                  subtitle: Text(card.desc),  
                  leading: card.thumbnail.startsWith('http')
                      ? Image.network(card.thumbnail, width: 50, height: 50, fit: BoxFit.cover)
                      : Image.asset(card.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                  onTap: () {
                    // Navigate to the song page with the playlist queue
                    Provider.of<MusicProvider>(context, listen: false)
                        .goToSongPage(context, playlist.searchPlaylistQueue, index);
                  },
                );
              },
            ),
    );
  }
}

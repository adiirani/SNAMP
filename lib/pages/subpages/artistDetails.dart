import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:SNAMP/models/templates/searchPlaylist.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/searchprovider.dart'; // Import SearchProvider
import 'package:SNAMP/components/neumorphicboxthin.dart'; // Import NeuBoxThin

class ArtistDetailsPage extends StatelessWidget {
  final List<SearchCard> headers; // Not shown with the main content
  final List<List<SearchCard>> artistContents;
  final SearchCard initialCard;

  const ArtistDetailsPage({
    super.key,
    required this.headers,
    required this.artistContents,
    required this.initialCard,
  });

  @override
  Widget build(BuildContext context) {
    print(initialCard.id);
    print("Headers: ${headers.map((header) => header.id).toList()}");

    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.surface, // Match your theme
            elevation: 0, // Flat app bar
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeuThinBox(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              initialCard.thumbnail,
                              fit: BoxFit.cover,
                              height: 150,
                              width: 150,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  initialCard.name,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Artist",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
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
                  const SizedBox(height: 24),
                  // SONGS Section and Other Content...
                  if (artistContents.isNotEmpty && artistContents[0].isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          headers.isNotEmpty ? headers[0].name : 'Songs',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            // Call the goToPlaylist function with the header ID
                            if (headers.isNotEmpty) {
                              searchProvider.goToPlaylist(context,headers[0]);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: artistContents[0].map((song) {
                        return ListTile(
                          title: Text(song.name),
                          subtitle: Text(song.desc),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(song.thumbnail),
                          ),
                          onTap: () {
                            searchProvider.handleClick(context, song);
                            print(song.type);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  for (var i = 1; i < artistContents.length; i++) ...[
                    Text(
                      headers.length > i ? headers[i].name : "Section $i",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: artistContents[i].map((content) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                searchProvider.handleClick(context, content);
                              },
                              child: SizedBox(
                                width: 120,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(content.thumbnail),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      content.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

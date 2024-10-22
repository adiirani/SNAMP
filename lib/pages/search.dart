import 'package:flutter/material.dart';
import 'package:SNAMP/models/musicprovider.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/components/neumorphicboxthin.dart';
import 'package:SNAMP/models/searchprovider.dart';
import 'package:SNAMP/models/templates/searchCard.dart';
import 'package:SNAMP/models/playlistprovider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore) {
        _loadMoreResults();
      }
    });
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await Provider.of<SearchProvider>(context, listen: false).searchContinue();
    } catch (e) {
      // Handle error without showing a Snackbar
      print('Error loading more results: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    try {
      if (query.isNotEmpty) {
        searchProvider.query = query;
        await searchProvider.search();
        setState(() {
          _hasSearched = true;
        });
      } else {
        searchProvider.displayList = [];
      }
    } catch (e) {
      // Handle error without showing a Snackbar
      print('Search error: $e');
    }
  }

  Future<void> _getSuggestions(String query) async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        searchProvider.suggestions = [];
      });
      return;
    }

    try {
      await searchProvider.suggest(query);
      setState(() {});
    } catch (e) {
      // Handle error without showing a Snackbar
      print('Suggestion error: $e');
    }
  }

  void _handleSearchResultTap(BuildContext context, SearchCard searchResult) async {
    try {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      await searchProvider.handleClick(context, searchResult);
    } catch (e) {
      // Handle error without showing a Snackbar
      print('Error opening song: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
              child: NeuThinBox(
                child: TextField(
                  onChanged: (value) {
                    _getSuggestions(value);
                    setState(() {
                      _hasSearched = false;
                    });
                  },
                  onSubmitted: _performSearch,
                  decoration: InputDecoration(
                    hintText: searchProvider.query.isEmpty
                        ? "Search for music..."
                        : searchProvider.query,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Suggestions List
            if (!_hasSearched && searchProvider.suggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchProvider.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = searchProvider.suggestions[index];
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        _performSearch(suggestion);
                      },
                    );
                  },
                ),
              ),

            // Search Results or No Results Message
            if (_hasSearched)
              Expanded(
                child: Column(
                  children: [
                    // Scrollable Filter Tabs
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.keys.map((tabName) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                searchProvider.selectedTag = tabName;
                                _performSearch(searchProvider.query);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: NeuThinBox(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: searchProvider.selectedTag == tabName
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tabName,
                                    style: TextStyle(
                                      color: searchProvider.selectedTag == tabName
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Search Results
                    Expanded(
                      child: searchProvider.displayList.isNotEmpty
                          ? ListView.builder(
                              controller: _scrollController,
                              itemCount: searchProvider.displayList.length,
                              itemBuilder: (context, index) {
                                final searchResult =
                                    searchProvider.displayList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        searchResult.thumbnail,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      searchResult.name,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                    ),
                                    subtitle: Text(
                                      searchResult.desc,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                    ),
                                    onTap: () => _handleSearchResultTap(
                                        context, searchResult),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'No results found :(',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:SNAMP/components/neumorphicboxthin.dart'; // Import the NeuThinBox
import 'package:SNAMP/models/musicprovider.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:SNAMP/theme/themeprov.dart';
import 'package:flutter/cupertino.dart';
import 'package:SNAMP/components/neumorphicbox.dart'; // Import NeumorphicBox
import 'package:SNAMP/models/cacheprovider.dart'; // Import CacheProvider

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late MusicProvider musicProvider; // Declare MusicProvider
  late CacheProvider cacher; // Declare CacheProvider

  @override
  void initState() {
    super.initState();
    // Access the MusicProvider and CacheProvider
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    cacher = musicProvider.cacher;
    // No need to fetch cached songs here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10), // Replacing Material with NeumorphicBox
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration( // Use your theme's primary color
            borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
          ),
          child: Column( // Use Column to stack settings items
            children: [
              // NeuThinBox around Dark Mode row
              NeuThinBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Add padding around the row
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust alignment
                    children: [
                      const Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 18), // Increase text size
                      ),
                      CupertinoSwitch(
                        value: Provider.of<Themeprov>(context, listen: true).isDark, // Listen for changes in theme
                        onChanged: (value) => Provider.of<Themeprov>(context, listen: false).toggleTheme(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Space between the rows

              // NeuThinBox around Clear Cache and Nuke Data rows
              NeuThinBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Add padding around the column
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showClearCacheDialog(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust alignment
                          children: [
                            Expanded(
                              child: Text(
                                "Clear Cache",
                                style: TextStyle(fontSize: 18, color: Colors.red), // Increase text size
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30), // Space between the rows
                      GestureDetector(
                        onTap: () {
                          _showNukeDataDialog(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust alignment
                          children: [
                            Expanded(
                              child: Text(
                                "Nuke Data",
                                style: TextStyle(fontSize: 18, color: Colors.red), // Increase text size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show the confirmation dialog for clearing cache
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear Cache"),
          content: const Text("Are you sure you want to clear the cache?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Clear"),
              onPressed: () {
                // Call the cache provider's clear method
                Provider.of<MusicProvider>(context, listen: false).cacher.clearCache();
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cache cleared!")), // Show a snackbar confirmation
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show the confirmation dialog for nuking data
  void _showNukeDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nuke Data"),
          content: const Text("Are you sure you want to nuke all data? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Nuke"),
              onPressed: () {
                // Call the cache provider's nuke method
                Provider.of<MusicProvider>(context, listen: false).cacher.nuke();
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data nuked!")), // Show a snackbar confirmation
                );
              },
            ),
          ],
        );
      },
    );
  }
}

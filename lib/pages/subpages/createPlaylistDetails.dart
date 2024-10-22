import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SNAMP/models/playlistprovider.dart';
import 'package:SNAMP/components/neumorphicboxthin.dart'; // Adjust the import path if needed

class CreatePlaylistDetails extends StatefulWidget {
  const CreatePlaylistDetails({super.key});

  @override
  State<CreatePlaylistDetails> createState() => _CreatePlaylistDetailsState();
}

class _CreatePlaylistDetailsState extends State<CreatePlaylistDetails> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _addPlaylist(BuildContext context) {
    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isNotEmpty && desc.isNotEmpty) {
      try {
        Provider.of<PlaylistProvider>(context, listen: false)
            .addPlaylist(name, desc, ""); // Empty image for now
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Playlist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Playlist Name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Playlist Description",
                ),
              ),
              const SizedBox(height: 24),
              NeuThinBox(
                child: InkWell(
                  onTap: () => _addPlaylist(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "Add Playlist",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

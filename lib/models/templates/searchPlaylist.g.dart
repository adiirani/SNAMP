// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchPlaylist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchPlaylistAdapter extends TypeAdapter<SearchPlaylist> {
  @override
  final int typeId = 2;

  @override
  SearchPlaylist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchPlaylist(
      searchPlaylistName: fields[1] as String,
      searchPlaylistDesc: fields[2] as String,
      searchPlaylistQueue: (fields[3] as List).cast<SearchCard>(),
      searchPlaylistImage: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SearchPlaylist obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.searchPlaylistName)
      ..writeByte(2)
      ..write(obj.searchPlaylistDesc)
      ..writeByte(3)
      ..write(obj.searchPlaylistQueue)
      ..writeByte(4)
      ..write(obj.searchPlaylistImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchPlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

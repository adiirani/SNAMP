// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchCard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchCardAdapter extends TypeAdapter<SearchCard> {
  @override
  final int typeId = 1;

  @override
  SearchCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchCard(
      name: fields[1] as String,
      desc: fields[2] as String,
      thumbnail: fields[3] as String,
      type: fields[4] as String,
      id: fields[5] as String,
      url: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SearchCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.desc)
      ..writeByte(3)
      ..write(obj.thumbnail)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

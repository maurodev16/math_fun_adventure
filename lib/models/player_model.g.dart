// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      avatarId: fields[1] as String,
      coins: fields[2] as int,
      worlds: (fields[3] as List).cast<World>(),
      unlockedItems: (fields[4] as List).cast<String>(),
      totalScore: fields[5] as int,
      currentLevel: fields[6] as int,
      currentWorld: fields[7] as int,
      achievements: (fields[8] as List).cast<Achievement>(),
      playTimeSecs: fields[9] as int,
      lastPlayDate: fields[10] as DateTime,
      consecutiveDays: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.avatarId)
      ..writeByte(2)
      ..write(obj.coins)
      ..writeByte(3)
      ..write(obj.worlds)
      ..writeByte(4)
      ..write(obj.unlockedItems)
      ..writeByte(5)
      ..write(obj.totalScore)
      ..writeByte(6)
      ..write(obj.currentLevel)
      ..writeByte(7)
      ..write(obj.currentWorld)
      ..writeByte(8)
      ..write(obj.achievements)
      ..writeByte(9)
      ..write(obj.playTimeSecs)
      ..writeByte(10)
      ..write(obj.lastPlayDate)
      ..writeByte(11)
      ..write(obj.consecutiveDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorldAdapter extends TypeAdapter<World> {
  @override
  final int typeId = 1;

  @override
  World read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return World(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      iconId: fields[3] as String,
      levels: (fields[4] as List).cast<Level>(),
      unlocked: fields[5] as bool,
      completed: fields[6] as bool,
      themeColor: fields[7] as String,
      operation: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, World obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconId)
      ..writeByte(4)
      ..write(obj.levels)
      ..writeByte(5)
      ..write(obj.unlocked)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.themeColor)
      ..writeByte(8)
      ..write(obj.operation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 2;

  @override
  Level read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Level(
      id: fields[0] as int,
      name: fields[1] as String,
      difficulty: fields[2] as int,
      unlocked: fields[3] as bool,
      completed: fields[4] as bool,
      stars: fields[5] as int,
      highScore: fields[6] as int,
      bestTime: fields[7] as int,
      challengeType: fields[8] as String,
      lastPlayedDate: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.unlocked)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.stars)
      ..writeByte(6)
      ..write(obj.highScore)
      ..writeByte(7)
      ..write(obj.bestTime)
      ..writeByte(8)
      ..write(obj.challengeType)
      ..writeByte(9)
      ..write(obj.lastPlayedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 3;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconId: fields[3] as String,
      dateUnlocked: fields[4] as DateTime,
      rewardCoins: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconId)
      ..writeByte(4)
      ..write(obj.dateUnlocked)
      ..writeByte(5)
      ..write(obj.rewardCoins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive_flutter/hive_flutter.dart';

part 'game_challenge_models.g.dart';

// Execute o comando abaixo para gerar código do Hive:
// flutter packages pub run build_runner build

@HiveType(typeId: 64)
enum ProblemType {
  @HiveField(0)
  sequence,

  @HiveField(1)
  operation,
}

@HiveType(typeId: 65)
class Problem {
  @HiveField(0)
  final ProblemType type;

  @HiveField(1)
  final String instruction;

  @HiveField(2)
  final List<String> draggableItems;

  @HiveField(3)
  final List<String> targetValues;

  Problem({
    required this.type,
    required this.instruction,
    required this.draggableItems,
    required this.targetValues,
  });
}

@HiveType(typeId: 66)
class DraggableItem {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final bool isPlaced;

  DraggableItem({
    required this.id,
    required this.value,
    required this.isPlaced,
  });

  DraggableItem copyWith({int? id, String? value, bool? isPlaced}) {
    return DraggableItem(
      id: id ?? this.id,
      value: value ?? this.value,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}

@HiveType(typeId: 67)
class TargetSlot {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String correctValue;

  @HiveField(2)
  final bool isTargetSlot;

  @HiveField(3)
  final DraggableItem? currentItem;

  TargetSlot({
    required this.id,
    required this.correctValue,
    required this.isTargetSlot,
    this.currentItem,
  });

  TargetSlot copyWith({
    int? id,
    String? correctValue,
    bool? isTargetSlot,
    DraggableItem? currentItem,
  }) {
    return TargetSlot(
      id: id ?? this.id,
      correctValue: correctValue ?? this.correctValue,
      isTargetSlot: isTargetSlot ?? this.isTargetSlot,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

// These adapters could either be defined here, or in a separate adapters file,
// or directly in the PlayerDataService.dart file

// ProblemType Adapter
class ProblemTypeAdapter extends TypeAdapter<ProblemType> {
  @override
  final int typeId = 64;

  @override
  ProblemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProblemType.sequence;
      case 1:
        return ProblemType.operation;
      default:
        return ProblemType.sequence;
    }
  }

  @override
  void write(BinaryWriter writer, ProblemType obj) {
    switch (obj) {
      case ProblemType.sequence:
        writer.writeByte(0);
        break;
      case ProblemType.operation:
        writer.writeByte(1);
        break;
    }
  }
}

// Problem Adapter
class ProblemAdapter extends TypeAdapter<Problem> {
  @override
  final int typeId = 65;

  @override
  Problem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return Problem(
      type: fields[0] as ProblemType,
      instruction: fields[1] as String,
      draggableItems: (fields[2] as List).cast<String>(),
      targetValues: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Problem obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.type);
    writer.writeByte(1);
    writer.write(obj.instruction);
    writer.writeByte(2);
    writer.write(obj.draggableItems);
    writer.writeByte(3);
    writer.write(obj.targetValues);
  }
}

// DraggableItem Adapter
class DraggableItemAdapter extends TypeAdapter<DraggableItem> {
  @override
  final int typeId = 66;

  @override
  DraggableItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return DraggableItem(
      id: fields[0] as int,
      value: fields[1] as String,
      isPlaced: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DraggableItem obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.value);
    writer.writeByte(2);
    writer.write(obj.isPlaced);
  }
}

// TargetSlot Adapter
class TargetSlotAdapter extends TypeAdapter<TargetSlot> {
  @override
  final int typeId = 67;

  @override
  TargetSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return TargetSlot(
      id: fields[0] as int,
      correctValue: fields[1] as String,
      isTargetSlot: fields[2] as bool,
      currentItem: fields[3] as DraggableItem?,
    );
  }

  @override
  void write(BinaryWriter writer, TargetSlot obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.correctValue);
    writer.writeByte(2);
    writer.write(obj.isTargetSlot);
    writer.writeByte(3);
    writer.write(obj.currentItem);
  }
}

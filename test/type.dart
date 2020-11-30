import 'package:hive/hive.dart';

class TestType {
  final String id;
  final String value;

  TestType(this.id, this.value);
}

class TestTypeAdapter implements TypeAdapter<TestType> {
  @override
  final typeId = 0;

  @override
  TestType read(BinaryReader reader) {
    return TestType(reader.read(), reader.read());
  }

  @override
  void write(BinaryWriter writer, TestType obj) {
    writer..write(obj.id)..write(obj.value);
  }
}

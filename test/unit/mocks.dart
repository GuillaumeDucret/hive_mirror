import 'package:hive/hive.dart';
import 'package:hive_mirror/src/hive_mirror.dart';
import 'package:hive_mirror/src/metadata.dart';
import 'package:mockito/mockito.dart';

class LazyBoxMock extends Mock implements LazyBox {}

class MetadataMock extends Mock implements Metadata {}

class MirrorHandlerMock extends Mock implements MirrorHandler {}

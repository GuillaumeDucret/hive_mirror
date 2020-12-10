import 'src/hive_mirror.dart';
import 'src/hive_mirror_impl.dart';

export 'src/backend/git/git_patch.dart';
export 'src/handlers/box_mirror_handler.dart';
export 'src/hive_mirror.dart';

final HiveMirrorInterface HiveMirror = HiveMirrorImpl();

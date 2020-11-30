import 'src/hive_mirror.dart';
import 'src/hive_mirror_impl.dart';

export 'src/backend/git/git_patch.dart';
export 'src/handlers.dart';

final HiveMirrorInterface HiveMirror = HiveMirrorImpl();

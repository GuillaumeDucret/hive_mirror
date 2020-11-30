import '../hive_mirror.dart';
import '../metadata.dart';
import 'git/git_mirror_manager.dart';
import 'git/git_patch.dart';

abstract class MirrorManager {
  Future<void> mirror(dynamic source);

  factory MirrorManager.fromSource(dynamic source,
      {MirrorHandler handler, Metadata metadata}) {
    if (source is GitPatchInterface) {
      return GitMirrorManager(handler, metadata);
    }
    throw UnsupportedError('''source $source is not supported.
         Use one of the supported sources [GitPatch]''');
  }
}

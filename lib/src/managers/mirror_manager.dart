// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import '../datasource/file.dart';
import '../datasource/git_patch.dart';
import '../hive_mirror.dart';
import '../metadata.dart';
import 'file.dart';
import 'git_patch.dart';

abstract class MirrorManager {
  Future<void> mirror(dynamic source);

  factory MirrorManager.fromSource(
    dynamic source, {
    MirrorHandler handler,
    Metadata metadata,
  }) {
    if (source is GitPatchInterface) {
      return GitMirrorManager(handler, metadata);
    }
    if (source is FileDescriptorInterface) {
      return FileMirrorManager(handler, metadata);
    }
    throw ArgumentError('''source $source is not supported.
         Use one of the supported sources
         [GitPatchInterface, FileDescriptorInterface]''');
  }
}

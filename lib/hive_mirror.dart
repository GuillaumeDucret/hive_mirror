// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'src/hive_mirror.dart';
import 'src/hive_mirror_impl.dart';

export 'src/datasource/git_patch.dart';
export 'src/datasource/file.dart';
export 'src/extension.dart';
export 'src/handlers/box.dart';
export 'src/hive_mirror.dart';

final HiveMirrorInterface HiveMirror = HiveMirrorImpl();

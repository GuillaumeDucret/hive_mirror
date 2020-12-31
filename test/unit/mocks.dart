// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive_mirror/src/hive_mirror.dart';
import 'package:hive_mirror/src/metadata.dart';
import 'package:mockito/mockito.dart';

class MetadataMock extends Mock implements Metadata {}

class MirrorHandlerMock<T> extends Mock implements MirrorHandler<T> {}

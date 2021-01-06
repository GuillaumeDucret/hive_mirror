// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hive_mirror/src/convert/git_patch_parser.dart';
import 'package:test/test.dart';

import '../../patches.dart';

void main() {
  group('GitPatchParser', () {
    test('bind()', () async {
      void onCommit(Commit commit) {
        final diff = commit.diffs[0];

        expect(commit.revision, equals(Add2Remove1Patch.revision));
        expect(commit.diffs, hasLength(1));
        expect(diff.path, equals(Add2Remove1Patch.path));
        expect(diff.addLines, equals(Add2Remove1Patch.addLines));
        expect(diff.removeLines, equals(Add2Remove1Patch.removeLines));
      }

      await File(Add2Remove1Patch.filePath)
          .openRead()
          .transform(Utf8Decoder())
          .transform(LineSplitter())
          .transform(GitPatchParser())
          .listen(expectAsync1(onCommit, count: 1));
    });
  });
}

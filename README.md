# hive_mirror

One way sync for hive databases.

This package is in development. API might change.

## Usage

```dart
// Hive setup has to be done using the HiveMirror api.
HiveMirror.init('myHivePath');
HiveMirror.registerAdapter(PersonAdapter());

final source = FileDescriptor.file(
  File('myFilePath'),
  decode: (line) {
    final tupple = line.split(':');
    return Person()
      ..name = tupple[0]
      ..age = tupple[1];
  },
  decodeKey: (line) {
    final tupple = line.split(':');
    return tupple[0];
  },
);

// Box is synced with the data source
final box = await Hive.openMirrorBox<Person>('myBox', mirrorSource: source);
```

## Supported backends

HiveMirror currently supports files and git patches data sources.

### Text file

Both local and remote files are supported as mirror data sources.
Each line of the file must describe a box entry which is decoded and put in the box during the mirror operation.
A file is processed only if it has changed since the last mirror operation.

```dart
final source = FileDescriptor.file(
  File('myFilePath'),
  decode: (line) {
    final tupple = line.split(':');
    return Person()
      ..name = tupple[0]
      ..age = tupple[1];
  },
  decodeKey: (line) {
    final tupple = line.split(':');
    return tupple[0];
  },
);
```

### Git patch

HiveMirror relies on git patches to support incremental sync.
A git patch is formatted using the commit from the last mirror operation.
Each diff line is then decoded and either put or deleted from the box.

Github compare view is used as the patch provider.

```dart
final source = GitPatch.githubCompareView('myGithubUserName', 'myRepoName',
  initialBaseRevision: 'initialRevision',
  compareRevision: 'master',
  filter: (filePath) => filePath == 'myFileToSync',
  decode: (filePath, line) {
    final tupple = line.split(':');
    return Person()
      ..name = tupple[0]
      ..age = tupple[1];
  },
  decodeKey: (filePath, line) {
    final tupple = line.split(':');
    return tupple[0];
  },
);
```

## Limitations

HiveMirror operates inside an isolate. So it will not work in flutter web.

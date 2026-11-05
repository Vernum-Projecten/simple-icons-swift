- **Breaking:** every icon is now a static function: write `SimpleIcon.swift()` and `.github()`
  instead of `SimpleIcon.swift` and `.github`. A public static property makes the library export a
  property descriptor per icon, and an app kept the names of all 3,467 in its symbol table even
  when it used six icons. A release build of a program with six icons is now 0.15 MB instead of
  0.5 MB on macOS (0.35 MB instead of 0.6 MB on Linux), measured unstripped with its symbol table.
  To update, add `()` after every icon. `SimpleIcon.allCases` and every icon's properties are
  unchanged.

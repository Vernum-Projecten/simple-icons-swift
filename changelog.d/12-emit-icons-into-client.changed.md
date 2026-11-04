- An app now contains only the icons it uses: a release build with six icons is 0.5 MB
  instead of 8.2 MB. Every icon is compiled into the app where it is used, and the others
  never reach the binary. `SimpleIcon.allCases` still lists every icon; an app that uses it
  contains them all.

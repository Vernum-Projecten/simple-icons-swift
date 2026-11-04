- `SimpleIcon` is no longer `CaseIterable`: the conformance kept every icon in every app.
  `SimpleIcon.allCases` stays and works as before; generic code that needs the protocol can
  add `extension SimpleIcon: @retroactive CaseIterable {}` itself.

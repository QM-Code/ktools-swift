# Gamma SDK Demo

Reusable gamma inline parser used by the Swift omega demo executable.

This demo shows that an SDK parser can still be reused when the executable renames the root locally with `setRoot(...)`.
Its parser and handler behavior stays local to the gamma demo target.

Implementation:

- [`src/KcliDemoGamma.swift`](src/KcliDemoGamma.swift)

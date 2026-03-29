# Beta SDK Demo

Reusable beta inline parser used by the Swift omega demo executable.

Like alpha, this demo is a reference for SDK-style parser composition in Swift.
It exposes a reusable `InlineParser("--beta")` that the executable imports and registers.
Its handler and validation behavior lives in the beta demo target itself.

Implementation:

- [`src/KcliDemoBeta.swift`](src/KcliDemoBeta.swift)

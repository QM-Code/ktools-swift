# Examples

This page shows a few common `kcli` patterns. For complete compiling examples, also see:

- [`../src/Sources/KcliDemoAlpha/KcliDemoAlpha.swift`](../src/Sources/KcliDemoAlpha/KcliDemoAlpha.swift)
- [`../src/Sources/KcliDemoBeta/KcliDemoBeta.swift`](../src/Sources/KcliDemoBeta/KcliDemoBeta.swift)
- [`../src/Sources/KcliDemoGamma/KcliDemoGamma.swift`](../src/Sources/KcliDemoGamma/KcliDemoGamma.swift)
- [`../src/Sources/KcliDemoCore/main.swift`](../src/Sources/KcliDemoCore/main.swift)
- [`../src/Sources/KcliDemoOmega/main.swift`](../src/Sources/KcliDemoOmega/main.swift)

## Minimal Executable

```swift
import Kcli

let parser = Parser()

try parser.addAlias("-v", target: "--verbose")
try parser.setHandler("--verbose",
                      handler: { context in
                      },
                      description: "Enable verbose logging.")

try parser.parseOrThrow(CommandLine.arguments)
```

## Inline Root With Subcommands-Like Options

```swift
let parser = Parser()
var build = try InlineParser("--build")

try build.setHandler("-profile",
                     handler: { context, value in
                     },
                     description: "Set build profile.")
try build.setHandler("-clean",
                     handler: { context in
                     },
                     description: "Enable clean build.")

try parser.addInlineParser(build)
try parser.parseOrThrow(CommandLine.arguments)
```

This enables:

```text
--build
--build-profile release
--build-clean
```

## Bare Root Value Handler

```swift
var config = try InlineParser("--config")

try config.setRootValueHandler({ context, value in
}, valuePlaceholder: "<assignment>", description: "Store a config assignment.")
```

This enables:

```text
--config
--config user=alice
```

Behavior:

- `--config` prints inline help
- `--config user=alice` invokes the root value handler

## Alias Preset Tokens

```swift
let parser = Parser()

try parser.addAlias("-c", target: "--config-load", presetTokens: ["user-file"])
try parser.setHandler("--config-load",
                      handler: { context, value in
                      },
                      description: "Load config.")
```

This makes:

```text
-c settings.json
```

behave like:

```text
--config-load user-file settings.json
```

Inside the handler:

- `context.option` is `--config-load`
- `context.valueTokens` is `["user-file", "settings.json"]`

## Optional Values

```swift
try parser.setOptionalValueHandler("--color",
                                   handler: { context, value in
                                   },
                                   description: "Set or auto-detect color output.")
```

This enables both:

```text
--color
--color always
```

## Positionals

```swift
try parser.setPositionalHandler { context in
    for token in context.valueTokens {
        usePositional(token)
    }
}
```

The positional handler receives all remaining non-option tokens after option parsing succeeds.

## Custom Error Handling

If you want your own formatting or exit policy, use `parseOrThrow()`:

```swift
do {
    try parser.parseOrThrow(CommandLine.arguments)
} catch let error as CliError {
    FileHandle.standardError.write(Data("custom cli error: \(error.message)\n".utf8))
    exit(2)
}
```

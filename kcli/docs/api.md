# API Guide

The public Swift API lives in [`../src/Sources/Kcli/Kcli.swift`](../src/Sources/Kcli/Kcli.swift).

## Main Types

`Parser`

- Registers top-level handlers, aliases, positionals, and inline parsers.
- Provides `parseOrExit()` and `parseOrThrow(_:)`.

`InlineParser`

- Registers one inline root such as `--build` or `--trace`.
- Supports bare-root value handlers through `setRootValueHandler(...)`.
- Supports flag, required-value, and optional-value handlers.

`HandlerContext`

- `root`: active inline root without leading dashes, or empty for top-level handlers
- `option`: effective option token such as `--verbose` or `--build-profile`
- `command`: inline command suffix such as `-profile`
- `valueTokens`: consumed value tokens after alias preset tokens are applied

`CliError`

- Returned by `parseOrThrow(_:)` on invalid CLI input
- Exposes the effective option token through `option()`

`CliConfigurationError`

- Thrown when handlers, aliases, roots, or descriptions are registered incorrectly

## Registration Styles

Top-level flags:

```swift
try parser.setHandler("--verbose",
                      handler: { context in
                      },
                      description: "Enable verbose logging.")
```

Top-level required values:

```swift
try parser.setHandler("--output",
                      handler: { context, value in
                      },
                      description: "Set app output target.")
```

Top-level optional values:

```swift
try parser.setOptionalValueHandler("--color",
                                   handler: { context, value in
                                   },
                                   description: "Set or auto-detect color output.")
```

Inline roots:

```swift
var build = try InlineParser("--build")
try build.setHandler("-profile",
                     handler: { context, value in
                     },
                     description: "Set build profile.")
```

Bare-root value handlers:

```swift
var config = try InlineParser("--config")
try config.setRootValueHandler({ context, value in
}, valuePlaceholder: "<assignment>", description: "Store a config assignment.")
```

Aliases:

```swift
try parser.addAlias("-v", target: "--verbose")
try parser.addAlias("-c", target: "--config-load", presetTokens: ["user-file"])
```

Positionals:

```swift
try parser.setPositionalHandler { context in
    for token in context.valueTokens {
        usePositional(token)
    }
}
```

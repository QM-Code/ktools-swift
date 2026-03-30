# API Guide

The public Swift API lives in [`../src/Sources/Kcli/`](../src/Sources/Kcli/).

## Core Types

`Parser`

- Registers top-level handlers, aliases, positionals, and inline parsers.
- Provides `parseOrExit()` and `parse(_:)`.

`InlineParser`

- Registers one inline root such as `--build` or `--trace`.
- Supports bare-root value handlers through `setRootValueHandler(...)`.
- Supports flag, required-value, and optional-value handlers.

`HandlerContext`

- `root`: active inline root without leading dashes, or empty for top-level handlers and positionals
- `option`: effective option token such as `--verbose` or `--build-profile`
- `command`: normalized command token such as `verbose` or `profile`
- `valueTokens`: consumed value tokens after alias preset tokens are applied

`CliError`

- Returned by `parse(_:)` on invalid CLI input
- Exposes the effective option token through `option`

`CliConfigurationError`

- Thrown when handlers, aliases, roots, or descriptions are registered incorrectly

## InlineParser

### Construction

```swift
var build = try InlineParser("--build")
```

The root may be provided as either:

- `"build"`
- `"--build"`

### Root Value Handler

```swift
try build.setRootValueHandler(handler)
try build.setRootValueHandler(handler,
                              valuePlaceholder: "<selector>",
                              description: "Select build targets.")
```

The root value handler processes the bare root form, for example:

- `--build release`
- `--config user.json`

If the bare root is used without a value, `kcli` prints inline help for that root instead.

### Inline Handlers

```swift
try build.setHandler("-flag", handler: flagHandler, description: "Enable build flag.")
try build.setHandler("-profile", handler: valueHandler, description: "Set build profile.")
try build.setOptionalValueHandler("-enable",
                                  handler: optionalHandler,
                                  description: "Enable build mode.")
```

Inline handler options may be written in either form:

- short inline form: `-profile`
- fully-qualified form: `--build-profile`

## Parser

### Top-Level Handlers

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

Top-level handler options may be written as either:

- `"verbose"`
- `"--verbose"`

### Aliases

```swift
try parser.addAlias("-v", target: "--verbose")
try parser.addAlias("-c", target: "--config-load", presetTokens: ["user-file"])
```

Rules:

- aliases use single-dash form such as `-v`
- alias targets use double-dash form such as `--verbose`
- preset tokens are prepended to the handler's effective `valueTokens`

### Positional Handler

```swift
try parser.setPositionalHandler { context in
    for token in context.valueTokens {
        usePositional(token)
    }
}
```

### Inline Parser Registration

```swift
try parser.addInlineParser(build)
```

Duplicate inline roots are rejected.

### Parse Entry Points

```swift
parser.parseOrExit()
try parser.parse(CommandLine.arguments)
```

`parseOrExit()`

- reports invalid CLI input to `stderr` as `[error] [cli] ...`
- exits with code `2`

`parse()`

- throws `CliError`
- preserves the caller's argument list
- does not run handlers until the full command line validates

## Registration Styles

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

Use the registration form that matches the CLI contract you want:

- `setHandler(option, handler: FlagHandler, description: ...)` for flag-style options
- `setHandler(option, handler: ValueHandler, description: ...)` for required values
- `setOptionalValueHandler(option, handler: ValueHandler, description: ...)` for optional values
- `setRootValueHandler(...)` for bare inline roots such as `--build release`

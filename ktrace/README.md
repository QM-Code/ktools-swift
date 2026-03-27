# Karma Trace Logging SDK

Trace logging SDK with:

- namespaced channel tracing via `TraceLogger.trace(...)`
- always-visible operational logging via `TraceLogger.info/warn/error(...)`
- a library-facing `TraceLogger` source object
- an executable-facing `Logger` registry, filter, formatter, and output sink

## Quick Start

```swift
import Kcli
import Ktrace

let logger = Logger()
let trace = try TraceLogger("core")

try trace.addChannel("app", color: try TraceColors.color("BrightCyan"))
try logger.addTraceLogger(trace)
try logger.enableChannel(trace, ".app")

let parser = Parser()
try parser.addInlineParser(logger.makeInlineParser(trace))
try parser.parseOrThrow(CommandLine.arguments)

try trace.trace("app", "core initialized")
```

## Build SDK

Workspace-style build:

```bash
kbuild --build-latest
```

Direct SwiftPM flow:

```bash
cd src
swift test
swift run ktrace-demo-core --trace '*.*'
```

## Demos

Demo directories mirror the C++ layout even though the executable products live in the SwiftPM package:

- Bootstrap compile/import check: [demo/bootstrap/README.md](demo/bootstrap/README.md)
- SDK demos: [demo/sdk/alpha/README.md](demo/sdk/alpha/README.md), [demo/sdk/beta/README.md](demo/sdk/beta/README.md), [demo/sdk/gamma/README.md](demo/sdk/gamma/README.md)
- Executable demos: [demo/exe/core/README.md](demo/exe/core/README.md), [demo/exe/omega/README.md](demo/exe/omega/README.md)

Trace CLI examples:

```bash
cd src
swift run ktrace-demo-core --trace
swift run ktrace-demo-core --trace '.*'
swift run ktrace-demo-omega --trace '*.*'
swift run ktrace-demo-omega --trace '*.*.*.*'
swift run ktrace-demo-omega --trace '*.{net,io}'
swift run ktrace-demo-omega --trace-namespaces
swift run ktrace-demo-omega --trace-channels
swift run ktrace-demo-omega --trace-colors
swift run ktrace-demo-omega --trace-files
swift run ktrace-demo-omega --trace-functions
swift run ktrace-demo-omega --trace-timestamps
```

## API Model

`TraceLogger` is the namespace-bearing source object. Construct it with an explicit namespace and declare channels on it:

```swift
let trace = try TraceLogger("alpha")
try trace.addChannel("net", color: try TraceColors.color("DeepSkyBlue1"))
try trace.addChannel("cache", color: try TraceColors.color("Gold3"))
```

SDKs should usually expose a shared logger handle from a factory or static accessor:

```swift
enum AlphaSdk {
    static func getTraceLogger() throws -> TraceLogger {
        let trace = try TraceLogger("alpha")
        try trace.addChannel("net", color: try TraceColors.color("DeepSkyBlue1"))
        try trace.addChannel("cache", color: try TraceColors.color("Gold3"))
        return trace
    }
}
```

`Logger` is the executable-facing runtime. It imports one or more `TraceLogger`s, maintains the central channel registry, and owns filtering, formatting, and final output:

```swift
let logger = Logger()
let appTrace = try TraceLogger("core")

try appTrace.addChannel("app", color: try TraceColors.color("BrightCyan"))
try appTrace.addChannel("startup", color: try TraceColors.color("BrightYellow"))

try logger.addTraceLogger(appTrace)
```

## Logging APIs

Channel-based trace output:

```swift
try trace.trace("channel", "message {}", value)
try trace.traceChanged("channel", key, "message {}", value)
```

Always-visible operational logging:

```swift
try trace.info("message")
try trace.warn("configuration file '{}' was not found", path)
try trace.error("fatal startup failure")
```

Operational logging is independent of channel enablement. It is still namespaced and uses the same formatting options as trace output.

Message formatting supports sequential `{}` placeholders and escaped braces `{{` and `}}`.

## CLI Integration

The inline parser is logger-bound rather than global. Pass the executable's local `TraceLogger` so leading-dot selectors resolve against the right namespace:

```swift
let logger = Logger()
let appTrace = try TraceLogger("core")

try appTrace.addChannel("app", color: try TraceColors.color("BrightCyan"))
try logger.addTraceLogger(appTrace)

let parser = Parser()
try parser.addInlineParser(logger.makeInlineParser(appTrace))
```

## Channel Expression Forms

Single-selector APIs on `Logger`:

- `.channel[.sub[.sub]]` for a local channel in the provided local namespace
- `namespace.channel[.sub[.sub]]` for an explicit namespace

List APIs on `Logger`:

- `enableChannels(...)`
- `disableChannels(...)`
- list APIs accept selector patterns such as `*`, `{}`, and CSV
- list APIs resolve selectors against the channels currently registered at call time
- leading-dot selectors in list APIs resolve against the provided local namespace
- empty or whitespace selector lists are rejected
- unregistered channels remain disabled and do not emit, even if a selector pattern would otherwise match

Examples:

- `try logger.enableChannel(appTrace, ".app")`
- `try logger.enableChannel("alpha.net")`
- `try logger.enableChannels("alpha.*,{beta,gamma}.net.*")`
- `try logger.enableChannels(appTrace, ".net.*,otherapp.scheduler.tick")`

Formatting options:

- `--trace-files`
- `--trace-functions`
- `--trace-timestamps`

These affect both `trace(...)` output and `info/warn/error(...)` output.

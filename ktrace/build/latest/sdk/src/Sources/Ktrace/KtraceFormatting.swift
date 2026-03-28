import Foundation

func emitTrace(_ logger: LoggerStorage,
               traceNamespace: String,
               channel: String,
               source: SourceContext,
               message: String) {
    let payload = formatOutput(logger: logger,
                               traceNamespace: traceNamespace,
                               label: channel,
                               source: source,
                               message: message)
    withLock(logger.outputLock) {
        logger.output(payload)
    }
}

func emitLog(_ logger: LoggerStorage,
             traceNamespace: String,
             severity: LogSeverity,
             source: SourceContext,
             message: String) {
    let payload = formatOutput(logger: logger,
                               traceNamespace: traceNamespace,
                               label: severity.rawValue,
                               source: source,
                               message: message)
    withLock(logger.outputLock) {
        logger.output(payload)
    }
}

func formatOutput(logger: LoggerStorage,
                  traceNamespace: String,
                  label: String,
                  source: SourceContext,
                  message: String) -> String {
    let options = withLock(logger.outputLock) { logger.options }
    var parts = ["[\(traceNamespace)]"]
    if options.timestamps {
        parts.append("[\(formatTimestamp(Date().timeIntervalSince1970))]")
    }
    parts.append("[\(label)]")
    if options.filenames {
        var sourceLabel = "[\(basename(source.file))"
        if options.lineNumbers {
            sourceLabel += ":\(source.line)"
        }
        if options.functionNames {
            sourceLabel += ":\(source.function)"
        }
        sourceLabel += "]"
        parts.append(sourceLabel)
    }
    return "\(parts.joined(separator: " ")) \(message)\n"
}

func formatTimestamp(_ secondsSinceEpoch: TimeInterval) -> String {
    String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), secondsSinceEpoch)
}

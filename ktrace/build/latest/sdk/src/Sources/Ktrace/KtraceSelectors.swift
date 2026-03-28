struct ExactChannelResolution {
    let key: String
    let traceNamespace: String
    let channel: String
}

struct SelectorResolution {
    let channelKeys: [String]
    let unmatchedSelectors: [String]
}

struct CanonicalSelector {
    let pattern: String
    let display: String
}

func canonicalSelector(_ selector: String,
                       localNamespace: String) throws -> CanonicalSelector {
    let token = trimWhitespace(selector)
    if token == "*" {
        throw TraceConfigurationError("Invalid trace selector: '*' (did you mean '.*'?)")
    }
    if token.hasPrefix(".") {
        let namespace = try normalizeNamespace(localNamespace)
        let suffix = String(token.dropFirst())
        try validateSelectorBody(suffix)
        return CanonicalSelector(pattern: "\(namespace).\(suffix)", display: "\(namespace).\(suffix)")
    }

    guard let dotIndex = token.firstIndex(of: ".") else {
        throw TraceConfigurationError("Invalid trace selector: '\(token)'")
    }
    let namespacePattern = String(token[..<dotIndex])
    let channelPattern = String(token[token.index(after: dotIndex)...])
    if namespacePattern != "*" && !isIdentifierToken(namespacePattern) {
        throw TraceConfigurationError("Invalid trace selector: '\(token)'")
    }
    try validateSelectorBody(channelPattern)
    return CanonicalSelector(pattern: "\(namespacePattern).\(channelPattern)", display: token)
}

func validateSelectorBody(_ body: String) throws {
    let segments = body.split(separator: ".", omittingEmptySubsequences: false)
    if body.isEmpty || segments.isEmpty || segments.count > 3 {
        throw TraceConfigurationError("Invalid trace selector: '\(body)'")
    }
    for segment in segments {
        let token = String(segment)
        if token != "*" && !isIdentifierToken(token) {
            throw TraceConfigurationError("Invalid trace selector: '\(body)'")
        }
    }
}

func selectorMatches(_ pattern: String, candidate: String) throws -> Bool {
    let patternParts = pattern.split(separator: ".").map(String.init)
    let candidateParts = candidate.split(separator: ".").map(String.init)
    guard patternParts.count >= 2, candidateParts.count >= 2 else {
        return false
    }

    let namespacePattern = patternParts[0]
    let namespaceValue = candidateParts[0]
    if namespacePattern != "*" && namespacePattern != namespaceValue {
        return false
    }

    let selectorChannelParts = Array(patternParts.dropFirst())
    let candidateChannelParts = Array(candidateParts.dropFirst())
    if candidateChannelParts.count > selectorChannelParts.count {
        return false
    }

    for index in candidateChannelParts.indices {
        let patternToken = selectorChannelParts[index]
        if patternToken != "*" && patternToken != candidateChannelParts[index] {
            return false
        }
    }

    if candidateChannelParts.count < selectorChannelParts.count {
        for token in selectorChannelParts[candidateChannelParts.count...] where token != "*" {
            return false
        }
    }
    return true
}

func splitCSV(_ text: String) -> [String] {
    var tokens: [String] = []
    var current = ""
    var braceDepth = 0
    for character in text {
        switch character {
        case "{":
            braceDepth += 1
            current.append(character)
        case "}":
            braceDepth = max(0, braceDepth - 1)
            current.append(character)
        case "," where braceDepth == 0:
            tokens.append(current)
            current = ""
        default:
            current.append(character)
        }
    }
    if !current.isEmpty {
        tokens.append(current)
    }
    return tokens
}

func expandBraceSelectors(_ selector: String) throws -> [String] {
    guard let open = selector.firstIndex(of: "{"),
          let close = selector[open...].firstIndex(of: "}") else {
        return [selector]
    }

    let prefix = String(selector[..<open])
    let suffix = String(selector[selector.index(after: close)...])
    let body = String(selector[selector.index(after: open)..<close])
    let options = splitCSV(body).map(trimWhitespace).filter { !$0.isEmpty }
    if options.isEmpty {
        throw TraceConfigurationError("Invalid trace selector: '\(selector)'")
    }

    var expanded: [String] = []
    for option in options {
        let combined = prefix + option + suffix
        expanded.append(contentsOf: try expandBraceSelectors(combined))
    }
    return expanded
}

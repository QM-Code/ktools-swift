import Foundation

func trimWhitespace(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

func containsWhitespace(_ value: String) -> Bool {
    value.unicodeScalars.contains { CharacterSet.whitespacesAndNewlines.contains($0) }
}

func startsWith(_ value: String, prefix: String) -> Bool {
    value.hasPrefix(prefix)
}

func normalizeRootNameOrThrow(_ rawRoot: String) throws -> String {
    let root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if root.first == "-" {
        throw CliConfigurationError("kcli root must not begin with '-'")
    }
    if containsWhitespace(root) {
        throw CliConfigurationError("kcli root is invalid")
    }
    return root
}

func normalizeInlineRootOptionOrThrow(_ rawRoot: String) throws -> String {
    var root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if startsWith(root, prefix: "--") {
        root.removeFirst(2)
    } else if root.first == "-" {
        throw CliConfigurationError("kcli root must use '--root' or 'root'")
    }
    return try normalizeRootNameOrThrow(root)
}

func normalizeInlineHandlerOptionOrThrow(_ rawOption: String,
                                         rootName: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli inline handler option must not be empty")
    }

    if startsWith(option, prefix: "--") {
        let fullPrefix = "--\(rootName)-"
        if !startsWith(option, prefix: fullPrefix) {
            throw CliConfigurationError("kcli inline handler option must use '-name' or '\(fullPrefix)name'")
        }
        option.removeFirst(fullPrefix.count)
    } else if option.first == "-" {
        option.removeFirst()
    } else {
        throw CliConfigurationError("kcli inline handler option must use '-name' or '--\(rootName)-name'")
    }

    if option.isEmpty {
        throw CliConfigurationError("kcli command must not be empty")
    }
    if option.first == "-" {
        throw CliConfigurationError("kcli command must not start with '-'")
    }
    if containsWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

func normalizePrimaryHandlerOptionOrThrow(_ rawOption: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli end-user handler option must not be empty")
    }

    if startsWith(option, prefix: "--") {
        option.removeFirst(2)
    } else if option.first == "-" {
        throw CliConfigurationError("kcli end-user handler option must use '--name' or 'name'")
    }

    if option.isEmpty {
        throw CliConfigurationError("kcli command must not be empty")
    }
    if option.first == "-" {
        throw CliConfigurationError("kcli command must not start with '-'")
    }
    if containsWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

func normalizeAliasOrThrow(_ rawAlias: String) throws -> String {
    let alias = trimWhitespace(rawAlias)
    if alias.count < 2 || alias.first != "-" || startsWith(alias, prefix: "--") || containsWhitespace(alias) {
        throw CliConfigurationError("kcli alias must use single-dash form, e.g. '-v'")
    }
    return alias
}

func normalizeAliasTargetOptionOrThrow(_ rawTarget: String) throws -> String {
    let target = trimWhitespace(rawTarget)
    if target.count < 3 || !startsWith(target, prefix: "--") || containsWhitespace(target) {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    let index = target.index(target.startIndex, offsetBy: 2)
    if target[index] == "-" {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    return target
}

func normalizeHelpPlaceholderOrThrow(_ rawPlaceholder: String) throws -> String {
    let placeholder = trimWhitespace(rawPlaceholder)
    if placeholder.isEmpty {
        throw CliConfigurationError("kcli help placeholder must not be empty")
    }
    return placeholder
}

func normalizeDescriptionOrThrow(_ rawDescription: String) throws -> String {
    let description = trimWhitespace(rawDescription)
    if description.isEmpty {
        throw CliConfigurationError("kcli command description must not be empty")
    }
    return description
}

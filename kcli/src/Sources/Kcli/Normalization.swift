import Foundation

func trimWhitespace(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

func hasWhitespace(_ value: String) -> Bool {
    value.unicodeScalars.contains { CharacterSet.whitespacesAndNewlines.contains($0) }
}

func normalizedRootName(_ rawRoot: String) throws -> String {
    let root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if root.first == "-" {
        throw CliConfigurationError("kcli root must not begin with '-'")
    }
    if hasWhitespace(root) {
        throw CliConfigurationError("kcli root is invalid")
    }
    return root
}

func normalizedInlineRoot(_ rawRoot: String) throws -> String {
    var root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if root.hasPrefix("--") {
        root.removeFirst(2)
    } else if root.first == "-" {
        throw CliConfigurationError("kcli root must use '--root' or 'root'")
    }
    return try normalizedRootName(root)
}

func normalizedInlineHandlerOption(_ rawOption: String,
                                   rootName: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli inline handler option must not be empty")
    }

    if option.hasPrefix("--") {
        let fullPrefix = "--\(rootName)-"
        if !option.hasPrefix(fullPrefix) {
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
    if hasWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

func normalizedPrimaryHandlerOption(_ rawOption: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli end-user handler option must not be empty")
    }

    if option.hasPrefix("--") {
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
    if hasWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

func normalizedAlias(_ rawAlias: String) throws -> String {
    let alias = trimWhitespace(rawAlias)
    if alias.count < 2 || alias.first != "-" || alias.hasPrefix("--") || hasWhitespace(alias) {
        throw CliConfigurationError("kcli alias must use single-dash form, e.g. '-v'")
    }
    return alias
}

func normalizedAliasTargetOption(_ rawTarget: String) throws -> String {
    let target = trimWhitespace(rawTarget)
    if target.count < 3 || !target.hasPrefix("--") || hasWhitespace(target) {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    let index = target.index(target.startIndex, offsetBy: 2)
    if target[index] == "-" {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    return target
}

func normalizedHelpPlaceholder(_ rawPlaceholder: String) throws -> String {
    let placeholder = trimWhitespace(rawPlaceholder)
    if placeholder.isEmpty {
        throw CliConfigurationError("kcli help placeholder must not be empty")
    }
    return placeholder
}

func normalizedDescription(_ rawDescription: String) throws -> String {
    let description = trimWhitespace(rawDescription)
    if description.isEmpty {
        throw CliConfigurationError("kcli command description must not be empty")
    }
    return description
}

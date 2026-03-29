func printHelp(root: String, helpRows: [HelpRow], io: ParserIO) {
    io.stdout("\nAvailable --\(root)-* options:\n")

    let maxLeftWidth = helpRows.map { $0.0.count }.max() ?? 0
    if helpRows.isEmpty {
        io.stdout("  (no options registered)\n")
        io.stdout("\n")
        return
    }

    for row in helpRows {
        let padding = max(0, maxLeftWidth - row.0.count) + 2
        io.stdout("  \(row.0)\(String(repeating: " ", count: padding))\(row.1)\n")
    }
    io.stdout("\n")
}

func buildHelpRows(for parser: InlineParser) -> [HelpRow] {
    var rows: [HelpRow] = []
    if parser.rootValueHandler != nil && !parser.rootValueDescription.isEmpty {
        var lhs = "--\(parser.rootName)"
        if !parser.rootValuePlaceholder.isEmpty {
            lhs += " \(parser.rootValuePlaceholder)"
        }
        rows.append((lhs, parser.rootValueDescription))
    }

    for (command, binding) in parser.commands {
        var lhs = "--\(parser.rootName)-\(command)"
        switch binding.handler {
        case .flag:
            break
        case .value(_, let arity):
            lhs += (arity == .optional) ? " [value]" : " <value>"
        }
        rows.append((lhs, binding.description))
    }
    return rows
}

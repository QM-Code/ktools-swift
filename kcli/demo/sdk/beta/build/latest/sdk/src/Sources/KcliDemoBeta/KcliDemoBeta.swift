import Kcli
import KcliDemoSupport

public func makeKcliDemoBetaParser(
    emit: @escaping DemoEmitter = defaultDemoEmit
) throws -> InlineParser {
    try makeBetaInlineParser(emit: emit)
}

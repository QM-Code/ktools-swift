import Kcli
import KcliDemoSupport

public func makeKcliDemoAlphaParser(
    emit: @escaping DemoEmitter = defaultDemoEmit
) throws -> InlineParser {
    try makeAlphaInlineParser(emit: emit)
}

import Kcli
import KcliDemoSupport

public func makeKcliDemoGammaParser(
    emit: @escaping DemoEmitter = defaultDemoEmit
) throws -> InlineParser {
    try makeGammaInlineParser(emit: emit)
}

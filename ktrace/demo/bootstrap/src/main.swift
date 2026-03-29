import Ktrace

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

func runBootstrapDemo() -> Int {
    do {
        let logger = Logger()
        let trace = try TraceLogger("bootstrap")
        try trace.addChannel("app")
        try logger.addTraceLogger(trace)
        try logger.enableChannel(trace, ".app")
        try trace.trace("app", "ktrace Swift demo bootstrap import/integration check passed")
        return 0
    } catch {
        print("[fatal] \(String(describing: error))")
        return 1
    }
}

exit(Int32(runBootstrapDemo()))

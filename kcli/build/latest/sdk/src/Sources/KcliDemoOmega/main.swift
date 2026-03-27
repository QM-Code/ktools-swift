import KcliDemoSupport

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

exit(Int32(runOmegaDemo()))

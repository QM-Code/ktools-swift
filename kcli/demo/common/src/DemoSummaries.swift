func emitCoreSummary(exeName: String, emit: DemoEmitter) {
    emit("\nKCLI Swift demo core import/integration check passed\n\n")
    emit("Usage:\n")
    emit("  \(exeName) --alpha\n")
    emit("  \(exeName) --output stdout\n\n")
    emit("Enabled inline roots:\n")
    emit("  --alpha\n\n")
}

func emitOmegaSummary(emit: DemoEmitter) {
    emit("\nUsage:\n")
    emit("  kcli_demo_omega --<root>\n\n")
    emit("Enabled --<root> prefixes:\n")
    emit("  --alpha\n")
    emit("  --beta\n")
    emit("  --newgamma (gamma override)\n\n")
}

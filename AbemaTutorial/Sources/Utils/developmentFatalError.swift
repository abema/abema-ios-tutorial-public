func developmentFatalError(_ message: String = "",
                           file: StaticString = #file,
                           line: UInt = #line,
                           function: StaticString = #function) {
    print("[FATAL] \(file):\(line) \(function): \(message)")

    #if DEBUG
    fatalError(message, file: file, line: line)
    #endif
}

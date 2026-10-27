import Foundation

private func usage() {
    print("Usage: secret-audit <filename> [--json]")
    print("Offline scan of one local text file; secret contents are never printed.")
}

let args = Array(CommandLine.arguments.dropFirst())
if args.isEmpty || args.contains("--help") || args.contains("-h") {
    usage()
    exit(args.isEmpty ? 1 : 0)
}
if args.count > 2 || args.filter({ $0 == "--json" }).count > 1 {
    usage()
    exit(1)
}
let filenames = args.filter { $0 != "--json" }
guard filenames.count == 1 else {
    usage()
    exit(1)
}
let url = URL(fileURLWithPath: filenames[0])
let jsonMode = args.contains("--json")
do {
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
    guard size <= 1_000_000 else {
        fputs("Error: file is larger than 1 MB; choose a smaller text file.\n", stderr)
        exit(2)
    }
    let contents = try String(contentsOf: url, encoding: .utf8)
    let findings = SecretScanner().scan(contents)
    if jsonMode {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let result = try encoder.encode(findings)
        print(String(data: result, encoding: .utf8) ?? "[]")
    } else {
        print("Scanned: \(url.lastPathComponent)")
        print("Potential findings: \(findings.count)")
        for finding in findings {
            print("  line \(finding.line): \(finding.rule) - \(finding.message)")
        }
        print("Reminder: heuristic matches may be false positives.")
    }
    exit(findings.isEmpty ? 0 : 3)
} catch {
    fputs("Error reading file: \(error.localizedDescription)\n", stderr)
    exit(2)
}

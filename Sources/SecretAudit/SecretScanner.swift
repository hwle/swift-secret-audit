import Foundation

/// A safe, offline heuristic scanner for accidentally hardcoded credentials.
/// Findings never include matched secret values.
struct SecretFinding: Codable, Equatable {
    let line: Int
    let rule: String
    let message: String
}

struct SecretScanner {
    private struct Rule {
        let id: String
        let message: String
        let pattern: String
    }

    private let rules: [Rule] = [
        Rule(
            id: "PRIVATE_KEY_BLOCK",
            message: "Possible private key header",
            pattern: #"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"#
        ),
        Rule(
            id: "HARDCODED_TOKEN",
            message: "Possible token or API key assigned in source text",
            pattern: #"\b(?:api[_-]?key|access[_-]?token|secret[_-]?key)\b\s*[:=]\s*[\"']?[A-Za-z0-9_\-]{12,}"#
        ),
        Rule(
            id: "HARDCODED_PASSWORD",
            message: "Possible hardcoded password",
            pattern: #"\bpassword\b\s*[:=]\s*[\"']?[^\s\"']{6,}"#
        ),
    ]

    func scan(_ content: String) -> [SecretFinding] {
        let lines = content.components(separatedBy: .newlines)
        var findings: [SecretFinding] = []
        for (index, line) in lines.enumerated() {
            for rule in rules {
                guard let regex = try? NSRegularExpression(
                    pattern: rule.pattern, options: [.caseInsensitive]
                ) else { continue }
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                if regex.firstMatch(in: line, range: range) != nil {
                    findings.append(SecretFinding(
                        line: index + 1, rule: rule.id, message: rule.message
                    ))
                }
            }
        }
        return findings
    }
}

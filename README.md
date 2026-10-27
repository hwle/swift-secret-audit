# SecretAudit | Swift CLI Credential Leak Checker

A local Swift command-line tool that scans a UTF-8 text file for possible
hardcoded credentials. No uploads, API calls, or third-party dependencies.

## Why I built this

Even simple configuration files can accidentally include passwords, tokens, or
private-key markers. This is an educational, privacy-conscious static scanner
showcasing Swift `Foundation`, regular expressions, Swift Package Manager,
command-line design, JSON output, and XCTest unit tests.

## Quick start

Requires Swift 5.9+ on macOS or Linux:

```sh
swift run secret-audit examples/demo-config.txt
swift run secret-audit examples/demo-config.txt --json
swift test
```

The scanner exits with code `3` when it finds possible secrets, `0` when clean,
`2` for file errors, or `1` for invalid arguments. Exit code 3 is expected for
the included intentionally insecure demo file.

## Privacy by design

- Reads **one explicitly selected local file** (up to 1 MB).
- Never prints a matching secret, only rule name and line number.
- Does not connect to the internet, store results, or modify files.
- The demo file contains fake strings, not real keys.

## Limitations / roadmap

Regex checks are heuristic and cannot prove a secret is valid. False positives
and false negatives are expected. A next version could scan directories, add
allowlists, and include entropy-based checks, but would need safe exclusions to
avoid scanning unrelated private files.

**Important:** Do not upload real `.env` files, passwords, or keys to GitHub.

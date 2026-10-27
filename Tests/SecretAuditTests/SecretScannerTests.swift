import XCTest
@testable import SecretAudit

final class SecretScannerTests: XCTestCase {
    func testDetectsDummyTokenWithoutLeakingValue() {
        let input = "api_key = DEMO_NOT_A_REAL_TOKEN_12345"
        let results = SecretScanner().scan(input)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].rule, "HARDCODED_TOKEN")
        XCTAssertFalse(results[0].message.contains("DEMO_NOT_A_REAL_TOKEN_12345"))
    }

    func testDetectsExamplePrivateKeyMarker() {
        let results = SecretScanner().scan("-----BEGIN PRIVATE KEY-----")
        XCTAssertEqual(results.first?.rule, "PRIVATE_KEY_BLOCK")
    }

    func testReportsCorrectLineNumber() {
        let results = SecretScanner().scan("hello\npassword: demoPassword123\nworld")
        XCTAssertEqual(results.first?.line, 2)
    }

    func testIgnoresHarmlessInput() {
        XCTAssertTrue(SecretScanner().scan("let username = \"student\"").isEmpty)
    }
}

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SecretAudit",
    products: [.executable(name: "secret-audit", targets: ["SecretAudit"])],
    targets: [
        .executableTarget(name: "SecretAudit"),
        .testTarget(name: "SecretAuditTests", dependencies: ["SecretAudit"]),
    ]
)

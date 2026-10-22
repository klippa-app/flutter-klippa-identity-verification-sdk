// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "klippa_identity_verification_sdk",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "klippa-identity-verification-sdk", targets: ["klippa_identity_verification_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Keep in sync with ../sdk_version, which CocoaPods uses.
        .package(url: "https://github.com/klippa-app/klippa-identity-verification-spm", exact: "0.7.0")
    ],
    targets: [
        .target(
            name: "klippa_identity_verification_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "KlippaIdentityVerification", package: "klippa-identity-verification-spm")
            ]
        )
    ]
)

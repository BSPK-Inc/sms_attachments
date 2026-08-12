// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sms_attachments",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "sms-attachments", targets: ["sms_attachments"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "sms_attachments",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // If your plugin requires a privacy manifest, for example if it uses any
                // required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
                // plugin's privacy impact, and then uncomment this line. For more information,
                // see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)

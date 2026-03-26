// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RoktStripePaymentExtension",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "RoktStripePaymentExtension", targets: ["RoktStripePaymentExtension"])
    ],
    dependencies: [
        .package(url: "https://github.com/ROKT/rokt-contracts-apple.git", from: "0.1.2"),
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "24.25.0")
    ],
    targets: [
        .target(
            name: "RoktStripePaymentExtension",
            dependencies: [
                .product(name: "RoktContracts", package: "rokt-contracts-apple"),
                .product(name: "StripeApplePay", package: "stripe-ios")
            ]
        ),
        .testTarget(
            name: "RoktStripePaymentExtensionTests",
            dependencies: ["RoktStripePaymentExtension"]
        )
    ]
)

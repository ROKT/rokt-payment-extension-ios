# Rokt Stripe Payment Extension (iOS)

Optional Stripe payment integration for the Rokt iOS SDK ecosystem.
Provides Apple Pay support via Stripe for [Shoppable Ads](https://docs.rokt.com) placements.

This package depends only on [RoktContracts](https://github.com/ROKT/rokt-contracts-apple) — not the full Rokt SDK — keeping the Stripe dependency isolated and the integration lightweight.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Stripe account with Apple Pay enabled

## Installation

### Swift Package Manager

In Xcode: **File > Add Packages**, enter:

```text
https://github.com/ROKT/rokt-stripe-payment-extension-ios.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ROKT/rokt-stripe-payment-extension-ios.git", from: "0.1.0")
]
```

### CocoaPods

```ruby
pod 'RoktStripePaymentExtension'
```

## Usage

### Direct Rokt SDK Integration

When using the Rokt SDK directly, the partner provides the Stripe publishable key
explicitly at registration time:

```swift
import Rokt_Widget
import RoktStripePaymentExtension

// 1. Initialize Rokt
Rokt.initWith(roktTagId: "your-tag-id")

// 2. Create the payment extension with your Apple Pay merchant ID
guard let stripeExtension = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.example"
) else { return }

// 3. Register with the Rokt SDK — pass your Stripe publishable key
Rokt.registerPaymentExtension(stripeExtension, config: [
    "stripeKey": "pk_live_abc123"
])

// 4. Show Shoppable Ads (always overlay)
Rokt.selectShoppableAds(
    identifier: "ConfirmationPage",
    attributes: [
        "email": "user@example.com",
        "firstname": "John",
        "lastname": "Doe",
        "confirmationref": "ORDER-12345"
    ],
    onEvent: { event in
        switch event {
        case let e as RoktEvent.CartItemInstantPurchase:
            print("Purchase: \(e.catalogItemId)")
        case let e as RoktEvent.CartItemInstantPurchaseFailure:
            print("Failed: \(e.error ?? "unknown")")
        default:
            break
        }
    }
)
```

### mParticle Joint SDK Integration

When using the mParticle SDK, the Stripe publishable key is **automatically provided
from the mParticle dashboard configuration**. The partner only needs to create the
extension and register it — the Kit injects the `stripeKey` before forwarding to the
Rokt SDK:

```swift
import mParticle_Apple_SDK
import RoktStripePaymentExtension

// 1. mParticle init handles Rokt.initialize via Kit (tagId from dashboard)

// 2. Create and register the payment extension — no stripeKey needed
guard let stripeExtension = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.example"
) else { return }
MParticle.sharedInstance().rokt.registerPaymentExtension(stripeExtension)
// Kit automatically injects stripeKey from dashboard config

// 3. Show Shoppable Ads
MParticle.sharedInstance().rokt.shoppableAds(
    "ConfirmationPage",
    attributes: [
        "email": "user@example.com",
        "firstname": "John",
        "lastname": "Doe"
    ]
)
```

### What Partners Need for Each Scenario

| Scenario                        | Packages                                 | Stripe Key Source             | Code                                                                 |
| ------------------------------- | ---------------------------------------- | ----------------------------- | -------------------------------------------------------------------- |
| Standard placements (mParticle) | mParticle SDK + Rokt Kit                 | —                             | `rokt.selectPlacements(...)`                                         |
| Shoppable Ads (mParticle)       | Above + RoktStripePaymentExtension       | Dashboard config (automatic)  | `registerPaymentExtension(ext)` + `shoppableAds(...)`                |
| Standard placements (Direct)    | Rokt-Widget                              | —                             | `Rokt.selectPlacements(...)`                                         |
| Shoppable Ads (Direct)          | Rokt-Widget + RoktStripePaymentExtension | Partner passes in config dict | `registerPaymentExtension(ext, config:)` + `selectShoppableAds(...)` |

## Architecture

```text
RoktStripePaymentExtension (public facade)
  └── StripeApplePayManager (internal orchestration)
       ├── STPApplePayContext (Stripe SDK)
       └── ContactAddressMapping (PKContact → ContactAddress)
```

- **RoktStripePaymentExtension**: Implements `PaymentExtension` protocol from RoktContracts
- **StripeApplePayManager**: Manages Apple Pay flow via Stripe's `STPApplePayContext`
- **ContactAddressMapping**: Converts Apple Pay contact data to contract types

## License

Copyright 2024 Rokt Pte Ltd. Licensed under the [Rokt SDK Terms of Use 2.0](https://rokt.com/sdk-license-2-0/).

## Security

Please report vulnerabilities via our [disclosure form](https://www.rokt.com/vulnerability-disclosure/). Do not use GitHub issues.

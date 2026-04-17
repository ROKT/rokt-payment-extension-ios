# Rokt Stripe Payment Extension (iOS)

Optional Stripe payment integration for the Rokt iOS SDK ecosystem.
Provides Apple Pay, card, and Afterpay/Clearpay support via Stripe for
[Shoppable Ads](https://docs.rokt.com) placements.

This package depends only on [RoktContracts](https://github.com/ROKT/rokt-contracts-apple) — not the full Rokt SDK — keeping the Stripe dependency isolated and the integration lightweight.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Stripe account with Apple Pay enabled
- For Afterpay / Clearpay: a Stripe account with the method enabled and a custom
  URL scheme registered in the host app's `Info.plist` for redirect callbacks

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
Rokt.initialize(roktTagId: "your-tag-id")

// 2. Create the payment extension with your Apple Pay merchant ID.
//    Optionally pass `returnURL` (a custom URL scheme) to enable Afterpay / Clearpay.
guard let stripeExtension = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.example",
    returnURL: "myapp://stripe-redirect" // omit to keep the extension Apple-Pay-only
) else { return }

// 3. Register with the Rokt SDK — pass your Stripe publishable key
Rokt.registerPaymentExtension(stripeExtension, config: [
    "stripeKey": "pk_live_abc123"
])

// 4. Show Shoppable Ads (always overlay)
Rokt.shoppableAds(
    viewName: "ConfirmationPage",
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

// 2. Create and register the payment extension — no stripeKey needed.
//    Optionally pass `returnURL` to enable Afterpay / Clearpay.
guard let stripeExtension = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.example",
    returnURL: "myapp://stripe-redirect" // omit to keep the extension Apple-Pay-only
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

### Enabling Afterpay / Clearpay

Afterpay/Clearpay is a redirect-based payment method: Stripe opens a web page for
authentication and redirects back to your app via a custom URL scheme.

1. **Declare the URL scheme** in your host app's `Info.plist` under
   `CFBundleURLTypes` (e.g. `myapp`).
2. **Pass the matching `returnURL`** when creating the extension
   (e.g. `"myapp://stripe-redirect"`). Omit it and the extension stays
   Apple-Pay-only.
3. **Forward redirect URLs** to the Rokt SDK from your `SceneDelegate` /
   `AppDelegate`. The SDK dispatches the URL to every registered
   `PaymentExtension` via the optional `handleURLCallback(with:)` hook, which
   this extension implements by calling `StripeAPI.handleURLCallback(with:)`.

   ```swift
   // SceneDelegate
   func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
       for ctx in URLContexts {
           Rokt.handleURLCallback(with: ctx.url)
       }
   }
   ```

### What Partners Need for Each Scenario

| Scenario                        | Packages                                 | Stripe Key Source             | Code                                                           |
| ------------------------------- | ---------------------------------------- | ----------------------------- | -------------------------------------------------------------- |
| Standard placements (mParticle) | mParticle SDK + Rokt Kit                 | —                             | `rokt.selectPlacements(...)`                                   |
| Shoppable Ads (mParticle)       | Above + RoktStripePaymentExtension       | Dashboard config (automatic)  | `registerPaymentExtension(ext)` + `shoppableAds(...)`          |
| Standard placements (Direct)    | Rokt-Widget                              | —                             | `Rokt.selectPlacements(...)`                                   |
| Shoppable Ads (Direct)          | Rokt-Widget + RoktStripePaymentExtension | Partner passes in config dict | `registerPaymentExtension(ext, config:)` + `shoppableAds(...)` |

## Architecture

```text
RoktStripePaymentExtension (public facade)
  ├── StripeApplePayManager (Apple Pay / card)
  │    ├── STPApplePayContext (Stripe SDK)
  │    └── ContactAddressMapping (PKContact → ContactAddress)
  ├── StripeAfterpayManager (Afterpay / Clearpay)
  │    ├── STPPaymentHandler (Stripe SDK)
  │    └── BillingDetailsMapping (ContactAddress → Stripe billing/shipping)
  └── handleURLCallback(with:) → StripeAPI.handleURLCallback
```

- **RoktStripePaymentExtension**: Implements `PaymentExtension` protocol from RoktContracts; routes each `PaymentMethodType` to the matching internal manager.
- **StripeApplePayManager**: Manages Apple Pay / card flows via Stripe's `STPApplePayContext`.
- **StripeAfterpayManager**: Manages redirect-based Afterpay / Clearpay flows via `STPPaymentHandler`; validates `PaymentContext.billingAddress` and confirms the PaymentIntent with the configured `returnURL`.
- **ContactAddressMapping**: Converts Apple Pay `PKContact` to `ContactAddress`.
- **BillingDetailsMapping**: Converts `ContactAddress` to `STPPaymentMethodBillingDetails` and `STPPaymentIntentShippingDetailsParams`.

## License

Copyright 2024 Rokt Pte Ltd. Licensed under the [Rokt SDK Terms of Use 2.0](https://rokt.com/sdk-license-2-0/).

## Security

Please report vulnerabilities via our [disclosure form](https://www.rokt.com/vulnerability-disclosure/). Do not use GitHub issues.

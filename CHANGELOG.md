<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-04-02

### Breaking Changes

- Align with rokt-contracts-apple 0.1.3 breaking API changes ([#8](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/8))

### Added

- Initial RoktStripePaymentExtension implementing PaymentExtension from contracts

### Fixed

- Use standard Keep a Changelog format for release automation ([#6](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/6))
- Update RoktContracts version and drop v-prefix from release tags ([#1](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/1))

### Changed

- Use GitHub App token and shared workflow for trunk upgrade ([#4](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/4))
- Upgrade trunk to 1.25.0 ([#3](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/3))
- Bump codecov/codecov-action from 5.5.3 to 6.0.0 ([#2](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/2))

## [0.1.1] - 2026-04-02

### Added

- Initial RoktStripePaymentExtension implementing PaymentExtension from contracts

### Fixed

- Use standard Keep a Changelog format for release automation ([#6](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/6))
- Update RoktContracts version and drop v-prefix from release tags ([#1](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/1))

### Changed

- Use GitHub App token and shared workflow for trunk upgrade ([#4](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/4))
- Upgrade trunk to 1.25.0 ([#3](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/3))
- Bump codecov/codecov-action from 5.5.3 to 6.0.0 ([#2](https://github.com/ROKT/rokt-stripe-payment-extension-ios/pull/2))

## [0.1.0] - 2025-03-25

### Added

- `RoktStripePaymentExtension` implementing `PaymentExtension` protocol from RoktContracts
- Apple Pay support via Stripe's `STPApplePayContext`
- `ContactAddressMapping` for converting Apple Pay contact data to contract types
- Swift Package Manager and CocoaPods support
- GitHub Actions CI (trunk lint, unit tests, podspec lint)
- Dependabot for GitHub Actions dependency updates

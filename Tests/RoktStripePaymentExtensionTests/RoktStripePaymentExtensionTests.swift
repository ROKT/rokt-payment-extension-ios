import XCTest
@testable import RoktStripePaymentExtension

final class RoktStripePaymentExtensionTests: XCTestCase {

    func testInitWithEmptyMerchantIdReturnsNil() {
        XCTAssertNil(RoktStripePaymentExtension(applePayMerchantId: ""))
    }

    func testInitWithValidMerchantIdReturnsInstance() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")
        XCTAssertNotNil(ext)
    }

    func testProtocolProperties() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        XCTAssertEqual(ext.id, "rokt-stripe-payment-extension")
        XCTAssertEqual(ext.extensionDescription, "Rokt Stripe Payment Extension")
        XCTAssertEqual(ext.supportedMethods, ["apple_pay", "card"])
    }

    func testOnRegisterWithoutStripeKeyReturnsFalse() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        XCTAssertFalse(ext.onRegister(parameters: [:]))
    }

    func testOnRegisterWithEmptyStripeKeyReturnsFalse() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        XCTAssertFalse(ext.onRegister(parameters: ["stripeKey": ""]))
    }

    func testOnRegisterWithValidKeyReturnsTrue() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        XCTAssertTrue(ext.onRegister(parameters: ["stripeKey": "pk_test_123"]))
    }

    func testOnUnregisterNilsManager() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        XCTAssertTrue(ext.onRegister(parameters: ["stripeKey": "pk_test_123"]))
        // onUnregister should not throw and should leave extension in a usable state for re-registration
        ext.onUnregister()
        // After unregister, re-registration should still succeed
        XCTAssertTrue(ext.onRegister(parameters: ["stripeKey": "pk_test_456"]))
    }

    func testInitWithCustomCountryCode() {
        let ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test", countryCode: "AU")
        XCTAssertNotNil(ext)
    }
}

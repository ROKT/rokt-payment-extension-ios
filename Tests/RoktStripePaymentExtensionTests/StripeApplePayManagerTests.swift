import RoktContracts
import XCTest
@testable import RoktStripePaymentExtension

/// Tests that exercise validation paths inside StripeApplePayManager through the public facade.
/// Direct unit tests of StripeApplePayManager internal validation use presentPaymentSheet,
/// which surfaces failures synchronously through the completion handler when item is invalid.
final class StripeApplePayManagerTests: XCTestCase {

    private var ext: RoktStripePaymentExtension!

    override func setUp() {
        super.setUp()
        ext = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        ext.onRegister(parameters: ["stripeKey": "pk_test_dummy"])
    }

    // MARK: - Validation: empty name

    func testPresentPaymentSheetWithEmptyNameFails() {
        let item = PaymentItem(id: "item-1", name: "", amount: 9.99, currency: "USD")
        let expectation = expectation(description: "completion called")

        ext.presentPaymentSheet(
            item: item,
            method: .applePay,
            from: UIViewController(),
            preparePayment: { _, _ in fatalError("should not be called") }
        ) { result in
            XCTAssertEqual(result.outcome, .failed)
            XCTAssertNotNil(result.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Validation: empty id

    func testPresentPaymentSheetWithEmptyIdFails() {
        let item = PaymentItem(id: "", name: "Widget", amount: 9.99, currency: "USD")
        let expectation = expectation(description: "completion called")

        ext.presentPaymentSheet(
            item: item,
            method: .applePay,
            from: UIViewController(),
            preparePayment: { _, _ in fatalError("should not be called") }
        ) { result in
            XCTAssertEqual(result.outcome, .failed)
            XCTAssertNotNil(result.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Validation: zero amount

    func testPresentPaymentSheetWithZeroAmountFails() {
        let item = PaymentItem(id: "item-1", name: "Widget", amount: 0, currency: "USD")
        let expectation = expectation(description: "completion called")

        ext.presentPaymentSheet(
            item: item,
            method: .applePay,
            from: UIViewController(),
            preparePayment: { _, _ in fatalError("should not be called") }
        ) { result in
            XCTAssertEqual(result.outcome, .failed)
            XCTAssertNotNil(result.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Validation: empty currency

    func testPresentPaymentSheetWithEmptyCurrencyFails() {
        let item = PaymentItem(id: "item-1", name: "Widget", amount: 9.99, currency: "")
        let expectation = expectation(description: "completion called")

        ext.presentPaymentSheet(
            item: item,
            method: .applePay,
            from: UIViewController(),
            preparePayment: { _, _ in fatalError("should not be called") }
        ) { result in
            XCTAssertEqual(result.outcome, .failed)
            XCTAssertNotNil(result.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Validation: no manager (not registered)

    func testPresentPaymentSheetWithoutRegistrationFails() {
        let unregisteredExt = RoktStripePaymentExtension(applePayMerchantId: "merchant.test")!
        let item = PaymentItem(id: "item-1", name: "Widget", amount: 9.99, currency: "USD")
        let expectation = expectation(description: "completion called")

        unregisteredExt.presentPaymentSheet(
            item: item,
            method: .applePay,
            from: UIViewController(),
            preparePayment: { _, _ in fatalError("should not be called") }
        ) { result in
            XCTAssertEqual(result.outcome, .failed)
            XCTAssertNotNil(result.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

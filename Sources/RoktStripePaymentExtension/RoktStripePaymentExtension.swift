import Foundation
import PassKit
import RoktContracts
import StripeApplePay
import UIKit

public class RoktStripePaymentExtension: PaymentExtension {

    // MARK: - PaymentExtension Protocol Properties

    public let id: String = "rokt-stripe-payment-extension"
    public let extensionDescription: String = "Rokt Stripe Payment Extension"
    public let supportedMethods: [String] = [
        PaymentMethodType.applePay.wireValue,
        PaymentMethodType.card.wireValue
    ]

    // MARK: - Private Properties

    private let merchantId: String
    private let countryCode: String

    private var stripeApplePayManager: StripeApplePayManager?

    // MARK: - Initialization

    /// Initialize RoktStripePaymentExtension with an Apple Pay merchant identifier.
    ///
    /// - Parameters:
    ///   - applePayMerchantId: Apple Pay merchant identifier (must not be empty).
    ///   - countryCode: ISO 3166-1 alpha-2 country code for the payment (default: "US").
    /// - Returns: `nil` if `applePayMerchantId` is empty.
    public init?(
        applePayMerchantId: String,
        countryCode: String = "US"
    ) {
        guard !applePayMerchantId.isEmpty else { return nil }
        self.merchantId = applePayMerchantId
        self.countryCode = countryCode
    }

    // MARK: - PaymentExtension Protocol Implementation

    @discardableResult
    public func onRegister(parameters: [String: String]) -> Bool {
        guard let stripeKey = parameters["stripeKey"], !stripeKey.isEmpty else {
            return false
        }

        let apiClient = STPAPIClient(publishableKey: stripeKey)
        stripeApplePayManager = StripeApplePayManager(
            apiClient: apiClient,
            merchantId: merchantId,
            countryCode: countryCode
        )

        return true
    }

    public func onUnregister() {
        stripeApplePayManager = nil
    }

    public func presentPaymentSheet(
        item: PaymentItem,
        method: PaymentMethodType,
        from viewController: UIViewController,
        preparePayment: @escaping (
            _ address: ContactAddress,
            _ completion: @escaping (PaymentPreparation?, Error?) -> Void
        ) -> Void,
        completion: @escaping (PaymentSheetResult) -> Void
    ) {
        guard let stripeApplePayManager else {
            completion(.failed(error: "Apple Pay not configured. Call onRegister(parameters:) with a valid stripeKey first."))
            return
        }

        stripeApplePayManager.presentPayment(
            item: item,
            from: viewController,
            preparePayment: preparePayment,
            completion: completion
        )
    }
}

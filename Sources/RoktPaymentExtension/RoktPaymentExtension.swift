import Foundation
import PassKit
import RoktContracts
import StripeApplePay
import UIKit

/// Rokt payment extension backed by Stripe.
///
/// Currently supports Apple Pay and Afterpay/Clearpay via Stripe SDKs.
/// Partners provide what they want to support at init time:
/// - `applePayMerchantId` only  → Apple Pay (and card via Apple Pay sheet)
/// - `returnURL` only            → Afterpay
/// - Both                        → all three methods
///
/// Returns `nil` if neither `applePayMerchantId` nor `returnURL` is provided.
public class RoktPaymentExtension: PaymentExtension {

    // MARK: - PaymentExtension Protocol Properties

    public let id: String = "rokt-payment-extension"
    public let extensionDescription: String = "Rokt Payment Extension"

    /// Payment methods this extension supports, determined by which parameters
    /// were provided at initialization. Apple Pay / card require
    /// `applePayMerchantId`; Afterpay requires `returnURL`.
    public var supportedMethods: [String] {
        var methods: [String] = []
        if let merchantId, !merchantId.isEmpty {
            methods.append(PaymentMethodType.applePay.wireValue)
            methods.append(PaymentMethodType.card.wireValue)
        }
        if let returnURL, !returnURL.isEmpty {
            methods.append(PaymentMethodType.afterpay.wireValue)
        }
        return methods
    }

    // MARK: - Private Properties

    private let merchantId: String?
    private let countryCode: String
    private let returnURL: String?

    private var stripeApplePayManager: StripeApplePayManager?
    private var stripeAfterpayManager: StripeAfterpayManager?

    // MARK: - Initialization

    /// Initialize the Rokt payment extension.
    ///
    /// Supply `applePayMerchantId` to enable Apple Pay / card support.
    /// Supply `returnURL` to enable Afterpay (redirect-based). At least one of
    /// the two must be provided — otherwise the initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - applePayMerchantId: Apple Pay merchant identifier. Omit to disable Apple Pay.
    ///   - countryCode: ISO 3166-1 alpha-2 country code for the payment (default: "US").
    ///     Applies only to Apple Pay.
    ///   - returnURL: Custom URL scheme for redirect-based payment methods like Afterpay
    ///     (e.g. `"myapp://stripe-redirect"`). Omit to disable Afterpay.
    /// - Returns: `nil` if both `applePayMerchantId` and `returnURL` are omitted or empty.
    public init?(
        applePayMerchantId: String? = nil,
        countryCode: String = "US",
        returnURL: String? = nil
    ) {
        let hasApplePay = !(applePayMerchantId?.isEmpty ?? true)
        let hasAfterpay = !(returnURL?.isEmpty ?? true)
        guard hasApplePay || hasAfterpay else { return nil }

        self.merchantId = applePayMerchantId
        self.countryCode = countryCode
        self.returnURL = returnURL
    }

    // MARK: - PaymentExtension Protocol Implementation

    @discardableResult
    public func onRegister(parameters: [String: String]) -> Bool {
        guard let stripeKey = parameters["stripeKey"], !stripeKey.isEmpty else {
            return false
        }

        let apiClient = STPAPIClient(publishableKey: stripeKey)

        if let merchantId, !merchantId.isEmpty {
            stripeApplePayManager = StripeApplePayManager(
                apiClient: apiClient,
                merchantId: merchantId,
                countryCode: countryCode
            )
        }

        if let returnURL, !returnURL.isEmpty {
            stripeAfterpayManager = StripeAfterpayManager(
                apiClient: apiClient,
                returnURL: returnURL
            )
        }

        return true
    }

    public func onUnregister() {
        stripeApplePayManager = nil
        stripeAfterpayManager = nil
    }

    public func presentPaymentSheet(
        item: PaymentItem,
        method: PaymentMethodType,
        context: PaymentContext,
        from viewController: UIViewController,
        preparePayment: @escaping (
            _ address: ContactAddress,
            _ completion: @escaping (PaymentPreparation?, Error?) -> Void
        ) -> Void,
        completion: @escaping (PaymentSheetResult) -> Void
    ) {
        switch method {
        case .applePay, .card:
            guard let stripeApplePayManager else {
                completion(.failed(error: "Apple Pay not configured. Provide applePayMerchantId at init."))
                return
            }
            stripeApplePayManager.presentPayment(
                item: item,
                from: viewController,
                preparePayment: preparePayment,
                completion: completion
            )

        case .afterpay:
            guard let stripeAfterpayManager else {
                completion(.failed(error: "Afterpay not configured. Provide a returnURL at init."))
                return
            }
            stripeAfterpayManager.presentPayment(
                item: item,
                context: context,
                from: viewController,
                preparePayment: preparePayment,
                completion: completion
            )

        @unknown default:
            completion(.failed(error: "Unsupported payment method: \(method.wireValue)"))
        }
    }

    /// Forwards a redirect URL to Stripe so it can complete in-flight redirect-based
    /// flows (e.g. Afterpay). The Rokt SDK calls this after the host app receives a
    /// URL matching a registered extension's return URL scheme.
    public func handleURLCallback(with url: URL) -> Bool {
        StripeAPI.handleURLCallback(with: url)
    }
}

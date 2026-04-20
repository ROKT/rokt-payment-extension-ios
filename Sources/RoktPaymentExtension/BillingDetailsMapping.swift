import RoktContracts
import StripePayments

enum BillingDetailsMapping {
    /// Maps a ``ContactAddress`` to Stripe billing details for Afterpay payment method params.
    static func map(from address: ContactAddress) -> STPPaymentMethodBillingDetails {
        let billing = STPPaymentMethodBillingDetails()
        billing.name = address.name
        billing.email = address.email

        let stripeAddress = STPPaymentMethodAddress()
        stripeAddress.line1 = address.addressLine1
        stripeAddress.city = address.city
        stripeAddress.state = address.state
        stripeAddress.postalCode = address.postalCode
        stripeAddress.country = address.country
        billing.address = stripeAddress

        return billing
    }

    /// Maps a ``ContactAddress`` to Stripe shipping details for the PaymentIntent.
    static func mapShipping(from address: ContactAddress) -> STPPaymentIntentShippingDetailsParams {
        let shippingAddress = STPPaymentIntentShippingDetailsAddressParams(line1: address.addressLine1 ?? "")
        shippingAddress.city = address.city
        shippingAddress.state = address.state
        shippingAddress.postalCode = address.postalCode
        shippingAddress.country = address.country

        return STPPaymentIntentShippingDetailsParams(
            address: shippingAddress,
            name: address.name
        )
    }
}

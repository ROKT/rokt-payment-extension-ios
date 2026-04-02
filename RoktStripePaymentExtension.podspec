Pod::Spec.new do |s|
  s.name             = 'RoktStripePaymentExtension'
  s.version          = '0.1.2'
  s.summary          = 'Stripe payment extension for the Rokt SDK ecosystem.'
  s.swift_version    = '5.9'
  s.description      = <<-DESC
  Stripe payment integration for Rokt Shoppable Ads. Implements the PaymentExtension
  protocol from RoktContracts to provide Apple Pay support via Stripe.
                       DESC
  s.homepage         = 'https://github.com/ROKT/rokt-stripe-payment-extension-ios'
  s.license          = { :type => 'Rokt SDK Terms of Use 2.0', :file => 'LICENSE.md' }
  s.author           = { 'ROKT DEV' => 'nativeappsdev@rokt.com' }
  s.source           = { :git => 'https://github.com/ROKT/rokt-stripe-payment-extension-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.source_files = 'Sources/RoktStripePaymentExtension/**/*.swift'
  s.frameworks = 'Foundation', 'PassKit'
  s.dependency 'RoktContracts', '~> 0.1'
  s.dependency 'StripeApplePay', '~> 24.25'
end

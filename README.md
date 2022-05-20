# ApexMerchant
A multi-gateway payment processing library for Apex &amp; Salesforce / Force.com inspired by [ActiveMerchant](https://github.com/activemerchant/active_merchant) a ruby library for integrating with multiple payment processors.

This code was pulled from an AppExchange/ISV payments app I've been working on. I've poured a ton of time into developing a payments library that supports multiple payment gateways with a seamless/consistent API and so I thought I'd share with the community. This library will essentially enable you to add credit card, and bank payment processing to your Salesforce org, or app with just a few lines of code. The best part is that since the API is consistent across all gateways you can easily switch out payment providers without changing any code. This project is a work in progress, and I'll continue adding to it as we build our AppExchange app. My hope is that over time the community will contribute additional payment gateways to this library, and we'll all have a simple payments library for Salesforce. After all how many times have you developed ad-hoc payment integrations for your clients, or company?


## Usage
This simple example demonstrates how to process supported transactions using a person's credit card details.
```java
// Setup gateway options
Map<String, Object> options = new Map<String, Object> {
	'login' => 'sk_live_41Y6cbbMW9MQciBRf84hs84j',
	'password' => 'sk_test_RSylZfxqhm65G0yGh4jks94jf',
	'testMode' => 'true'
}

// Setup new instance of merchant passing in your gateway name (Stripe, AuthorizeDotNet, PayPal)
Merchant merchant = new Merchant('Stripe', options);

// Setup credit card payment source
Map<String, Object> source = new Map<String, Object> {
	'name' => 'Card',
	'firstName' => 'Charles',
	'lastName' => 'Naccio',
	'cardNumber' => '4444333322221111',
	'cvv' => '123',
	'month' => '12',
	'year' => '2017',
	'postalCode' => '75070'
};

// Amount to charge in cents i.e. $1.00 = 100 cents
Integer amount = 100;

// Merchant transaction actions
merchant.purchase(amount, source);
Map<String, Object> reference = merchant.authorize(amount, source).reference;
merchant.capture(amount, reference);
merchant.void(reference);
merchant.refund(amount, reference);
merchant.credit(amount, source);
reference = merchant.store(source).reference;
merchant.unstore(reference);
```

## Gateway Methods
The main methods implemented by gateways are:
- `verify()` - Verify connection with payment gateway
- `purchase(amount, paymentSource, [options])` - Capture, and authorize in one transaction
- `authorize(amount, paymentSource, [options])` - Authorize payment for capturing later
- `capture(amount, reference, [options])` - Capture a previously authorized payment
- `void(reference, [options])` - Void a previous transaction
- `refund(amount, reference, [options])` - Refund a previous transaction
- `credit(amount, source, [options])` - Credit an amount to the supplied credit card
- `store(paymentSource, [options])` - Store credit card with payment provider for future use
- `unstore(reference, [options])` - Remove/delete previously stored payment method from payment provider

## Supported Payment Gateways
- [Stripe](https://stripe.com/)
- [Authorize.Net](http://www.authorize.net/)
- [PayPal](https://developer.paypal.com)
- More to come...


## Contribute a New Gateway
I'll include better instructions in the future, but for now you can simply clone one of the existing payment gateway classes, for instance `merchant_Gateway_Stripe` as `merchant_Gateway_YourMerchantName`, and make needed changes. The code is commented fairly well so this should be enough to get you started.


## Contact & Feedback
Feel free to reach out with any questions or feedback via email at cnaccio@gmail.com, or charles@workless.io. Thanks, and enjoy!

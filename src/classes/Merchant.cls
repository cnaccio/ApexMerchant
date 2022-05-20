/**
* @author Charles Naccio
* @date 8/28/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Merchant class will act as a factory/library class to provide a thin
* layer of syntactic sugar to simplify the use of the Merchant library. 
*/
public with sharing class Merchant {
	
	/*******************************************************************************************************
	* @description Gateway for current Merchant instance
	*/
	public merchant_Gateway gateway;

	/*******************************************************************************************************
	* @description Payment source for current Merchant instance
	*/
	public merchant_Source source;

	/*******************************************************************************************************
	* @description Gateway transaction response from the latest transaction. If no transaction has been run
	* response will be null.
	*/
	public merchant_Response response;

	/*******************************************************************************************************
	* @description Merchant exception used when a generic error is caused anywhere in the merchant library.
	*/
	public class ApplicationException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant configuration exception used when an error is caused by invalid configuration
	*/
	public class ConfigurationException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant unsupported gateway exception used when an attempt to use an unsupported 
	* gateway.
	*/
	public class UnsupportedGatewayException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant unsupported payment source exception used when an attempt to use an unsupported 
	* payment source.
	*/
	public class UnsupportedPaymentSourceException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant unsupported transaction exception used when an attempt is made to use any 
	* unsupported, but standard gateway transaction. For instance stripe does not support the standard credit
	* transaction, and therefore if an attempt is made to use the credit transaction this exception will be 
	* thrown.
	*/
	public class UnsupportedTransactionException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant required option missing exception used when validating required options for any
	* method inside the merchant library.
	*/
	public class RequiredOptionMissingException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant gateway connection exception used when an error occurs while connecting to a 
	* payment gateway.
	*/
	public class GatewayConnectionException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant invalid response exception used when an error occurs while parsing the HTTP
	* response from a gateway transaction.
	*/
	public class InvalidResponseException extends Exception {}

	/*******************************************************************************************************
	* @description Merchant invalid parameter value exception used when an invalid parameter value is passed
	* to any merchant methods.
	*/
	public class InvalidParameterValueException extends Exception {}

	/*******************************************************************************************************
	* @description Initialize new merchant library instance
	* @param The gateway name to prep/setup for use
	* @param Map of gateway options
	* @example
	*
	* // Long example
	* Merchant merchant = new Merchant();
	*
	* // Setup gateway
	* merchant.createGateway('Stripe', options);
	* merchant.gateway.set(options); // Configure more/other gateway options; view gateway.allOptions property
	* for a list of configurable options
	*
	* // Verify gateway connection
	* if (merchant.verify()) {
	* 	System.debug('Gateway verified!');
	* }
	* 
	* // Typical
	* Merchant merchant = new Merchant('Stripe', options);
	*
	* // Setup payment source
	* Map<String, Object> source = new Map<String, Object> {
	* 	'name' => 'Card',
	* 	'firstName' => 'Charles',
	* 	'lastName' => 'Naccio',
	* 	'cardNumber' => '4444333322221111',
	* 	'cvv' => '123',
	* 	'month' => '12',
	* 	'year' => '2017',
	* 	'postalCode' => '75070'
	* };
	*
	* // Merchant transaction actions
	* merchant.purchase(100, source);
	* Map<String, Object> reference = merchant.authorize(100, source).reference;
	* merchant.capture(100, reference);
	* merchant.void(new Map<String, Object> {'name' => 'Reference', 'reference' => reference});
	* merchant.refund(100, reference);
	* merchant.credit(100, source);
	* reference = merchant.store(source).reference;
	* merchant.unstore(reference);
	* 
	* // Setup transaction options
	* Map<String, Object> options = new Map<String, Object> {
	*	'orderId' => '#9934532'	
	* }
	*
	* // Merchant transaction actions
	* merchant.purchase(100, source, options);
	* merchant.authorize(100, source, options);
	* reference = merchant.capture(100, source, options).reference;
	* merchant.void(source, reference);
	* merchant.refund(100, reference, options);
	* merchant.credit(100, source, options);
	* reference = merchant.store(source, options).reference;
	* merchant.unstore(reference, options);
	*/
	public Merchant() {
		// Do something
	}
	public Merchant(String name, Map<String, Object> options) {
		this.createGateway(name, options);
	}

	/*******************************************************************************************************
	* @description Create dynamic gateway instance by name
	* @param Gateway name
	* @param Gateway options
	* @example
	* Merchant merchant = new Merchant();
	* merchant.createGateway('Stripe', options);
	*/
	public void createGateway(String name, Map<String, Object> options) {
		if (String.isBlank(name)) {
			String errorMsg = 'Gateway name cannot be blank, must be one of (Stripe, Braintree, etc...).';
			throw new Merchant.InvalidParameterValueException(errorMsg);
		}
		Type gatewayType = Type.forName('merchant_Gateway_' + name);
		if(gatewayType == null) {
			String[] errorMsg = new String[] {
				'"' + name + '" is not a currently supported gateway. Please use one of the',
				'supported gateways such as (Stripe, Braintree, etc...).'
			};
			throw new Merchant.UnsupportedGatewayException(String.join(errorMsg, ' '));
		}
		this.gateway = (merchant_Gateway)gatewayType.newInstance();
		this.gateway.validateRequiredOptions(options);
		this.gateway.set(options);
	}

	/*******************************************************************************************************
	* @description Create dynamic payment source instance by name
	* @param Payment source name
	* @param Payment source options
	* @example
	* Merchant merchant = new Merchant();
	* merchant.createSource('Card', source);
	*/
	public void createSource(String name, Map<String, Object> source) {
		if (String.isBlank(name)) {
			String errorMsg = 'Source name cannot be blank, must be one of (Card, Bank, Token, or Reference).';
			throw new Merchant.InvalidParameterValueException(errorMsg);
		}
		Type sourceType = Type.forName('merchant_Source_' + name);
		if(sourceType == null) {
			String[] errorMsg = new String[] {
				'"' + name + '" is not a currently supported payment source. Please use one of the',
				'supported payment sources such as (Card, Bank, Token, or Reference).'
			};
			throw new Merchant.UnsupportedPaymentSourceException(String.join(errorMsg, ' '));
		}
		this.source = (merchant_Source)sourceType.newInstance();
		this.source.set(source);
		this.source.validateRequiredOptions(source);
	}

	/*******************************************************************************************************
	* @description Create dynamic transaction options
	* @param Transaction options
	* @example
	* Merchant merchant = new Merchant();
	* merchant.createTransactionOptions(options);
	*/
	public merchant_TransactionOptions createTransactionOptions(Map<String, Object> options) {
		merchant_TransactionOptions transactionOptions = new merchant_TransactionOptions();
		transactionOptions.set(options);
		return transactionOptions;
	}

	/*******************************************************************************************************
	* @description Check that merchant is properly setup to begin completing transactions
	* @param Need to check source as well
	* @example
	* Merchant merchant = new Merchant();
	* merchant.check();
	*/
	public void check(Boolean source) {
		this.checkGateway();
		if (source) this.checkSource();
	}

	/*******************************************************************************************************
	* @description Check that gateway is properly setup
	* @example
	* Merchant merchant = new Merchant();
	* merchant.checkGateway();
	*/
	public void checkGateway() {
		if (this.gateway == null) {
			String[] errorMsg = new String[] {
				'Gateway not setup. Please setup a gateway by calling',
				'Merchant.createGateway(\'GatewayName\') before attempting a transaction.'
			};
			throw new Merchant.ApplicationException(String.join(errorMsg, ' '));
		}
	}

	/*******************************************************************************************************
	* @description Check that source is properly setup
	* @example
	* Merchant merchant = new Merchant();
	* merchant.checkSource();
	*/
	public void checkSource() {
		if (this.source == null) {
			String errorMsg = 'Source not setup. Please setup a source before making a purchase.';
			throw new Merchant.ApplicationException(errorMsg);
		}
	}

	/*******************************************************************************************************
	* @description Verify gateway connectivity/readiness
	* @return True if interaction with gateway was successful; otherwise false.
	* @example
	* Boolean gatewayVerified = gateway.verify();
	*/
	public Boolean verify() {
		this.check(false);
		return this.gateway.verify();
	}

	/*******************************************************************************************************
	* @description Complete a purchase
	* @param Purchase amount
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.purchase(100, source);
	*/
	public merchant_Response purchase(Integer amount, Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.purchase(amount, this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a purchase
	* @param Purchase amount
	* @param Payment source
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.purchase(100, source, options);
	*/
	public merchant_Response purchase(Integer amount, Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.purchase(amount, this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a authorize
	* @param Authorize amount
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.authorize(100, source);
	*/
	public merchant_Response authorize(Integer amount, Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.authorize(amount, this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a authorize
	* @param Authorize amount
	* @param Payment source
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.authorize(100, source, options);
	*/
	public merchant_Response authorize(Integer amount, Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.authorize(amount, this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a capture
	* @param Capture amount
	* @param Previous authorization reference
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.capture(100, source);
	*/
	public merchant_Response capture(Integer amount, Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.capture(amount, this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a capture
	* @param Capture amount
	* @param Previous authorization reference
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.capture(100, source, options);
	*/
	public merchant_Response capture(Integer amount, Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.capture(amount, this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a void
	* @param Previous purchase, or authorization reference
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.void(source);
	*/
	public merchant_Response void(Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.void(this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a void
	* @param Previous purchase, or authorization reference
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.void(source, options);
	*/
	public merchant_Response void(Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.void(this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a refund
	* @param Refund amount
	* @param Previous authorization or purchase reference
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.refund(100, source);
	*/
	public merchant_Response refund(Integer amount, Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.refund(amount, this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a refund
	* @param Refund amount
	* @param Previous authorization or purchase reference
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.refund(100, source, options);
	*/
	public merchant_Response refund(Integer amount, Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.refund(amount, this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a credit
	* @param Credit amount
	* @param Payment source
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.credit(100, source);
	*/
	public merchant_Response credit(Integer amount, Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.credit(amount, this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a credit
	* @param Credit amount
	* @param Payment source
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.credit(100, source, options);
	*/
	public merchant_Response credit(Integer amount, Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.credit(amount, this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a store
	* @param Payment source
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.store(source);
	*/
	public merchant_Response store(Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.store(this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a store
	* @param Payment source
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.store(source, options);
	*/
	public merchant_Response store(Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.store(this.source, this.createTransactionOptions(options));
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a unstore
	* @param Payment source
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source);
	*/
	public merchant_Response unstore(Map<String, Object> source) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.unstore(this.source, new merchant_TransactionOptions());
		return this.response;
	}

	/*******************************************************************************************************
	* @description Complete a unstore
	* @param Payment source
	* @param Transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source, options);
	*/
	public merchant_Response unstore(Map<String, Object> source, Map<String, Object> options) {
		this.createSource((String)source.get('name'), source);
		this.check(true);
		this.response = this.gateway.unstore(this.source, this.createTransactionOptions(options));
		return this.response;
	}
}
/**
* @author Charles Naccio
* @date 8/26/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Stripe Gateway class, extended from the base Gateway class, handles all implementation
* details for payment processing using the Stripe gateway.
*/
public with sharing class merchant_Gateway_Stripe extends merchant_Gateway implements merchant_IGateway {

	/*******************************************************************************************************
	* @description Supported card type label to card type key mapping.
	*/
	private Map<String, String> supportedCardTypesMap;

	/*******************************************************************************************************
	* @description Gateway request endpoint to transaction action mapping
	*/
	private Map<String, Map<String, String>> transactionEndpointsMap;

	/*******************************************************************************************************
	* @description Standard response codes mapping. 
	*/
	private Map<String, String> standardResponseCodesMap;

	/*******************************************************************************************************
	* @description Different gateways handle test mode differently so the base gateway class treats
	* testMode as a string. For this gateway test mode is a boolean value so this is just a little helper
	* property.
	*/
	private Boolean inTestMode {
		get {
			return Boolean.valueOf(this.testMode);
		}
		set;
	}

	/*******************************************************************************************************
	* @description Gateway API URL
	*/
	private String apiURL {
		get {
			return (this.inTestMode ? this.testUrl : this.liveUrl);
		}
	}

	/*******************************************************************************************************
	* @description Gateway API key
	*/
	private String apiKey {
		get {
			return (this.inTestMode ? this.password : this.login);
		}
	}

	/*******************************************************************************************************
	* @description Payment source used for gateway verification.
	*/
	private merchant_Source verificationSource;

	/*******************************************************************************************************
	* @description Transaction options used for gateway verification.
	*/
	private merchant_TransactionOptions verificationOptions;

	/*******************************************************************************************************
	* @description Initialize new gateway instance
	* @example
	* merchant_Gateway_Stripe gateway = new merchant_Gateway_Stripe();
	*/
	public merchant_Gateway_Stripe() {
		
		// Set standard gateway options
		this.name = 'Stripe';
		this.displayName = 'Stripe Payments';
		this.testUrl = 'https://api.stripe.com/v1';
		this.liveUrl = 'https://api.stripe.com/v1';
		this.homepageUrl = 'http://www.stripe.com';
		this.defaultCurrency = 'USD';
		this.supportedPaymentSources = new Set<String> {
			'Card',
			'Reference',
			'Token'
		};
		this.supportedTransactions = new Set<String> {
			'purchase',
			'authorize',
			'capture',
			'void',
			'refund',
			'store',
			'unstore'
		};
		this.supportedCardTypesMap = new Map<String, String> {
			'Visa' => 'VISA',
			'Master Card' => 'MASTER',
			'Discover' => 'DISCOVER',
			'American Express' => 'AMERICAN',
			'Diners Club' => 'DINERS',
			'JCB' => 'JCB'
		};
		this.supportedCardTypes = this.supportedCardTypesMap.keySet();
		this.supportedCountries = new Set<String> {
			'AT',
			'AU',
			'BE',
			'CA',
			'CH',
			'DE',
			'DK',
			'ES',
			'FI',
			'FR',
			'GB',
			'IE',
			'IT',
			'LU',
			'NL',
			'NO',
			'SE',
			'US'
		};
		this.requiredOptions = new Set<String> {
			'login'
		};
		this.standardResponseCodesMap = new Map<String, String> {
	        'success' => this.standardResponseCodes.get('success'),
	        'authentication_error' => this.standardResponseCodes.get('authentication_error'),
	        'incorrect_number' => this.standardResponseCodes.get('incorrect_number'),
	        'invalid_number' => this.standardResponseCodes.get('invalid_number'),
	        'invalid_expiry_month' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'invalid_expiry_year' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'invalid_cvc' => this.standardResponseCodes.get('invalid_cvc'),
	        'expired_card' => this.standardResponseCodes.get('expired_card'),
	        'incorrect_cvc' => this.standardResponseCodes.get('incorrect_cvc'),
	        'incorrect_zip' => this.standardResponseCodes.get('incorrect_zip'),
	        'incorrect_pin' => this.standardResponseCodes.get('incorrect_pin'),
	        'card_declined' => this.standardResponseCodes.get('card_declined'),
	        'processing_error' => this.standardResponseCodes.get('processing_error'),
	        'invalid_request_error' => this.standardResponseCodes.get('invalid_request_error'),
	        'call_issuer' => this.standardResponseCodes.get('call_issuer'),
	        'expired_auth' => this.standardResponseCodes.get('expired_auth')
      	};

      	// Setup transaction endpoints mapping
		this.transactionEndpointsMap = new Map<String, Map<String, String>> {
			'purchase' => new Map<String, String> {
				'url' => '/charges',
				'method' => 'POST'	
			},
			'authorize' => new Map<String, String> {
				'url' => '/charges',
				'method' => 'POST'	
			},
			'capture' => new Map<String, String> {
				'url' => '/charges',
				'method' => 'POST'	
			},
			'void' => new Map<String, String> {
				'url' => '/refunds',
				'method' => 'POST'	
			},
			'refund' => new Map<String, String> {
				'url' => '/refunds',
				'method' => 'POST'	
			},
			'store' => new Map<String, String> {
				'url' => '/customers',
				'method' => 'POST'	
			},
			'unstore' => new Map<String, String> {
				'url' => '/customers',
				'method' => 'DELETE'	
			}
		};

		// Setup verification source, and options
		this.verificationSource = new merchant_Source_Card();
		this.verificationOptions = new merchant_TransactionOptions();
		this.verificationSource.set(new Map<String, Object> {
			'name' => 'Card',
			'firstName' => 'John',
			'lastName' => 'Doe',
			'cardNumber' => '4242424242424242',
			'cvv' => '123',
			'month' => String.valueOf(Date.today().month()),
			'year' => String.valueOf(Date.today().year()),
			'postalCode' => '75070'
		});
	}

	/*******************************************************************************************************
	* @description Verify gateway connectivity/readiness
	* @return True if interaction with gateway was successful; otherwise false.
	* @example
	* Boolean gatewayVerified = gateway.verify();
	*/
	public override Boolean verify() {
		
		// Default verification to false
		Boolean verified = false;
		merchant_Response authResponse = this.authorize(100, this.verificationSource, this.verificationOptions);

		// Account for test mode
		if(this.inTestMode) {
			
			// In test mode the authorize transaction should succeed since we're using a stripe test card
			if(authResponse.success) {
				merchant_Source_Reference reference;
				reference = new merchant_Source_Reference(String.valueOf(authResponse.reference));
				merchant_Response voidResponse = this.void(reference, this.verificationOptions);
				verified = voidResponse.success;
			}
		} else {
			
			// In live mode the authorize transaction should fail with a card declined error code due to
			// using a test/fake card. If the api key is invalid you'll receive an invalid request error
			// mentioning the api key is bad.
			if(authResponse.code == 'card_declined') {
				verified = true;
			}
		}

		// Return verification results
		return verified;
	}

	/*******************************************************************************************************
	* @description Complete a purchase
	* @param Purchase amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.purchase(100, source, options);
	*/
	public override merchant_Response purchase(
		Integer amount,
		merchant_Source source,
		merchant_TransactionOptions options
	) {

		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object> {
			'amount' => String.valueOf(amount),
			'capture' => 'true'
		};

		// Add payment source
		this.addSource('purchase', parameters, source);

		// Add transaction options
		this.addOptions('purchase', parameters, options);

		// Send the transaction with parameters
		return this.request('purchase', parameters);
	}

	/*******************************************************************************************************
	* @description Complete a authorize
	* @param Authorize amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.authorize(100, source, options);
	*/
	public override merchant_Response authorize(
		Integer amount,
		merchant_Source source,
		merchant_TransactionOptions options
	) {
		
		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object> {
			'amount' => String.valueOf(amount),
			'capture' => 'false'
		};

		// Add payment source
		this.addSource('authorize', parameters, source);

		// Add transaction options
		this.addOptions('authorize', parameters, options);

		// Send the transaction with parameters
		return this.request('authorize', parameters);
	}

	/*******************************************************************************************************
	* @description Complete a capture
	* @param Capture amount
	* @param Previous authorization reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.capture(100, source, options);
	*/
	public override merchant_Response capture(
		Integer amount,
		merchant_Source source,
		merchant_TransactionOptions options
	) {
		
		// First ensure reference payment source
		if (!(source instanceof merchant_Source_Reference)) {
			throw new Merchant.UnsupportedPaymentSourceException(
				'Please use a "Reference" payment source to use Stripe\'s "Capture" functionality.'
			);
		}

		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object> {
			'amount' => String.valueOf(amount)
		};

		// Add payment source
		this.addSource('capture', parameters, source);

		// Add transaction options
		this.addOptions('capture', parameters, options);

		// Send the transaction with parameters
		return this.request('capture', parameters);
	}

	/*******************************************************************************************************
	* @description Complete a void
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.void(source, options);
	*/
	public override merchant_Response void(merchant_Source source, merchant_TransactionOptions options) {
		
		// First ensure reference payment source
		if (!(source instanceof merchant_Source_Reference)) {
			throw new Merchant.UnsupportedPaymentSourceException(
				'Please use a "Reference" payment source to use Stripe\'s "Void" functionality.'
			);
		}

		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object>();

		// Add payment source
		this.addSource('void', parameters, source);

		// Add transaction options
		this.addOptions('void', parameters, options);

		// Send the transaction with parameters
		return this.request('void', parameters);
	}

	/*******************************************************************************************************
	* @description Complete a refund
	* @param Refund amount
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.refund(100, source, options);
	*/
	public override merchant_Response refund(
		Integer amount,
		merchant_Source source,
		merchant_TransactionOptions options
	) {
		
		// First ensure reference payment source
		if (!(source instanceof merchant_Source_Reference)) {
			throw new Merchant.UnsupportedPaymentSourceException(
				'Please use a "Reference" payment source to use Stripe\'s "Refund" functionality.'
			);
		}

		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object> {
			'amount' => String.valueOf(amount)
		};

		// Add payment source
		this.addSource('refund', parameters, source);

		// Add transaction options
		this.addOptions('refund', parameters, options);

		// Send the transaction with parameters
		return this.request('refund', parameters);
	}

	/*******************************************************************************************************
	* @description Complete a credit
	* @param Credit amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.credit(100, source, options);
	*/
	public override merchant_Response credit(
		Integer amount,
		merchant_Source source,
		merchant_TransactionOptions options
	) {
		String[] errorMsg = new String[]{};
		errorMsg.add('"' + this.displayName + '" does not support "credit" transactions.');
		errorMsg.add('If you\'re trying to complete a refund use the "refund" transaction.');
		throw new Merchant.UnsupportedTransactionException(String.join(errorMsg, ' '));
		return null;
	}

	/*******************************************************************************************************
	* @description Complete a store which currently creates a new customer, and source. This method is not
	* yet intelligent enough to store a new source on an existing customer. This should probably be
	* revisited in the future.
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.store(source, options);
	*/
	public override merchant_Response store(merchant_Source source, merchant_TransactionOptions options) {
		
		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object>();

		// Add payment source
		this.addSource('store', parameters, source);

		// Add transaction options
		this.addOptions('store', parameters, options);

		// Send the transaction with parameters
		return this.request('store', parameters);
	}

	/*******************************************************************************************************
	* @description Complete an unstore which deletes a previously stored card from a previous customer.
	* Please note that if we delete the last source from a customer the customer still remains.
	* @param Token payment source which for stripe is in the following format; customerId::sourceId
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source, options);
	*/
	public override merchant_Response unstore(merchant_Source source, merchant_TransactionOptions options) {
		
		// First ensure token payment source
		if (!(source instanceof merchant_Source_Token)) {
			throw new Merchant.UnsupportedPaymentSourceException(
				'Please use a "Token" payment source to use Stripe\'s "Unstore" functionality.'
			);
		}

		// Create transaction parameters map with simple parameters
		Map<String, Object> parameters = New Map<String, Object>();

		// Add payment source
		this.addSource('unstore', parameters, source);
		
		// Send the transaction with parameters
		return this.request('unstore', parameters);
	}

	/*******************************************************************************************************
	* @description Add payment source to transaction parameters by parsing the source object/parameter
	* @param Parameters map to populate with payment source
	* @param The payment source to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* gateway.addSource('purchase', parameters, source);
	*/
	private void addSource(String action, Map<String, Object> parameters, merchant_Source source) {
		if (source instanceof merchant_Source_Card) {
			this.addSourceCard(action, parameters, (merchant_Source_Card)source);
		} else if (source instanceof merchant_Source_Bank) {
			
			// Bank (ach or echeck) payments are not currently supported
			String[] errorMsg = new String[] {
				'"' + this.name + '" does not support "bank" (ach or echeck) payments. Please use one of the',
				'supported payment sources such as (Card, Token, or Reference).'
			};
			throw new Merchant.UnsupportedPaymentSourceException(String.join(errorMsg, ' '));
		} else if (source instanceof merchant_Source_Token) {
			this.addSourceToken(action, parameters, (merchant_Source_Token)source);
		} else if (source instanceof merchant_Source_Reference) {
			this.addSourceReference(action, parameters, (merchant_Source_Reference)source);
		}
	}

	/*******************************************************************************************************
	* @description Add card payment source to transaction parameters by parsing the source object/parameter
	* @param Parameters map to populate with payment source
	* @param The card payment source to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* gateway.addSourceCard('purchase', parameters, source);
	*/
	private void addSourceCard(String action, Map<String, Object> parameters, merchant_Source_Card source) {
		Map<String, Object> cardSource = new Map<String, Object> {
			'object' => source.name.toLowerCase(),
			'number' => source.cardNumber,
			'exp_month' => source.month,
			'exp_year' => source.year,
			'cvc' => source.cvv,
			'name' => source.fullName,
			'address_line1' => source.address1,
			'address_line2' => source.address2,
			'address_city' => source.city,
			'address_state' => source.state,
			'address_zip' => source.postalCode,
			'address_country' => source.country
		};
		parameters.put('source', cardSource);
	}

	/*******************************************************************************************************
	* @description Add reference payment source to transaction parameters by parsing the source object/parameter
	* @param Parameters map to populate with payment source
	* @param The reference payment source to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* gateway.addSourceReference('purchase', parameters, source);
	*/
	private void addSourceReference(String action, Map<String, Object> parameters, merchant_Source_Reference source) {
		if (action == 'capture') {
			parameters.put('reference', source.reference);
		} else if (action == 'void' || action == 'refund') {
			parameters.put('charge', source.reference);
		}
	}

	/*******************************************************************************************************
	* @description Add token payment source to transaction parameters by parsing the source object/parameter
	* @param Parameters map to populate with payment source
	* @param The token payment source to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* gateway.addSourceToken('purchase', parameters, source);
	*/
	private void addSourceToken(String action, Map<String, Object> parameters, merchant_Source_Token source) {
		List<String> tokenSource = source.token.split('::');
		if (tokenSource.size() > 1) {
			parameters.put('customer', tokenSource.get(0));
			parameters.put('source', tokenSource.get(1));
		} else {
			throw new Merchant.InvalidParameterValueException(
				'"Unstore" token of "' + source.token + '" is invalid. Please ensure your ' +
				'token is in the following format: "customerId::sourceId", and try again.'
			);
		}
	}

	/*******************************************************************************************************
	* @description Add transaction options to transaction parameters by parsing the options parameter
	* @param Gateway transaction action
	* @param Parameters map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptions('purchase', parameters, options);
	*/
	private void addOptions(String action, Map<String, Object> parameters, merchant_TransactionOptions options) {
		if (action == 'purchase') this.addOptionsPurchase(parameters, options);
		if (action == 'authorize') this.addOptionsPurchase(parameters, options);
		if (action == 'capture') this.addOptionsCapture(parameters, options);
		if (action == 'void') this.addOptionsRefund(parameters, options);
		if (action == 'refund') this.addOptionsRefund(parameters, options);
		if (action == 'store') this.addOptionsStore(parameters, options);
	}

	/*******************************************************************************************************
	* @description Add purchase transaction options to transaction parameters by parsing the options parameter
	* @param Parameters map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptionsPurchase(parameters, options);
	*/
	private void addOptionsPurchase(Map<String, Object> parameters, merchant_TransactionOptions options) {
		
		// Add basic transaction options
		parameters.put('currency', (options.currencie == null ? this.defaultCurrency : options.currencie));
		if (options.customer != null) parameters.put('customer', options.customer);
		if (options.description != null) parameters.put('description', options.description);
		if (options.statementDescription != null) {
			parameters.put('statement_descriptor', this.statementDescription(options.statementDescription));
		}
		if (options.email != null) parameters.put('receipt_email', options.email);

		// Add transaction metadata
		Map<String, Object> metadata = new Map<String, Object>();
		if (options.orderId != null) metadata.put('order_id', options.orderId);
		if (options.ip != null) metadata.put('ip', options.ip);
		if (options.invoice != null) metadata.put('invoice', options.invoice);
		parameters.put('metadata', metadata);

		// Add transaction shipping details
		Map<String, Object> shipping = new Map<String, Object>();
		if (options.shippingName != null || options.shippingCompany != null) {
			String name = options.shippingName;
			if (String.isEmpty(name)) {
				name = options.shippingCompany;
			} else {
				name = options.shippingCompany + ' attn: ' + options.shippingName;
			}
			shipping.put('name', name);
		}
		if (options.shippingCarrier != null) shipping.put('carrier', options.shippingCarrier);
		if (options.shippingPhone != null) shipping.put('phone', options.shippingPhone);
		if (options.shippingTrackingNumber != null) shipping.put('tracking_number', options.shippingTrackingNumber);

		// Add shipping address
		Map<String, Object> shippingAddress = new Map<String, Object>();
		if (options.shippingAddress1 != null) shippingAddress.put('line1', options.shippingAddress1);
		if (options.shippingAddress2 != null) shippingAddress.put('line2', options.shippingAddress2);
		if (options.shippingCity != null) shippingAddress.put('city', options.shippingCity);
		if (options.shippingState != null) shippingAddress.put('state', options.shippingState);
		if (options.shippingPostalCode != null) shippingAddress.put('postal_code', options.shippingPostalCode);
		if (options.shippingCountry != null) shippingAddress.put('country', options.shippingCountry);
		shipping.put('address', shippingAddress);

		// Add shipping details, and address to shipping parameter
		parameters.put('shipping', shipping);

		// Add "connect" options
		if (options.merchant != null) parameters.put('destination', options.merchant);
		if (options.merchantFee != null) parameters.put('application_fee', options.merchantFee);
	}

	/*******************************************************************************************************
	* @description Add capture transaction options to transaction parameters by parsing the options parameter
	* @param Parameters map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptionsCapture(parameters, options);
	*/
	private void addOptionsCapture(Map<String, Object> parameters, merchant_TransactionOptions options) {
		
		// Add basic transaction options
		if (options.statementDescription != null) {
			parameters.put('statement_descriptor', this.statementDescription(options.statementDescription));
		}
		if (options.email != null) parameters.put('receipt_email', options.email);

		// Add "connect" options
		if (options.merchantFee != null) parameters.put('application_fee', options.merchantFee);
	}

	/*******************************************************************************************************
	* @description Add refund transaction options to transaction parameters by parsing the options parameter
	* @param Parameters map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptionsRefund(parameters, options);
	*/
	private void addOptionsRefund(Map<String, Object> parameters, merchant_TransactionOptions options) {

		// Add basic refund transaction options
		if (options.reason != null) parameters.put('reason', options.reason);

		// Add transaction metadata
		Map<String, Object> metadata = new Map<String, Object>();
		if (options.orderId != null) metadata.put('order_id', options.orderId);
		if (options.ip != null) metadata.put('ip', options.ip);
		if (options.invoice != null) metadata.put('invoice', options.invoice);
		parameters.put('metadata', metadata);

		// Add "connect" options
		if (options.refundMerchantFee != null) parameters.put('refund_application_fee', options.refundMerchantFee);
		if (options.reverseMerchant != null) parameters.put('reverse_transfer', options.reverseMerchant);
	}

	/*******************************************************************************************************
	* @description Add store transaction options to transaction parameters by parsing the options parameter
	* @param Parameters map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> parameters = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptionsStore(parameters, options);
	*/
	private void addOptionsStore(Map<String, Object> parameters, merchant_TransactionOptions options) {

		// Add basic refund transaction options
		if (options.description != null) parameters.put('description', options.description);
		if (options.email != null) parameters.put('email', options.email);
	}

	/*******************************************************************************************************
	* @description Commit gateway transaction request
	* @param Gateway transaction action
	* @param Transaction parameters
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.request(action, parameters);
	*/
	public override merchant_Response request(String action, Map<String, Object> parameters) {

		// Set the API endpoint for use with this request		
		String endpoint = this.endpoint(action, parameters);

		// Set the API request method (POST, GET, PUT, etc...)
		String method = this.transactionEndpointsMap.get(action).get('method');

		// Setup API authentication credentials
		merchant_Request.HttpCredentials credentials;
		credentials = new merchant_Request.HttpCredentials('Bearer', this.apiKey);

		// Setup request http content
		String payload = this.payload(action, parameters);
		merchant_Request.HttpContent content;
		
		// Some actions require no payload/content so we're explicitly handling such actions below.
		if(String.isNotBlank(payload)) {
			content = new merchant_Request.HttpContent('application/x-www-form-urlencoded', payload);
		} else if (action == 'unstore') {
			content = new merchant_Request.HttpContent('application/x-www-form-urlencoded');
		}
		
		// Create and execute merchant request
		merchant_Request request = new merchant_Request(credentials, endpoint, method, content, action);

		// Return standard merchant response object
		return this.response(action, request.execute());
	}

	/*******************************************************************************************************
	 * Convenience Methods
	 */

	/*******************************************************************************************************
	* @description Convenience method for formatting a statement description
	* @param Unformatted statement description
	* @return Return formatted statement description
	* @example
	* String statementDescriptor = 'Purchase for concert tickets';
	* statementDescriptor= gateway.statementDescription(statementDescriptor);
	*/
	private String statementDescription(String unformattedStatementDescription) {
		String formattedStatementDescription = unformattedStatementDescription;
		formattedStatementDescription = formattedStatementDescription.remove('<');
		formattedStatementDescription = formattedStatementDescription.remove('>');
		formattedStatementDescription = formattedStatementDescription.remove('"');
		formattedStatementDescription = formattedStatementDescription.remove('\'');
		formattedStatementDescription = formattedStatementDescription.abbreviate(22);
		formattedStatementDescription = formattedStatementDescription.toUpperCase();
		return formattedStatementDescription;
	}

	/*******************************************************************************************************
	* @description Convenience method building an API endpoint
	* @param Gateway transaction action
	* @param Optional parameters
	* @return Fully built API endpoint URL
	* @example
	* String endpoint = gateway.endpoint('purchase', null);
	*/
	private String endpoint(String action, Map<String, Object> parameters) {
		String endpoint = null;
		endpoint = this.apiURL + this.transactionEndpointsMap.get(action).get('url');
		if (action == 'capture' && parameters.containsKey('reference')) {
			endpoint += '/' + parameters.get('reference') + '/capture';

			// Remove parameters that we're referencing in the url above. 
			parameters.remove('reference');
		}
		if (action == 'unstore' && parameters.containsKey('customer')) {
			endpoint += '/' + parameters.get('customer') + '/sources/' + parameters.get('source'); 
			
			// Remove parameters that we're referencing in the url above.
			parameters.remove('customer');
			parameters.remove('source');
		}
		return endpoint;
	}

	/*******************************************************************************************************
	* @description Convenience method for building the HTTP request payload
	* @param Gateway transaction action
	* @param Transaction parameters
	* @return Return stringified payload
	* @example
	* HttpRequest request = new HttpRequest();
	* String payload = gateway.payload('purchase', parameters);
	* request.setBody(payload);
	*/
	private String payload(String action, Map<String, Object> parameters) {

		// Build request body/payload
		String payload = '';
		for (String key : parameters.keySet()) {

			// Check for string value
			if (parameters.get(key) instanceof String) {
				payload += (EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(
					String.valueOf(parameters.get(key)), 'UTF-8') + '&'
				);
			}

			// Check for map nested value
			if (parameters.get(key) instanceof Map<String, Object>) {
				
				// Create sub options handle
				Map<String, Object> subOptions = (Map<String, Object>)parameters.get(key);
				
				// Loop through sub options
				for (String subKey : subOptions.keySet()) {

					// Check for map nested, nested value
					if (subOptions.get(subKey) instanceof Map<String, Object>) {

						// Create sub, sub options handle
						Map<String, Object> subSubOptions = (Map<String, Object>)subOptions.get(subKey);

						// Loop through sub, sub options
						for (String subSubKey : subSubOptions.keySet()) {
							payload += (
								EncodingUtil.urlEncode(key + '[' + subKey + ']' + '[' + subSubKey + ']', 'UTF-8') +
								'=' +
								EncodingUtil.urlEncode(String.valueOf(subSubOptions.get(subSubKey)), 'UTF-8') +
								'&'
							);
						}						
					}

					// Check for string nested value
					if (subOptions.get(subKey) instanceof String) {
						payload += (
							EncodingUtil.urlEncode(key + '[' + subKey + ']', 'UTF-8') +
							'=' +
							EncodingUtil.urlEncode(String.valueOf(subOptions.get(subKey)), 'UTF-8') +
							'&'
						);
					}
				}
			}
		}

		// Return payload
		return payload;
	}

	/*******************************************************************************************************
	* @description Convenience method for parsing HTTP responses
	* @param Gateway transaction action
	* @param HTTP response body
	* @return Generic map of parsed response data
	* @example
	* HttpResponse response = http.send(request);
	* Map<String, Object> data = gateway.parse('purchase', response.getBody());
	*/
	private Map<String, Object> parse(String action, String body) {
		Map<String, Object> parsed = new Map<String, Object>();
		try {
			parsed = (Map<String, Object>)JSON.deserializeUntyped(body);
		} catch(Exception e) {
			
			// Debug invalid response exception
			System.debug('\n**** INVALID RESPONSE EXCEPTION:\n' + e);

			// Throw invalid response exception
			String[] errorMsg = new String[] {};
			errorMsg.add('Invalid response received from gateway while attempting a "' + action + '" transaction.');
			errorMsg.add('\nProblem details: ' + e.getMessage());
			errorMsg.add('\nResponse body: ' + body);
			throw new Merchant.InvalidResponseException(String.join(errorMsg, ' '), e);
		}
		return parsed;
	}

	/*******************************************************************************************************
	* @description Convenience method for getting the transaction request/response code
	* @param Gateway transaction action
	* @param Parsed HTTP response body
	* @return A response code
	* @example
	* String code = gateway.code('purchase', parsedResponse);
	*/
	private String code(String action, Map<String, Object> parsedResponse) {
		String code = null;
		if (parsedResponse.containsKey('error')) {
			Map<String, Object> error = (Map<String, Object>)parsedResponse.get('error');
			String declineCode = null;
			if (error.get('code') != null) code = String.valueOf(error.get('code'));
			if (code == 'card_declined') declineCode = String.valueOf(error.get('decline_code'));
			if (code == null && error.get('type') != null) code = String.valueOf(error.get('type'));
			code = standardResponseCodesMap.get(declineCode) != null ?
				   standardResponseCodesMap.get(declineCode) :
				   standardResponseCodesMap.get(code);

		   // Default error
		   if (code == null) code = 'invalid_request_error';
		} else {
			code = this.standardResponseCodesMap.get('success');
		}
		return code;
	}

	/*******************************************************************************************************
	* @description Convenience method for getting the message details from gateway to supplement standard
	* response messages
	* @param Gateway transaction action
	* @param Parsed HTTP response body
	* @return A response message details
	* @example
	* String details = gateway.details('purchase', parsedResponse);
	*/
	private String details(String action, Map<String, Object> parsedResponse) {
		String details = null;
		if (parsedResponse.containsKey('error')) {
			Map<String, Object> error = (Map<String, Object>)parsedResponse.get('error');
			details = String.valueOf(error.get('message'));
		} else {
			details = 'The ' + action + ' transaction completed successfully';
		}
		return details;
	}

	/*******************************************************************************************************
	* @description Convenience method for obtaining the gateway transaction reference
	* @param Gateway transaction action
	* @param Parsed HTTP response body
	* @return A transaction reference
	* @example
	* String reference = gateway.message('purchase', parsedResponse);
	*/
	private String reference(String action, Map<String, Object> parsedResponse) {
		String reference = null;
		if (parsedResponse.containsKey('error')) {
			Map<String, Object> error = (Map<String, Object>)parsedResponse.get('error');
			if (error.containsKey('charge')) reference = String.valueOf(error.get('charge'));
		}
		if (parsedResponse.get('object') == 'charge') {
			reference = String.valueOf(parsedResponse.get('id'));
		}
		if (parsedResponse.get('object') == 'refund') {
			reference = String.valueOf(parsedResponse.get('id'));
		}
		if (parsedResponse.get('object') == 'customer') {

			// Get sources
			Map<String, Object> sources = (Map<String, Object>)parsedResponse.get('sources');

			// Get source data
			List<Object> datas = (List<Object>)sources.get('data');

			// Get first, and only source reference
			if (datas.get(0) != null) {
				Map<String, Object> source = (Map<String, Object>)datas.get(0);

				List<String> stripeReference = new List<String> {
				
					// Customer reference
					String.valueOf(parsedResponse.get('id')),
					
					// Card reference
					String.valueOf(source.get('id'))
				};
				reference = String.join(stripeReference, '::');
			}
		}
		if (parsedResponse.get('object') == 'card') {
			List<String> stripeReference = new List<String> {
				
				// Customer reference
				String.valueOf(parsedResponse.get('customer')),
				
				// Card reference
				String.valueOf(parsedResponse.get('id'))
			};
			reference = String.join(stripeReference, '::');
		}
		
		// Catch all reference; stripe typically returns an id on every transaction
		if (String.isBlank(reference) && String.isNotBlank(String.valueOf(parsedResponse.get('id')))) {
			reference = String.valueOf(parsedResponse.get('id'));
		}
		return reference;
	}

	/*******************************************************************************************************
	* @description Convenience method for building the standard gateway transaction response
	* @param Gateway transaction action
	* @param Parsed gateway transaction response
	* @return A standard gateway transaction response object
	* @example
	* merchant_Response response = gateway.response('purchase', response);
	*/
	private merchant_Response response(String action, HttpResponse response) {
		
		// Grab http response body which can be later parsed
		String body = response.getBody();

		// First let's parse the response
		Map<String, Object> parsedResponse = this.parse(action, body);

		// Figure out if the request was successful
		Boolean success = parsedResponse.containsKey('error') ? false : true;

		// Get request/response code
		String code = this.code(action, parsedResponse);

		// Get request/response message
		String message = this.standardResponseMessages.get(code);

		// Get request/response message details
		String details = this.details(action, parsedResponse);

		// Get transaction reference
		String reference = this.reference(action, parsedResponse);

		// Return standard response
		return new merchant_Response(success, code, message, details, body, reference);
	}
}
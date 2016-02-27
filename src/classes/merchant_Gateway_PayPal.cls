/**
* @author Charles Naccio
* @date 2/26/2016
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The PayPal Gateway class, extended from the base Gateway class, handles all
* implementation details for payment processing using the PayPal gateway.
*/
public with sharing class merchant_Gateway_PayPal extends merchant_Gateway implements merchant_IGateway {

	/*******************************************************************************************************
	* @description Supported card type label to card type key mapping.
	*/
	private Map<String, String> supportedCardTypesMap;

	/*******************************************************************************************************
	* @description Supported bank account type label to account type key mapping.
	*/
	private Map<String, String> supportedBankAccountTypesMap;

	/*******************************************************************************************************
	* @description Gateway request endpoint to transaction action mapping
	*/
	private Map<String, Map<String, String>> transactionEndpointsMap;

	/*******************************************************************************************************
	* @description Gateway transaction to transaction request transaction type mapping.
	*/
	private Map<String, String> transactionRequestTypesMap;

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
	* @description Standard response codes mapping. 
	*/
	private Map<String, String> standardResponseCodesMap;

	/**
	 * Gateway API Request Classes
	 */

	// Do something

	/**
	 * Gateway API Response Classes
	 */

	// Do something

	/**
	 * Gateway Constructor/Methods
	 */

	/*******************************************************************************************************
	* @description Initialize new gateway instance
	* @example
	* merchant_Gateway_PayPal gateway = new merchant_Gateway_PayPal();
	*/
	public merchant_Gateway_PayPal() {
		
		// Set standard gateway options
		this.name = 'PayPal';
		this.displayName = 'PayPal';
		this.testUrl = 'https://api.sandbox.paypal.com';
		this.liveUrl = 'https://api.paypal.com';
		this.homepageUrl = 'http://www.paypal';
		this.defaultCurrency = 'USD';
		this.supportedPaymentSources = new Set<String> {
			'Card',
			'Bank',
			'Reference',
			'Token'
		};
		this.supportedTransactions = new Set<String> {
			TRANSACTION_VERIFY,
			TRANSACTION_PURCHASE,
			TRANSACTION_AUTHORIZE,
			TRANSACTION_CAPTURE,
			TRANSACTION_VOID,
			TRANSACTION_REFUND,
			TRANSACTION_CREDIT,
			TRANSACTION_STORE,
			TRANSACTION_UNSTORE
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
		this.supportedBankAccountTypesMap = new Map<String, String> {
			'Checking' => 'checking',
			'Savings' => 'savings',
			'Business Checking' => 'businessChecking'
		};
		this.supportedBankAccountTypes = this.supportedBankAccountTypesMap.keySet();
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
			'login',
			'password'
		};
		this.standardResponseCodesMap = new Map<String, String> {
	        
	        // Standard codes
	        'success' => this.standardResponseCodes.get('success'),
			'authentication_error' => this.standardResponseCodes.get('authentication_error'),
			'incorrect_number' => this.standardResponseCodes.get('incorrect_number'),
			'incorrect_account_info' => this.standardResponseCodes.get('incorrect_account_info'),
			'incorrect_routing_number' => this.standardResponseCodes.get('incorrect_routing_number'),
	        'incorrect_account_number' => this.standardResponseCodes.get('incorrect_account_number'),
	        'incorrect_check_number' => this.standardResponseCodes.get('incorrect_check_number'),
	        'invalid_number' => this.standardResponseCodes.get('invalid_number'),
	        'invalid_account_info' => this.standardResponseCodes.get('invalid_account_info'),
	        'invalid_routing_number' => this.standardResponseCodes.get('invalid_routing_number'),
	        'invalid_account_number' => this.standardResponseCodes.get('invalid_account_number'),
	        'invalid_check_number' => this.standardResponseCodes.get('invalid_check_number'),
	        'invalid_expiry_date' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'invalid_cvc' => this.standardResponseCodes.get('invalid_cvc'),
	        'expired_card' => this.standardResponseCodes.get('expired_card'),
	        'incorrect_cvc' => this.standardResponseCodes.get('incorrect_cvc'),
	        'incorrect_zip' => this.standardResponseCodes.get('incorrect_zip'),
	        'incorrect_address' => this.standardResponseCodes.get('incorrect_address'),
	        'incorrect_pin' => this.standardResponseCodes.get('incorrect_pin'),
	        'card_declined' => this.standardResponseCodes.get('card_declined'),
	        'processing_error' => this.standardResponseCodes.get('processing_error'),
	        'invalid_request_error' => this.standardResponseCodes.get('invalid_request_error'),
	        'call_issuer' => this.standardResponseCodes.get('call_issuer'),
	        'pickup_card' => this.standardResponseCodes.get('pickup_card'),
	        'expired_auth' => this.standardResponseCodes.get('expired_auth'),
	        'held_for_review' => this.standardResponseCodes.get('held_for_review')
      	};

      	// Setup transaction endpoints mapping
		this.transactionEndpointsMap = new Map<String, Map<String, String>> {
			'verify' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'
			},
			'purchase' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'authorize' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'capture' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'void' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'refund' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'credit' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'store' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'	
			},
			'unstore' => new Map<String, String> {
				'url' => '',
				'method' => 'POST'
			}
		};

		// Setup gateway transaction to transaction request transaction type mapping
		this.transactionRequestTypesMap = new Map<String, String> {
			TRANSACTION_PURCHASE => 'authCaptureTransaction',
			TRANSACTION_AUTHORIZE => 'authOnlyTransaction',
			TRANSACTION_CAPTURE => 'priorAuthCaptureTransaction',
			TRANSACTION_VOID => 'voidTransaction',			
			TRANSACTION_REFUND => 'refundTransaction',
			TRANSACTION_CREDIT => 'refundTransaction'
		};
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

		// Build request
		//AuthenticateTestRequest authenticationTestRequest = new AuthenticateTestRequest();

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_VERIFY => authenticationTestRequest
		//};

		//// Process request
		//merchant_Response authenticationTestResponse = this.request(TRANSACTION_VERIFY, body);

		//// Confirm successful request
		//verified = authenticationTestResponse.success;

		// Return verification result
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

		// Build request
		//CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		//createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
		//	TRANSACTION_PURCHASE
		//);
		//createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_PURCHASE => createTransactionRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_PURCHASE, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_PURCHASE, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_PURCHASE, body);
		return null;
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
		
		// Build request
		//CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		//createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
		//	TRANSACTION_AUTHORIZE
		//);
		//createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_AUTHORIZE => createTransactionRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_AUTHORIZE, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_AUTHORIZE, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_AUTHORIZE, body);
		return null;
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
				'Please use a "Reference" payment source to use PayPal\'s "Capture" functionality.'
			);
		}

		// Build request
		//CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		//createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
		//	TRANSACTION_CAPTURE
		//);
		//createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_CAPTURE => createTransactionRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_CAPTURE, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_CAPTURE, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_CAPTURE, body);
		return  null;
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
				'Please use a "Reference" payment source to use PayPal\'s "Void" functionality.'
			);
		}

		// Build request
		//CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		//createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
		//	TRANSACTION_VOID
		//);

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_VOID => createTransactionRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_VOID, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_VOID, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_VOID, body);
		return null;
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
				'Please use a "Reference" payment source to use PayPal\'s "Refund" functionality.'
			);
		}

		// Build request
		//CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		//createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
		//	TRANSACTION_REFUND
		//);
		//createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_REFUND => createTransactionRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_REFUND, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_REFUND, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_REFUND, body);
		return null;
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
		
		// Build request
		//CreateCustomerProfileRequest createCustomerProfileRequest = new CreateCustomerProfileRequest();

		// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_STORE => createCustomerProfileRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_STORE, body, source);

		//// Add transaction options
		//this.addOptions(TRANSACTION_STORE, body, options);

		//// Send the transaction with body
		//return this.request(TRANSACTION_STORE, body);
		return null;
	}

	/*******************************************************************************************************
	* @description Complete an unstore which deletes a previously stored card from a previous customer.
	* Please note that if we delete the last source from a customer the customer still remains.
	* @param Token payment source which for paypal is in the following format; customerId::sourceId
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source, options);
	*/
	public override merchant_Response unstore(merchant_Source source, merchant_TransactionOptions options) {
		
		// First ensure token payment source
		//if (!(source instanceof merchant_Source_Token)) {
		//	throw new Merchant.UnsupportedPaymentSourceException(
		//		'Please use a "Token" payment source to use PayPal\'s "Unstore" functionality.'
		//	);
		//}

		//// Build request
		//DeleteCustomerProfileRequest deleteCustomerProfileRequest = new DeleteCustomerProfileRequest();

		//// Add request to body
		//Map<String, Object> body = new Map<String, Object> {
		//	TRANSACTION_UNSTORE => deleteCustomerProfileRequest
		//};

		//// Add payment source
		//this.addSource(TRANSACTION_UNSTORE, body, source);

		//// Send the transaction with body
		//return this.request(TRANSACTION_UNSTORE, body);
		return null;
	}

	///*******************************************************************************************************
	//* @description Add payment source to transaction body by parsing the source object/parameter
	//* @param Request body to populate with payment source
	//* @param The payment source to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* gateway.addSource('purchase', body, source);
	//*/
	//private void addSource(String action, Map<String, Object> body, merchant_Source source) {
	//	if (source instanceof merchant_Source_Card) {
	//		this.addSourceCard(action, body, (merchant_Source_Card)source);
	//	} else if (source instanceof merchant_Source_Bank) {
	//		this.addSourceBank(action, body, (merchant_Source_Bank)source);
	//	} else if (source instanceof merchant_Source_Token) {
	//		this.addSourceToken(action, body, (merchant_Source_Token)source);
	//	} else if (source instanceof merchant_Source_Reference) {
	//		this.addSourceReference(action, body, (merchant_Source_Reference)source);
	//	}
	//}

	///*******************************************************************************************************
	//* @description Add card payment source to transaction body by parsing the source object/parameter
	//* @param Request body map to populate with payment source
	//* @param The card payment source to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* gateway.addSourceCard('purchase', body, source);
	//*/
	//private void addSourceCard(String action, Map<String, Object> body, merchant_Source_Card source) {
		
	//	// Handle create customer profile requests
	//	if(action == TRANSACTION_STORE) {
			
	//		// Create customer profile request handle
	//		CreateCustomerProfileRequest createCustomerProfileRequest = (
	//			(CreateCustomerProfileRequest)body.get(action)
	//		);

	//		// Create new customer profile
	//		Profile customerProfile = new Profile();
	//		customerProfile.paymentProfiles = new PaymentProfiles();

	//		// Create new credit card
	//		CreditCard creditCard = new CreditCard(source);

	//		// Create new payment from credit card
	//		Payment payment = new Payment(creditCard);

	//		// Create new bill to
	//		BillTo billTo = new BillTo(source);

	//		// Add bill to to customer payment profiles
	//		customerProfile.paymentProfiles.billTo = billTo;

	//		// Add payment to customer payment profiles
	//		customerProfile.paymentProfiles.payment = payment;
			
	//		// Add customer profile to request
	//		createCustomerProfileRequest.profile = customerProfile;
	//	} else {

	//		// Create transaction request handle
	//		CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

	//		// Create new credit card
	//		CreditCard creditCard = new CreditCard(source);

	//		// Create new payment from credit card
	//		Payment payment = new Payment(creditCard);

	//		// Create new bill to
	//		BillTo billTo = new BillTo(source);

	//		// Add payment to request
	//		createTransactionRequest.transactionRequest.payment = payment;

	//		// Add bill to address to request
	//		createTransactionRequest.transactionRequest.billTo = billTo;
	//	}
	//}

	///*******************************************************************************************************
	//* @description Add bank payment source to transaction body by parsing the source object/parameter
	//* @param Request body map to populate with payment source
	//* @param The bank payment source to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* gateway.addSourceBank('purchase', body, source);
	//*/
	//private void addSourceBank(String action, Map<String, Object> body, merchant_Source_Bank source) {
		
	//	// Handle create customer profile requests
	//	if(action == TRANSACTION_STORE) {
			
	//		// Create customer profile request handle
	//		CreateCustomerProfileRequest createCustomerProfileRequest = (
	//			(CreateCustomerProfileRequest)body.get(action)
	//		);

	//		// Create new customer profile
	//		Profile customerProfile = new Profile();
	//		customerProfile.paymentProfiles = new PaymentProfiles();

	//		// Create new bank account
	//		BankAccount bankAccount = new BankAccount(source);

	//		// Convert bank account type from label to key
	//		bankAccount.accountType = this.supportedBankAccountTypesMap.get(bankAccount.accountType);

	//		// Figure out echeck type.
	//		// Reference Below:
	//		// https://www.paypal/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm
	//		if(bankAccount.accountType == BANK_ACCOUNT_TYPE_BUSINESS_CHECKING) {
	//			bankAccount.echeckType = ECHECK_TYPE_CCD;
	//		} else {
	//			bankAccount.echeckType = ECHECK_TYPE_PPD;
	//		}

	//		// Create new payment from bank account
	//		Payment payment = new Payment(bankAccount);

	//		// Add payment to customer payment profiles
	//		customerProfile.paymentProfiles.payment = payment;
			
	//		// Add customer profile to request
	//		createCustomerProfileRequest.profile = customerProfile;
	//	} else {

	//		// Create transaction request handle
	//		CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

	//		// Create new bank account
	//		BankAccount bankAccount = new BankAccount(source);

	//		// Convert bank account type from label to key
	//		bankAccount.accountType = this.supportedBankAccountTypesMap.get(bankAccount.accountType);

	//		// Figure out echeck type.
	//		// Reference Below:
	//		// https://www.paypal/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm
	//		if(bankAccount.accountType == BANK_ACCOUNT_TYPE_BUSINESS_CHECKING) {
	//			bankAccount.echeckType = ECHECK_TYPE_CCD;
	//		} else if (action == TRANSACTION_REFUND) {
	//			bankAccount.echeckType = ECHECK_TYPE_PPD;
	//		} else {
	//			bankAccount.echeckType = DEFAULT_ECHECK_TYPE;
	//		}

	//		// Create new payment from bank account
	//		Payment payment = new Payment(bankAccount);

	//		// Add payment to request
	//		createTransactionRequest.transactionRequest.payment = payment;
	//	}
	//}

	///*******************************************************************************************************
	//* @description Add reference payment source to transaction body by parsing the source object/parameter
	//* @param Parameters map to populate with payment source
	//* @param The reference payment source to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* gateway.addSourceReference('authorize', body, source);
	//*/
	//private void addSourceReference(String action, Map<String, Object> body, merchant_Source_Reference source) {
		
	//	// TODO: Refactor the code below to store reference as JSON instead of just a :: delimited string

	//	// Create transaction request handle
	//	CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

	//	// Parse reference
	//	String refTransId;
	//	String accountNumber;
	//	String expirationDate;
	//	String accountType;
	//	String routingNumber;
	//	String nameOnAccount;
	//	String bankName;
	//	Boolean isCardSource = true;
	//	if(source.reference.contains('::')) {
	//		List<String> referenceParts = source.reference.split('::');
	//		if (referenceParts.size() > 0) refTransId = referenceParts[0];
	//		if (referenceParts.size() > 1) accountNumber = referenceParts[1];
	//		if (referenceParts.size() > 5) {
	//			accountType = referenceParts[2];
	//			routingNumber = referenceParts[3];
	//			nameOnAccount = referenceParts[4];
	//			bankName = referenceParts[5];

	//			// If more than 5 reference parts exists then this is definitely a bank payment source
	//			isCardSource = false;
	//		} else if (referenceParts.size() > 2) {
	//			expirationDate = referenceParts[2];
	//		}
	//	} else {
	//		refTransId = source.reference;
	//	}

	//	// Add transaction reference id
	//	createTransactionRequest.transactionRequest.refTransId = refTransId;

	//	// Add payment for refunds
	//	if(action == TRANSACTION_REFUND && String.isNotBlank(accountNumber)) {
	//		Payment payment;
	//		if(isCardSource) {
				
	//			// Create new credit card
	//			CreditCard creditCard = new CreditCard();
	//			creditCard.cardNumber = accountNumber;
	//			creditCard.expirationDate = expirationDate;

	//			// Create new payment from credit card
	//			payment = new Payment(creditCard);
	//		} else {

	//			// Create new bank account
	//			BankAccount bankAccount = new BankAccount();
	//			bankAccount.accountType = accountType;
	//			bankAccount.routingNumber = routingNumber;
	//			bankAccount.accountNumber = accountNumber;
	//			bankAccount.nameOnAccount = nameOnAccount;
	//			bankAccount.bankName = bankName;

	//			// PPD seems to be required for bank refunds
	//			bankAccount.echeckType = ECHECK_TYPE_PPD;

	//			// Create new payment from bank account
	//			payment = new Payment(bankAccount);
	//		}

	//		// Add payment to request
	//		createTransactionRequest.transactionRequest.payment = payment;
	//	}
	//}

	///*******************************************************************************************************
	//* @description Add token payment source to transaction body by parsing the source object/parameter
	//* @param body map to populate with payment source
	//* @param The token payment source to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* gateway.addSourceToken('purchase', body, source);
	//*/
	//private void addSourceToken(String action, Map<String, Object> body, merchant_Source_Token source) {
		
	//	// Create delete customer profile request handle
	//	DeleteCustomerProfileRequest deleteCustomerProfileRequest = (
	//		(DeleteCustomerProfileRequest)body.get(action)
	//	);
	//	deleteCustomerProfileRequest.customerProfileId = source.token;
	//}

	///*******************************************************************************************************
	//* @description Add transaction options to transaction body by parsing the options parameter
	//* @param Gateway transaction action
	//* @param body map to populate with transaction options
	//* @param The options parameter to parse
	//* @example
	//* Map<String, Object> body = new Map<String, Object>();
	//* merchant_TransactionOptions options = new merchant_TransactionOptions();
	//* gateway.addOptions('purchase', body, options);
	//*/
	//private void addOptions(String action, Map<String, Object> body, merchant_TransactionOptions options) {
		
	//	// Handle create customer profile requests
	//	if(action == TRANSACTION_STORE) {

	//		// Create customer profile request handle
	//		CreateCustomerProfileRequest createCustomerProfileRequest = (
	//			(CreateCustomerProfileRequest)body.get(action)
	//		);

	//		// Add merchant assigned id
	//		createCustomerProfileRequest.profile.merchantCustomerId = options.customer;

	//		// Add description
	//		createCustomerProfileRequest.profile.description = options.description;

	//		// Add customer email
	//		createCustomerProfileRequest.profile.email = options.email;

	//		// At least one of the fields above must be filled in otherwise the store request will fail
	//		if(
	//			String.isBlank(options.customer) &&
	//			String.isBlank(options.description) &&
	//			String.isBlank(options.email)
	//		) {
				
	//			// Set merchant customer id using reference id
	//			createCustomerProfileRequest.profile.merchantCustomerId = createCustomerProfileRequest.refId;
	//		}

	//		// Add bill to options
	//		createCustomerProfileRequest.profile.paymentProfiles.billTo.addOptions(options);

	//		// Add ship to options
	//		ShipTo shipTo = new ShipTo(options);
	//		createCustomerProfileRequest.profile.shipToList.add(shipTo);
	//	} else {

	//		// Create transaction request handle
	//		CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);
			
	//		// Add order options
	//		Order order = new Order(options);
	//		createTransactionRequest.transactionRequest.order = order;

	//		// Add customer options
	//		Customer customer = new Customer(options);
	//		createTransactionRequest.transactionRequest.customer = customer;

	//		// Add bill to options
	//		createTransactionRequest.transactionRequest.billTo.addOptions(options);

	//		// Add ship to options
	//		ShipTo shipTo = new ShipTo(options);
	//		createTransactionRequest.transactionRequest.shipTo = shipTo;
	//	}
	//}

	/******************************************************************************************************
	* @description Commit gateway transaction request
	* @param Gateway transaction action
	* @param Gateway http request body
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.request(action, body);
	*/
	public override merchant_Response request(String action, Map<String, Object> body) {

		// Set the API endpoint for use with this request		
		//String endpoint = this.endpoint(action, body);

		//// Set the API request method (POST, GET, PUT, etc...)
		//String method = this.transactionEndpointsMap.get(action).get('method');

		//// API credentials are added to the request payload; adding dummy credentials for emphasis.
		//merchant_Request.HttpCredentials credentials;
		//credentials = new merchant_Request.HttpCredentials('payload', 'payload');

		//// Setup http request payload
		//String payload = this.payload(action, body);
		
		//// Setup request http content with the above generated payload
		//merchant_Request.HttpContent content = new merchant_Request.HttpContent('application/json', payload);
		
		//// Create and execute merchant request
		//merchant_Request request = new merchant_Request(credentials, endpoint, method, content, action);

		//// Return standard merchant response object
		//return this.response(action, body, request.execute());
		return null;
	}

	///*******************************************************************************************************
	// * Convenience Methods
	// */


	// /*******************************************************************************************************
	// * @description Get given amount in cents in dollars
	// * @param Amount in cents
	// * @return Amount converted to dollars
	// * @example
	// * Decimal dollarAmount = gateway.getDollarAmount(100);
	// */
	// private Decimal getDollarAmount(Integer amount) {
	// 	return (
	//		(amount != null && amount != 0) ?
	//		amount / 100 :
	//		0.00
	//	);
	// }

	///*******************************************************************************************************
	//* @description Convenience method for formatting a statement description
	//* @param Unformatted statement description
	//* @return Return formatted statement description
	//* @example
	//* String statementDescriptor = 'Purchase for concert tickets';
	//* statementDescriptor= gateway.statementDescription(statementDescriptor);
	//*/
	//private String statementDescription(String unformattedStatementDescription) {
	//	String formattedStatementDescription = unformattedStatementDescription;
	//	formattedStatementDescription = formattedStatementDescription.remove('<');
	//	formattedStatementDescription = formattedStatementDescription.remove('>');
	//	formattedStatementDescription = formattedStatementDescription.remove('"');
	//	formattedStatementDescription = formattedStatementDescription.remove('\'');
	//	formattedStatementDescription = formattedStatementDescription.abbreviate(22);
	//	formattedStatementDescription = formattedStatementDescription.toUpperCase();
	//	return formattedStatementDescription;
	//}

	///*******************************************************************************************************
	//* @description Convenience method building an API endpoint
	//* @param Gateway transaction action
	//* @param Gateway http request body; optional.
	//* @return Fully built API endpoint URL
	//* @example
	//* String endpoint = gateway.endpoint('purchase', null);
	//*/
	//private String endpoint(String action, Map<String, Object> body) {
	//	String endpoint = null;
	//	endpoint = this.apiURL + this.transactionEndpointsMap.get(action).get('url');
	//	return endpoint;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for building the HTTP request payload
	//* @param Gateway transaction action
	//* @param Gateway http request body
	//* @return Return stringified payload
	//* @example
	//* HttpRequest request = new HttpRequest();
	//* String payload = gateway.payload('purchase', body);
	//* request.setBody(payload);
	//*/
	//private String payload(String action, Map<String, Object> body) {

	//	// Build request body/payload
	//	String payload = '';
		
	//	// Setup gateway/merchant authentication as all transactions require authentication
	//	MerchantAuthentication merchantAuthentication;
	//	merchantAuthentication = new MerchantAuthentication(this.login,	this.password);

	//	// Handle each transaction action
	//	if(action == TRANSACTION_VERIFY) {

	//		// Grab/Cast transaction request
	//		AuthenticateTestRequest authenticationTestRequest;
	//		authenticationTestRequest = (AuthenticateTestRequest)body.get(TRANSACTION_VERIFY);

	//		// Add request authentication
	//		authenticationTestRequest.merchantAuthentication = merchantAuthentication;

	//		// Get payload
	//		payload = authenticationTestRequest.serialize();
	//	} else if (action == TRANSACTION_STORE) {

	//		// Grab/Cast create customer profile request
	//		CreateCustomerProfileRequest createCustomerProfileRequest;
	//		createCustomerProfileRequest = (CreateCustomerProfileRequest)body.get(action);

	//		// Add request authentication
	//		createCustomerProfileRequest.merchantAuthentication = merchantAuthentication;

	//		// Get payload
	//		payload = createCustomerProfileRequest.serialize();
	//	} else if (action == TRANSACTION_UNSTORE) {

	//		// Grab/Cast delete customer profile request
	//		DeleteCustomerProfileRequest deleteCustomerProfileRequest;
	//		deleteCustomerProfileRequest = (DeleteCustomerProfileRequest)body.get(action);

	//		// Add request authentication
	//		deleteCustomerProfileRequest.merchantAuthentication = merchantAuthentication;

	//		// Get payload
	//		payload = deleteCustomerProfileRequest.serialize();
	//	} else {

	//		// Grab/Cast transaction request
	//		CreateTransactionRequest createTransactionRequest;
	//		createTransactionRequest = (CreateTransactionRequest)body.get(action);

	//		// Add request authentication
	//		createTransactionRequest.merchantAuthentication = merchantAuthentication;

	//		// Get payload
	//		payload = createTransactionRequest.serialize();
	//	}

	//	// Return payload
	//	return payload;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for parsing HTTP responses
	//* @param Gateway transaction action
	//* @param HTTP response body
	//* @return Generic map of parsed response data
	//* @example
	//* HttpResponse response = http.send(request);
	//* Map<String, Object> data = gateway.parse('purchase', response.getBody());
	//*/
	//private Map<String, Object> parse(String action, String body) {
	//	Map<String, Object> parsed = new Map<String, Object>();
	//	try {
			
	//		// Remove 'ZERO WIDTH NO-BREAK SPACE' Unicode character if present
	//		if(body.codePointAt(0) == 65279) {
	//			body = body.replace('\uFEFF', '');
	//		}

	//		// Deserialize response into a generic map for easily working with the data
	//		parsed = (Map<String, Object>)JSON.deserializeUntyped(body);
			
	//		/**
	//		 * Deserialize Various Responses
	//		 */

	//		// Handle verify transactions
	//		if(action == TRANSACTION_VERIFY) {
	//			AuthenticateTestResponse authenticationTestResponse;
	//			authenticationTestResponse = (AuthenticateTestResponse)JSON.deserialize(
	//				body,
	//				merchant_Gateway_PayPal.AuthenticateTestResponse.class
	//			);
	//			parsed.put('messages', authenticationTestResponse.messages);
	//		}

	//		// Handle store transactions
	//		else if (action == TRANSACTION_STORE) {
	//			CreateCustomerProfileResponse createCustomerProfileResponse;
	//			createCustomerProfileResponse = (CreateCustomerProfileResponse)JSON.deserialize(
	//				body,
	//				merchant_Gateway_PayPal.CreateCustomerProfileResponse.class
	//			);
	//			parsed.put('messages', createCustomerProfileResponse.messages);
	//		}

	//		// Handle unstore transactions
	//		else if (action == TRANSACTION_UNSTORE) {
	//			DeleteCustomerProfileResponse deleteCustomerProfileResponse;
	//			deleteCustomerProfileResponse = (DeleteCustomerProfileResponse)JSON.deserialize(
	//				body,
	//				merchant_Gateway_PayPal.DeleteCustomerProfileResponse.class
	//			);
	//			parsed.put('messages', deleteCustomerProfileResponse.messages);
	//		}

	//		// Handle all other payment transactions
	//		else {
	//			CreateTransactionResponse createTransactionResponse;
	//			createTransactionResponse = (CreateTransactionResponse)JSON.deserialize(
	//				body,
	//				merchant_Gateway_PayPal.CreateTransactionResponse.class
	//			);
	//			parsed.put('messages', createTransactionResponse.messages);
	//			parsed.put('transactionResponse', createTransactionResponse.transactionResponse);
	//		}
	//	} catch(Exception e) {
			
	//		// Debug invalid response exception
	//		System.debug('\n**** INVALID RESPONSE EXCEPTION:\n' + e);

	//		// Throw invalid response exception
	//		String[] errorMsg = new String[] {};
	//		errorMsg.add('Invalid response received from gateway while attempting a "' + action + '" transaction.');
	//		errorMsg.add('\nProblem details: ' + e.getMessage());
	//		errorMsg.add('\nResponse body: ' + body);
	//		throw new Merchant.InvalidResponseException(String.join(errorMsg, ' '), e);
	//	}
	//	return parsed;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for figuring out if transaction was successful or not
	//* @param Gateway transaction action
	//* @param Parsed HTTP response body
	//* @return Whether or not transaction was successful
	//* @example
	//* Boolean success = gateway.success('purchase', parsedResponse);
	//*/
	//private Boolean success(String action, Map<String, Object> parsedResponse) {
		
	//	// Default success to false
	//	Boolean success = false;

	//	// If response doesn't included messages then something went wrong
	//	if(!parsedResponse.containsKey('messages')) return success;

	//	// Cast api response messages
	//	Messages responseMessages = (Messages)parsedResponse.get('messages');
		
	//	// Check if api request was successful
	//	if (responseMessages.resultCode == API_RESULT_CODE_OK) {

	//		// Account for customer profile transactions
	//		if(action == TRANSACTION_STORE || action == TRANSACTION_UNSTORE) {
				
	//			// Mark store transaction successful
	//			success = true;
	//		} else {

	//			// If response doesn't included transaction response then something went wrong
	//			if(!parsedResponse.containsKey('transactionResponse')) return success;
				
	//			// Cast transaction response
	//			TransactionResponse transactionResponse = (
	//				(TransactionResponse)parsedResponse.get('transactionResponse')
	//			);

	//			// Check if the actual payment transaction was successful
	//			if(transactionResponse.responseCode == RESPONSE_CODE_APPROVED) {
					
	//				// Mark transaction successful
	//				success = true;
	//			}
	//		}
	//	}
		
	//	// Return transaction success result
	//	return success;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for getting the transaction request/response code
	//* @param Gateway transaction action
	//* @param Parsed HTTP response body
	//* @return A response code
	//* @example
	//* String code = gateway.code('purchase', parsedResponse);
	//*/
	//private String code(String action, Map<String, Object> parsedResponse) {
		
	//	// Default null code
	//	String code = null;

	//	// If response doesn't included messages then something went wrong
	//	if(!parsedResponse.containsKey('messages')) return code;

	//	// Cast api response messages
	//	Messages responseMessages = (Messages)parsedResponse.get('messages');

	//	// Check if api request failed
	//	if (responseMessages.resultCode == API_RESULT_CODE_ERROR) {
			
	//		// Check for transaction error
	//		if(parsedResponse.get('transactionResponse') != null) {

	//			// Cast transaction response
	//			TransactionResponse transactionResponse = (
	//				(TransactionResponse)parsedResponse.get('transactionResponse')
	//			);

	//			// Set response code
	//			code = this.standardResponseCodesMap.get(transactionResponse.responseCode);

	//			// Set more detailed response code
	//			if(transactionResponse.responseCode != RESPONSE_CODE_APPROVED) {
					
	//				// Process first transaction response error if code still hasn't been figured out
	//				if(
	//					transactionResponse.errors != null &&
	//					transactionResponse.errors.size() > 0
	//				) {
	//					TransactionResponseError transactionResponseError = transactionResponse.errors[0];
	//					code = standardResponseCodesMap.get(transactionResponseError.errorCode);
	//				}
	//			}

	//		}

	//		// Process first error message if code still hasn't been figured out
	//		if(
	//			code == null &&
	//			responseMessages.message != null &&
	//			responseMessages.message.size() > 0
	//		) {
	//			Message errorMessage = responseMessages.message[0];
	//			code = standardResponseCodesMap.get(errorMessage.code);
	//		}

	//		// Default invalid request error
	//	   	if (code == null) code = 'invalid_request_error';
	//	}

	//	// Next let's check if the actual payment transaction was successful
	//	else {

	//		// Account for customer profile transactions
	//		if(action != TRANSACTION_STORE && action != TRANSACTION_UNSTORE) {
				
	//			// If response doesn't included transaction response then something went wrong
	//			if(!parsedResponse.containsKey('transactionResponse')) return code;
				
	//			// Cast transaction response
	//			TransactionResponse transactionResponse = (
	//				(TransactionResponse)parsedResponse.get('transactionResponse')
	//			);

	//			// Set response code
	//			code = this.standardResponseCodesMap.get(transactionResponse.responseCode);

	//			// Set more detailed response code
	//			if(transactionResponse.responseCode != RESPONSE_CODE_APPROVED) {

	//				// Process first transaction response error if code still hasn't been figured out
	//				if(
	//					transactionResponse.errors != null &&
	//					transactionResponse.errors.size() > 0
	//				) {
	//					TransactionResponseError transactionResponseError = transactionResponse.errors[0];
	//					code = standardResponseCodesMap.get(transactionResponseError.errorCode);
	//				}

	//			}
	//		}

	//		// Default success
	//   		if (code == null) code = 'success';
	//	}
	//	return code;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for getting the message details from gateway to supplement standard
	//* response messages 
	//* @param Gateway transaction action
	//* @param Parsed HTTP response body
	//* @return A response message details
	//* @example
	//* String details = gateway.details('purchase', parsedResponse);
	//*/
	//private String details(String action, Map<String, Object> parsedResponse) {
		
	//	// Default null details
	//	String details = null;

	//	// If response doesn't included messages then something went wrong
	//	if(!parsedResponse.containsKey('messages')) return details;

	//	// Cast api response messages
	//	Messages responseMessages = (Messages)parsedResponse.get('messages');

	//	// Check for transaction response
	//	if(parsedResponse.get('transactionResponse') != null) {

	//		// Cast transaction response
	//		TransactionResponse transactionResponse = (
	//			(TransactionResponse)parsedResponse.get('transactionResponse')
	//		);

	//		// Process first transaction response error message if available
	//		if(
	//			transactionResponse.errors != null &&
	//			transactionResponse.errors.size() > 0
	//		) {
	//			TransactionResponseError transactionResponseError = transactionResponse.errors[0];
	//			details = transactionResponseError.errorText;
	//		}

	//		// Process first transaction response message if available
	//		if(
	//			transactionResponse.messages != null &&
	//			transactionResponse.messages.size() > 0
	//		) {
	//			TransactionResponseMessage transactionResponseMessage = transactionResponse.messages[0];
	//			details = transactionResponseMessage.description;
	//		}
	//	}

	//	// Process first api response message if available, and details still hasn't been set
	//	if(
	//		details == null &&
	//		responseMessages.message != null &&
	//		responseMessages.message.size() > 0
	//	) {
	//		Message responseMessage = responseMessages.message[0];
	//		details = responseMessage.text;
	//	}

	//	// Default details if not yet set
	//	if(details == null) {
	//		details = (
	//			responseMessages.resultCode == API_RESULT_CODE_ERROR ?
	//			'The ' + action + ' transaction was not completed successfully' :
	//			'The ' + action + ' transaction completed successfully'
	//		);
	//	}
	//	return details;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for obtaining the gateway transaction reference
	//* @param Gateway transaction action
	//* @param Gateway http request body
	//* @param Parsed HTTP response body
	//* @return A transaction reference
	//* @example
	//* String reference = gateway.message('purchase', parsedResponse);
	//*/
	//private String reference(String action, Map<String, Object> body, Map<String, Object> parsedResponse) {
	//	String reference = null;
		
	//	// Grab transaction reference if applicable
	//	if(parsedResponse.get('transactionResponse') != null) {
	//		TransactionResponse transactionResponse = (TransactionResponse)parsedResponse.get('transactionResponse');
	//		reference = transactionResponse.transId;

	//		// Add payment details for later use in refunds
	//		if(action == TRANSACTION_PURCHASE || action == TRANSACTION_AUTHORIZE) {
				
	//			// Add last four digits of card number
	//			if(String.isNotBlank(transactionResponse.accountNumber)) {
	//				if (transactionResponse.accountType != RESPONSE_ACCOUNT_TYPE_ECHECK) {
						
	//					// Remove Xs for card payments
	//					reference += '::' + transactionResponse.accountNumber.substringAfterLast('X');
	//				} else {

	//					// Don't remove Xs for bank payments
	//					reference += '::' + transactionResponse.accountNumber;
	//				}
	//			}

	//			// Add card expiration date if credit card transaction
	//			CreateTransactionRequest createTransactionRequest;
	//			createTransactionRequest = (CreateTransactionRequest)body.get(action);
	//			if (transactionResponse.accountType != RESPONSE_ACCOUNT_TYPE_ECHECK) {
	//				reference += '::' + createTransactionRequest.transactionRequest.payment.creditCard.expirationDate;
	//			} else {

	//				// Add additional bank details
	//				reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.accountType;
	//				reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.routingNumber;
	//				reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.nameOnAccount;
	//				reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.bankName;
	//			}
	//		}

	//		// Handle void reference ids because a separate id isn't generated
	//		if (action == TRANSACTION_VOID) reference += '::VOID';
	//	} else if(parsedResponse.containsKey('customerProfileId')) {
			
	//		// Grab the newly stored customer profile id
	//		reference = (String)parsedResponse.get('customerProfileId');
	//	}
		
	//	// Catch all reference; paypal always returns a reference id if supplied in the request
	//	if (String.isBlank(reference) && String.isNotBlank(String.valueOf(parsedResponse.get('refId')))) {
	//		reference = String.valueOf(parsedResponse.get('refId'));
	//	}
	//	return reference;
	//}

	///*******************************************************************************************************
	//* @description Convenience method for building the standard gateway transaction response
	//* @param Gateway transaction action
	//* @param Gateway http request body
	//* @param Parsed gateway transaction response
	//* @return A standard gateway transaction response object
	//* @example
	//* merchant_Response response = gateway.response('purchase', response);
	//*/
	//private merchant_Response response(String action, Map<String, Object> body, HttpResponse response) {
	//	System.debug('*** PayPal RESPONSE: ' + response.getBody());

	//	// Grab http response body which can be later parsed
	//	String responseBody = response.getBody();

	//	// First let's parse the response
	//	Map<String, Object> parsedResponse = this.parse(action, responseBody);

	//	// Figure out if the request was successful
	//	Boolean success = this.success(action, parsedResponse);

	//	// Get request/response code
	//	String code = this.code(action, parsedResponse);

	//	// Get request/response message
	//	String message = this.standardResponseMessages.get(code);

	//	// Get request/response message details
	//	String details = this.details(action, parsedResponse);

	//	// Get transaction reference
	//	String reference = this.reference(action, body, parsedResponse);

	//	// Return standard response
	//	return new merchant_Response(success, code, message, details, responseBody, reference);
	//}
}
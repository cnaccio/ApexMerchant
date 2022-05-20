/**
* @author Charles Naccio
* @date 2/3/2016
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Authorize.Net Gateway class, extended from the base Gateway class, handles all
* implementation details for payment processing using the Authorize.Net gateway.
*/
public with sharing class merchant_Gateway_AuthorizeDotNet extends merchant_Gateway implements merchant_IGateway {

	/*******************************************************************************************************
	* @description Gateway api result codes
	*/
	public static final String API_RESULT_CODE_OK = 'Ok';
	public static final String API_RESULT_CODE_ERROR = 'Error';

	/*******************************************************************************************************
	* @description Gateway transaction response codes
	*/
	public static final String RESPONSE_CODE_APPROVED = '1';
	public static final String RESPONSE_CODE_DECLINED = '2';
	public static final String RESPONSE_CODE_ERROR = '3';
	public static final String RESPONSE_CODE_HELD = '4';

	/*******************************************************************************************************
	* @description Bank account types
	*/
	public static final String BANK_ACCOUNT_TYPE_CHECKING = 'checking';
	public static final String BANK_ACCOUNT_TYPE_SAVINGS = 'savings';
	public static final String BANK_ACCOUNT_TYPE_BUSINESS_CHECKING = 'businessChecking';

	/*******************************************************************************************************
	* @description Types of electronic check transactions.
	*/
	public static final String ECHECK_TYPE_CCD = 'CCD';
	public static final String ECHECK_TYPE_PPD = 'PPD';
	public static final String ECHECK_TYPE_TEL = 'TEL';
	public static final String ECHECK_TYPE_WEB = 'WEB';

	/*******************************************************************************************************
	* @description Response account types
	*/
	public static final String RESPONSE_ACCOUNT_TYPE_ECHECK = 'eCheck';

	/*******************************************************************************************************
	* @description Gateway specific defaults
	*/
	public static final String DEFAULT_ECHECK_TYPE = ECHECK_TYPE_WEB;

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

	/*******************************************************************************************************
	* @description Class to model authorize.net authenticate test request
	*/
	public class AuthenticateTestRequest {

		/*******************************************************************************************************
		* @description Merchant authentication
		*/
		public MerchantAuthentication merchantAuthentication {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of authenticate test request
		* @example
		* AuthenticateTestRequest atr = new AuthenticateTestRequest();
		*/
		public AuthenticateTestRequest() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of authenticate test request from supplied parameters
		* @param Merchant authentication
		* @example
		* AuthenticateTestRequest atr;
		* atr = new AuthenticateTestRequest(new MerchantAuthentication());
		*/
		public AuthenticateTestRequest(MerchantAuthentication merchantAuthentication) {
			this.merchantAuthentication = merchantAuthentication;
		}

		/*******************************************************************************************************
		* @description Serialize authenticate test request into json string
		* @return JSON serialized string representation of authenticate test request object
		* @example
		* String jsonString = atr.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize authenticate test request into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "authenticateTestRequest": {
				generator.writeFieldName('authenticateTestRequest');
				generator.writeStartObject();

					// "merchantAuthentication": "{!merchantAuthentication}",
					generator.writeStringField('merchantAuthentication', '{!merchantAuthentication}');

				generator.writeEndObject();
				// }

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			jsonString = jsonString.replace('"{!merchantAuthentication}"', this.merchantAuthentication.serialize());
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model authorize.net create transaction request
	*/
	public class CreateTransactionRequest {

		/*******************************************************************************************************
		* @description Merchant authentication
		*/
		public MerchantAuthentication merchantAuthentication {get;set;}

		/*******************************************************************************************************
		* @description Transaction request reference id
		*/
		public String refId {
			get {
				if(refId == null) {
					
					// Generate reference guid
					Blob b = Crypto.GenerateAESKey(128);
					String h = EncodingUtil.ConvertTohex(b);
					String guid = h.substring(0, 6) +
								  '-' +
								  h.substring(6, 12) +
								  '-' +
								  h.substring(12, 18);
					refId = guid;
				}
				return refId;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Transaction request
		*/
		public TransactionRequest transactionRequest {
			get {
				if (transactionRequest == null) {
					transactionRequest = new TransactionRequest();
				}
				return transactionRequest;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Generate new instance of create transaction request
		* @example
		* CreateTransactionRequest ctr = new CreateTransactionRequest();
		*/
		public CreateTransactionRequest() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of create transaction request from supplied parameters
		* @param Merchant authentication
		* @param Transaction reference id
		* @param The transaction request
		* @example
		* CreateTransactionRequest ctr;
		* ctr = new CreateTransactionRequest(new MerchantAuthentication(), '1234', 'USD', new TransactionRequest());
		*/
		public CreateTransactionRequest(
			MerchantAuthentication merchantAuthentication,
			String refId,
			TransactionRequest transactionRequest
		) {
			this.merchantAuthentication = merchantAuthentication;
			this.refId = refId;
			this.transactionRequest = transactionRequest;
		}

		/*******************************************************************************************************
		* @description Serialize create transaction request into json string
		* @return JSON serialized string representation of create transaction request object
		* @example
		* String jsonString = ctr.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize create transaction request into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "CreateTransactionRequest": {
				generator.writeFieldName('createTransactionRequest');
				generator.writeStartObject();

					// "merchantAuthentication": "{!merchantAuthentication}",
					generator.writeStringField('merchantAuthentication', '{!merchantAuthentication}');

					// "refId": "{!refId}",
					if (String.isNotBlank(this.refId)) generator.writeStringField('refId', this.refId);

					// "transactionRequest": "{!transactionRequest}"
					generator.writeStringField('transactionRequest', '{!transactionRequest}');

				generator.writeEndObject();
				// }

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			jsonString = jsonString.replace('"{!merchantAuthentication}"', this.merchantAuthentication.serialize());
			jsonString = jsonString.replace('"{!transactionRequest}"', this.transactionRequest.serialize());
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model authorize.net create customer profile request
	*/
	public class CreateCustomerProfileRequest {

		/*******************************************************************************************************
		* @description Merchant authentication
		*/
		public MerchantAuthentication merchantAuthentication {get;set;}

		/*******************************************************************************************************
		* @description Transaction request reference id
		*/
		public String refId {
			get {
				if(refId == null) {
					
					// Generate reference guid
					Blob b = Crypto.GenerateAESKey(128);
					String h = EncodingUtil.ConvertTohex(b);
					String guid = h.substring(0, 6) +
								  '-' +
								  h.substring(6, 12) +
								  '-' +
								  h.substring(12, 18);
					refId = guid;
				}
				return refId;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Customer profile
		*/
		public Profile profile {
			get {
				if (profile == null) {
					profile = new Profile();
				}
				return profile;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Indicates the processing mode for the request. 
		* - liveMode: A $0 or $0.01 (depending on card type and processor) live transaction is processed
		* against the card and then immediately voided. Address is required for cards that support $0
		* authorizations and will be validated along with card code if submitted.
		* 
		* - testMode: Card data is validated using simple mathematical checks to confirm that it appears to be
		* valid. It is not a guarantee that the card is legitimate and customer data is not validated.
		* 
		* - None: No validation is performed at all. It is recommended that this option only be used for your
		* integration testing and not for real customers.
		*/
		public String validationMode {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of create customer request
		* @example
		* CreateCustomerProfileRequest ccpr = new CreateCustomerProfileRequest();
		*/
		public CreateCustomerProfileRequest() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of create customer request from supplied parameters
		* @param Merchant authentication
		* @param Transaction reference id
		* @param Customer profile
		* @param Validation mode
		* @example
		* CreateCustomerProfileRequest ccpr;
		* ccpr = new CreateCustomerProfileRequest(new MerchantAuthentication(), new Profile());
		*/
		public CreateCustomerProfileRequest(
			MerchantAuthentication merchantAuthentication,
			String refId,
			Profile profile,
			String validationMode
		) {
			this.merchantAuthentication = merchantAuthentication;
			this.refId = refId;
			this.profile = profile;
			this.validationMode = validationMode;
		}

		/*******************************************************************************************************
		* @description Serialize create customer profile request into json string
		* @return JSON serialized string representation of create customer profile request object
		* @example
		* String jsonString = ccpr.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize create transaction request into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "CreateCustomerProfileRequest": {
				generator.writeFieldName('createCustomerProfileRequest');
				generator.writeStartObject();

					// "merchantAuthentication": "{!merchantAuthentication}",
					generator.writeStringField('merchantAuthentication', '{!merchantAuthentication}');

					// "refId": "{!refId}",
					if (String.isNotBlank(this.refId)) generator.writeStringField('refId', this.refId);

					// "profile": "{!profile}"
					generator.writeStringField('profile', '{!profile}');

					// "validationMode": "{!validationMode}",
					if (String.isNotBlank(this.validationMode)) {
						generator.writeStringField('validationMode', this.validationMode);
					}

				generator.writeEndObject();
				// }

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			jsonString = jsonString.replace('"{!merchantAuthentication}"', this.merchantAuthentication.serialize());
			jsonString = jsonString.replace('"{!profile}"', this.profile.serialize());
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model authorize.net delete customer profile request
	*/
	public class DeleteCustomerProfileRequest {

		/*******************************************************************************************************
		* @description Merchant authentication
		*/
		public MerchantAuthentication merchantAuthentication {get;set;}

		/*******************************************************************************************************
		* @description Transaction request reference id
		*/
		public String refId {
			get {
				if(refId == null) {
					
					// Generate reference guid
					Blob b = Crypto.GenerateAESKey(128);
					String h = EncodingUtil.ConvertTohex(b);
					String guid = h.substring(0, 6) +
								  '-' +
								  h.substring(6, 12) +
								  '-' +
								  h.substring(12, 18);
					refId = guid;
				}
				return refId;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Payment gateway assigned ID associated with the customer profile. This output is present
		* only for successful requests.
		*/
		public String customerProfileId {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of delete customer request
		* @example
		* DeleteCustomerProfileRequest dcpr = new DeleteCustomerProfileRequest();
		*/
		public DeleteCustomerProfileRequest() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of delete customer request from supplied parameters
		* @param Merchant authentication
		* @param Transaction reference id
		* @param Customer profile id
		* @example
		* DeleteCustomerProfileRequest dcpr;
		* dcpr = new DeleteCustomerProfileRequest(new MerchantAuthentication(), '10000');
		*/
		public DeleteCustomerProfileRequest(
			MerchantAuthentication merchantAuthentication,
			String refId,
			String customerProfileId
		) {
			this.merchantAuthentication = merchantAuthentication;
			this.refId = refId;
			this.customerProfileId = customerProfileId;
		}

		/*******************************************************************************************************
		* @description Serialize delete customer profile request into json string
		* @return JSON serialized string representation of delete customer profile request object
		* @example
		* String jsonString = dcpr.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize delete customer profile request into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "DeleteCustomerProfileRequest": {
				generator.writeFieldName('deleteCustomerProfileRequest');
				generator.writeStartObject();

					// "merchantAuthentication": "{!merchantAuthentication}",
					if (this.merchantAuthentication != null) {
						generator.writeStringField('merchantAuthentication', '{!merchantAuthentication}');
					}

					// "refId": "{!refId}",
					if (String.isNotBlank(this.refId)) generator.writeStringField('refId', this.refId);

					// "customerProfileId": "{!customerProfileId}",
					if (String.isNotBlank(this.customerProfileId)) {
						generator.writeStringField('customerProfileId', this.customerProfileId);
					}

				generator.writeEndObject();
				// }

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			if (this.merchantAuthentication != null) {
				jsonString = jsonString.replace('"{!merchantAuthentication}"', this.merchantAuthentication.serialize());
			}
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant authentication details
	*/
	public class MerchantAuthentication {
		
		/*******************************************************************************************************
		* @description Authorize.Net api login id
		*/
		public String name {get;set;}

		/*******************************************************************************************************
		* @description Authorize.Net api transaction key
		*/
		public String transactionKey {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of merchant authentication
		* @example
		* MerchantAuthentication ma = new MerchantAuthentication();
		*/
		public MerchantAuthentication() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of merchant authentication from supplied parameters
		* @param Authorize.Net api login id
		* @param Authorize.Net api transaction key
		* @example
		* MerchantAuthentication ma;
		* ma = new MerchantAuthentication('login id', 'transaction key');
		*/
		public MerchantAuthentication(
			String name,
			String transactionKey
		) {
			this.name = name;
			this.transactionKey = transactionKey;
		}

		/*******************************************************************************************************
		* @description Serialize merchant authentication into json string
		* @return JSON serialized string representation of merchant authentication object
		* @example
		* String jsonString = ma.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize merchant authentication into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "name": "value",
				if (String.isNotBlank(this.name)) generator.writeStringField('name', this.name);

				// "transactionKey": "value"
				if (String.isNotBlank(this.transactionKey)) {
					generator.writeStringField('transactionKey', this.transactionKey);
				}

			generator.writeEndObject();
			// }

			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model customer profile
	*/
	public class Profile {
		
		/*******************************************************************************************************
		* @description Merchant assigned ID for the customer. Required only when no values for description and
		* email are submitted.
		*/
		public String merchantCustomerId {get;set;}

		/*******************************************************************************************************
		* @description Description of the customer or customer profile. Required only when no values for 
		* merchantCustomerId and email are submitted.
		*/
		public String description {get;set;}

		/*******************************************************************************************************
		* @description Email address associated with the customer profile. Required when no values for
		* description and merchantCustomerId are submitted. Required only when you use a European payment
		* processor.
		*/
		public String email {get;set;}

		/*******************************************************************************************************
		* @description Contains payment profiles for the customer profile. Multiple instances of this element
		* can be submitted to create multiple payment profiles for the customer profile.
		*/
		public PaymentProfiles paymentProfiles {
			get {
				if (paymentProfiles == null) {
					paymentProfiles = new PaymentProfiles();
				}
				return paymentProfiles;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Customer profile ship to list containing one or more ship to addresses
		*/
		public List<ShipTo> shipToList {
			get {
				if (shipToList == null) {
					shipToList = new List<ShipTo>();
				}
				return shipToList;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Generate new instance of profile
		* @example
		* Profile p = new Profile();
		*/
		public Profile() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of profile from supplied parameters
		* @param Merchant assigned customer id
		* @param Customer profile description
		* @param Customer email address
		* @param Customer payment profiles
		* @example
		* Profile p;
		* p = new Profile(
		*   'CUST-0000123',
		*   'This is a top customer!',
		*   'customer@email.com',
		*   new PaymentProfiles(),
		*   new List<ShipTo>()
		* );
		*/
		public Profile(
			String merchantCustomerId,
			String description,
			String email,
			PaymentProfiles paymentProfiles,
			List<ShipTo> shipToList
		) {
			this.merchantCustomerId = merchantCustomerId;
			this.description = description;
			this.email = email;
			this.paymentProfiles = paymentProfiles;
			this.shipToList = shipToList;
		}

		/*******************************************************************************************************
		* @description Serialize profile into json string
		* @return JSON serialized string representation of customer profile object
		* @example
		* String jsonString = p.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize customer profile into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "merchantCustomerId": "value",
				if (String.isNotBlank(this.merchantCustomerId)) {
					generator.writeStringField('merchantCustomerId', this.merchantCustomerId);
				}

				// "description": "{!description}"
				if (this.description != null) generator.writeStringField('description', this.description);

				// "email": "value",
				if (this.email != null) generator.writeStringField('email', this.email);

				// "paymentProfiles": "{!paymentProfiles}"
				if (this.paymentProfiles != null) generator.writeStringField('paymentProfiles', '{!paymentProfiles}');

				// "shipToList": "{!shipToList}"
				if (this.shipToList != null) generator.writeStringField('shipToList', '{!shipToList}');

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			if (this.paymentProfiles != null) {
				jsonString = jsonString.replace('"{!paymentProfiles}"', this.paymentProfiles.serialize());
			}
			if (this.shipToList != null) {
				
				// Start array
				String jsonShipToList = '[';

				// Serialize each ship to address
				List<String> jsonShipTos = new List<String>();
				for(ShipTo shipTo: this.shipToList) {
					jsonShipTos.add(shipTo.serialize());
				}

				// Add ship tos json to ship to list
				if (jsonShipTos.size() > 0) {
					String jsonShipTo = String.join(jsonShipTos, ',');
					
					// Don't add empty ship to addresses as that will cause an error
					Object objShipTo = JSON.deserializeUntyped(jsonShipTo);
					if (String.valueOf(objShipTo).trim().length() > 2) jsonShipToList += jsonShipTo;
				}

				// End array
				jsonShipToList += ']';

				// Add ship to addresses to list
				jsonString = jsonString.replace('"{!shipToList}"', jsonShipToList);
			}
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model customer payment profiles
	*/
	public class PaymentProfiles {
		
		/*******************************************************************************************************
		* @description Customer type (individual or business)
		*/
		public String customerType {get;set;}

		/*******************************************************************************************************
		* @description Customer profile bill to details
		*/
		public BillTo billTo {
			get {
				if (billTo == null) {
					billTo = new BillTo();
				}
				return billTo;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Customer profile payment details
		*/
		public Payment payment {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of customer payment profiles
		* @example
		* PaymentProfiles pp = new PaymentProfiles();
		*/
		public PaymentProfiles() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of customer payment profile from supplied parameters
		* @param Customer type (individual or business)
		* @param Customer profile payment
		* @example
		* PaymentProfiles pp;
		* pp = new PaymentProfiles(
		*   'business',
		*   new BillTo(),
		*   new Payment()
		* );
		*/
		public PaymentProfiles(
			String customerType,
			BillTo billTo,
			Payment payment
		) {
			this.customerType = customerType;
			this.billTo = billTo;
			this.payment = payment;
		}

		/*******************************************************************************************************
		* @description Serialize customer payment profile into json string
		* @return JSON serialized string representation of customer payment profile object
		* @example
		* String jsonString = pp.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize customer payment profile into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "customerType": "value",
				if (String.isNotBlank(this.customerType)) {
					generator.writeStringField('customerType', this.customerType);
				}

				// "billTo": "{!billTo}"
				if (this.billTo != null) generator.writeStringField('billTo', '{!billTo}');

				// "payment": "{!payment}"
				if (this.payment != null) generator.writeStringField('payment', '{!payment}');

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			if (this.billTo != null) jsonString = jsonString.replace('"{!billTo}"', this.billTo.serialize());
			if (this.payment != null) jsonString = jsonString.replace('"{!payment}"', this.payment.serialize());
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model transaction requests
	*/
	public class TransactionRequest {
		
		/*******************************************************************************************************
		* @description Transaction type
		*/
		public String transactionType {get;set;}

		/*******************************************************************************************************
		* @description Transaction amount
		*/
		public Decimal amount {get;set;}

		/*******************************************************************************************************
		* @description Transaction payment details
		*/
		public Payment payment {get;set;}

		/*******************************************************************************************************
		* @description Transaction reference id
		*/
		public String refTransId {get;set;}

		/*******************************************************************************************************
		* @description Transaction order details
		*/
		public Order order {
			get {
				if (order == null) {
					order = new Order();
				}
				return order;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Transaction customer details
		*/
		public Customer customer {
			get {
				if (customer == null) {
					customer = new Customer();
				}
				return customer;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Transaction bill to details
		*/
		public BillTo billTo {
			get {
				if (billTo == null) {
					billTo = new BillTo();
				}
				return billTo;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Transaction ship to details
		*/
		public ShipTo shipTo {
			get {
				if (shipTo == null) {
					shipTo = new ShipTo();
				}
				return shipTo;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Generate new instance of transaction request
		* @example
		* TransactionRequest tr = new TransactionRequest();
		*/
		public TransactionRequest() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of transaction request from supplied parameters
		* @param Transaction type
		* @param Transaction amount
		* @param Transaction reference id
		* @param Transaction payment details
		* @param Transaction bill to details
		* @param Transaction ship to details
		* @example
		* TransactionRequest tr;
		* tr = new TransactionRequest(
		*   'authCaptureTransaction',
		*   5.00,
		*   '1234567890',
		*   new Payment(),
		*   new Order(),
		*   new Customer(),
		*   new BillTo(),
		*   new ShipTo()
		* );
		*/
		public TransactionRequest(
			String transactionType,
			Decimal amount,
			String refTransId,
			Payment payment,
			Order order,
			Customer customer,
			BillTo billTo,
			ShipTo shipTo
		) {
			this.transactionType = transactionType;
			this.amount = amount;
			this.payment = payment;
			this.refTransId = refTransId;
			this.order = order;
			this.customer = customer;
			this.billTo = billTo;
			this.shipTo = shipTo;
		}

		/*******************************************************************************************************
		* @description Serialize transaction request into json string
		* @return JSON serialized string representation of transaction request object
		* @example
		* String jsonString = tr.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize transaction request into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "transactionType": "value",
				if (String.isNotBlank(this.transactionType)) {
					generator.writeStringField('transactionType', this.transactionType);
				}

				// "amount": "value",
				if (this.amount != null) generator.writeNumberField('amount', this.amount);

				// "payment": "{!payment}"
				if (this.payment != null) generator.writeStringField('payment', '{!payment}');

				// "refTransId": "value",
				if (this.refTransId != null) generator.writeStringField('refTransId', this.refTransId);

				// "order": "{!order}"
				generator.writeStringField('order', '{!order}');

				// "customer": "{!customer}"
				generator.writeStringField('customer', '{!customer}');

				// "billTo": "{!billTo}"
				generator.writeStringField('billTo', '{!billTo}');

				// "shipTo": "{!shipTo}"
				generator.writeStringField('shipTo', '{!shipTo}');

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			if (this.payment != null) jsonString = jsonString.replace('"{!payment}"', this.payment.serialize());
			if (this.order != null) jsonString = jsonString.replace('"{!order}"', this.order.serialize());
			if (this.customer != null) jsonString = jsonString.replace('"{!customer}"', this.customer.serialize());
			if (this.billTo != null) jsonString = jsonString.replace('"{!billTo}"', this.billTo.serialize());
			if (this.shipTo != null) jsonString = jsonString.replace('"{!shipTo}"', this.shipTo.serialize());
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant payment details
	*/
	public class Payment {
		
		/*******************************************************************************************************
		* @description Credit card payment
		*/
		public CreditCard creditCard {get;set;}

		/*******************************************************************************************************
		* @description Bank account payment
		*/
		public BankAccount bankAccount {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of payment
		* @example
		* Payment pymt = new Payment();
		*/
		public Payment() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of payment from supplied parameters
		* @param Credit card details
		* @example
		* Payment pymt;
		* pymt = new Payment(new CreditCard());
		*/
		public Payment(
			CreditCard creditCard
		) {
			this.creditCard = creditCard;
		}

		/*******************************************************************************************************
		* @description Generate new instance of payment from supplied parameters
		* @param Bank account details
		* @example
		* Payment pymt;
		* pymt = new Payment(new BankAccount());
		*/
		public Payment(
			BankAccount bankAccount
		) {
			this.bankAccount = bankAccount;
		}

		/*******************************************************************************************************
		* @description Serialize payment into json string
		* @return JSON serialized string representation of payment object
		* @example
		* String jsonString = pymt.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize payment into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();

				// "creditCard": "{!creditCard}"
				if (this.creditCard != null) generator.writeStringField('creditCard', '{!creditCard}');

				// "bankAccount": "{!bankAccount}"
				if (this.bankAccount != null) generator.writeStringField('bankAccount', '{!bankAccount}');

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();

			// Replace tokens in order to support nested serialization
			if (this.creditCard != null) {
				jsonString = jsonString.replace('"{!creditCard}"', this.creditCard.serialize());
			}
			if (this.bankAccount != null) {
				jsonString = jsonString.replace('"{!bankAccount}"', this.bankAccount.serialize());
			}
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant credit card payment details
	*/
	public class CreditCard {
		
		/*******************************************************************************************************
		* @description Credit card number
		*/
		public String cardNumber {get;set;}

		/*******************************************************************************************************
		* @description Credit card expiration date
		*/
		public String expirationDate {get;set;}

		/*******************************************************************************************************
		* @description Credit card security code
		*/
		public String cardCode {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of credit card
		* @example
		* CreditCard cc = new CreditCard();
		*/
		public CreditCard() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of credit card from supplied parameters
		* @param Credit card number
		* @param Credit card expiration date
		* @param Credit card security code
		* @example
		* CreditCard cc;
		* cc = new CreditCard('0123456789123456', '1122', '944');
		*/
		public CreditCard(
			String cardNumber,
			String expirationDate,
			String cardCode
		) {
			this.cardNumber = cardNumber;
			this.expirationDate = expirationDate;
			this.cardCode = cardCode;
		}

		/*******************************************************************************************************
		* @description Generate new instance of credit card from merchant card source
		* @param Merchant card source
		* @example
		* CreditCard cc;
		* cc = new CreditCard(new merchant_Source_Card);
		*/
		public CreditCard(merchant_Source_Card card) {
			this.cardNumber = card.cardNumber;
			this.expirationDate = card.month + card.year;
			this.cardCode = card.cvv;
		}

		/*******************************************************************************************************
		* @description Serialize credit card into json string
		* @return JSON serialized string representation of credit card object
		* @example
		* String jsonString = cc.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize credit card into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "cardNumber": "value",
				if (String.isNotBlank(this.cardNumber)) generator.writeStringField('cardNumber', this.cardNumber);

				// "expirationDate": "value"
				if (String.isNotBlank(this.expirationDate)) {
					generator.writeStringField('expirationDate', this.expirationDate);
				}

				// "cardCode": "value"
				if (String.isNotBlank(this.cardCode)) generator.writeStringField('cardCode', this.cardCode);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant bank account payment details. Contains bank account payment
	* information for the payment profile. This element is required only when the payment profile is
	* bank account.
	*/
	public class BankAccount {
		
		/*******************************************************************************************************
		* @description The type of bank account for payment profile. (checking, savings, or businessChecking.)
		*/
		public String accountType {get;set;}

		/*******************************************************************************************************
		* @description The routing number of the customer’s bank. (9 digits.)
		*/
		public String routingNumber {get;set;}

		/*******************************************************************************************************
		* @description The customer’s bank account number. (5 to 17 digits.)
		*/
		public String accountNumber {get;set;}

		/*******************************************************************************************************
		* @description The customer’s full name as listed on the bank account. (Up to 22 characters.)
		*/
		public String nameOnAccount {get;set;}

		/*******************************************************************************************************
		* @description The type of electronic check transaction. (CCD, PPD, TEL, WEB)
		*/
		public String echeckType {get;set;}

		/*******************************************************************************************************
		* @description The name of the bank associated with the bank account number. (Up to 50 characters.)
		*/
		public String bankName {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of bank account
		* @example
		* BankAccount ba = new BankAccount();
		*/
		public BankAccount() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of bank account from supplied parameters
		* @param The type of bank account for payment profile. (checking, savings, or businessChecking.)
		* @param The routing number of the customer’s bank. (9 digits.)
		* @param The customer’s bank account number. (5 to 17 digits.)
		* @param The customer’s full name as listed on the bank account. (Up to 22 characters.)
		* @param The type of electronic check transaction. (CCD, PPD, TEL, WEB)
		* @param The name of the bank associated with the bank account number. (Up to 50 characters.)
		* @example
		* BankAccount ba;
		* ba = new BankAccount('checking', '123456789', '1234567890123456', 'Charles Naccio', 'WEB', 'Chase');
		*/
		public BankAccount(
			String accountType,
			String routingNumber,
			String accountNumber,
			String nameOnAccount,
			String echeckType,
			String bankName
		) {
			this.accountType = accountType;
			this.routingNumber = routingNumber;
			this.accountNumber = accountNumber;
			this.nameOnAccount = nameOnAccount;
			this.echeckType = echeckType;
			this.bankName = bankName;
		}

		/*******************************************************************************************************
		* @description Generate new instance of bank account from merchant bank source
		* @param Merchant bank source
		* @example
		* BankAccount ba;
		* ba = new BankAccount(new merchant_Source_Bank);
		*/
		public BankAccount(merchant_Source_Bank bank) {
			this.accountType = bank.accountType;
			this.routingNumber = bank.routingNumber;
			this.accountNumber = bank.accountNumber;
			this.nameOnAccount = bank.accountName;
			this.bankName = bank.bankName;

			// Note that eCheck type is also figured out externally
			this.echeckType = DEFAULT_ECHECK_TYPE;
		}

		/*******************************************************************************************************
		* @description Serialize bank account into json string
		* @return JSON serialized string representation of bank account object
		* @example
		* String jsonString = ba.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize bank account into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();
				
				// "accountType": "value",
				if (String.isNotBlank(this.accountType)) generator.writeStringField('accountType', this.accountType);

				// "routingNumber": "value",
				if (String.isNotBlank(this.routingNumber)) {
					generator.writeStringField('routingNumber', this.routingNumber);
				}

				// "accountNumber": "value",
				if (String.isNotBlank(this.accountNumber)) {
					generator.writeStringField('accountNumber', this.accountNumber);
				}

				// "nameOnAccount": "value",
				if (String.isNotBlank(this.nameOnAccount)) {
					generator.writeStringField('nameOnAccount', this.nameOnAccount);
				}

				// "echeckType": "value",
				if (String.isNotBlank(this.echeckType)) generator.writeStringField('echeckType', this.echeckType);

				// "bankName": "value",
				if (String.isNotBlank(this.bankName)) generator.writeStringField('bankName', this.bankName);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model transaction customer details
	*/
	public class Order {
		
		/*******************************************************************************************************
		* @description Order invoice number
		*/
		public String invoiceNumber {get;set;}

		/*******************************************************************************************************
		* @description Order description
		*/
		public String description {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of order
		* @example
		* Order order = new Order();
		*/
		public Order() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of order from merchant transaction options
		* @param Merchant transaction options
		* @example
		* Order order;
		* order = new Order(new merchant_TransactionOptions);
		*/
		public Order(merchant_TransactionOptions options) {
			this.invoiceNumber = options.invoice;
			this.description = options.description;
		}

		/*******************************************************************************************************
		* @description Serialize order into json string
		* @return JSON serialized string representation of order object
		* @example
		* String jsonString = order.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize order into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();

				// "invoiceNumber": "value",
				if (String.isNotBlank(this.invoiceNumber)) {
					generator.writeStringField('invoiceNumber', this.invoiceNumber);
				}

				// "description": "value"
				if (String.isNotBlank(this.description)) generator.writeStringField('description', this.description);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model transaction customer details
	*/
	public class Customer {
		
		/*******************************************************************************************************
		* @description Customer type
		*/
		public String type {get;set;}

		/*******************************************************************************************************
		* @description Customer id
		*/
		public String id {get;set;}

		/*******************************************************************************************************
		* @description Customer email
		*/
		public String email {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of customer
		* @example
		* Customer customer = new Customer();
		*/
		public Customer() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of customer from merchant transaction options
		* @param Merchant transaction options
		* @example
		* Customer customer;
		* customer = new Customer(new merchant_TransactionOptions);
		*/
		public Customer(merchant_TransactionOptions options) {
			this.id = options.customer;
			this.email = options.email;
		}

		/*******************************************************************************************************
		* @description Serialize customer into json string
		* @return JSON serialized string representation of customer object
		* @example
		* String jsonString = customer.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize customer into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();

				// "type": "value",
				if (String.isNotBlank(this.type)) generator.writeStringField('type', this.type);

				// "id": "value"
				if (String.isNotBlank(this.id)) generator.writeStringField('id', this.id);

				// "email": "value"
				if (String.isNotBlank(this.email)) generator.writeStringField('email', this.email);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant bill to details
	*/
	public class BillTo {
		
		/*******************************************************************************************************
		* @description Bill to first name
		*/
		public String firstName {get;set;}

		/*******************************************************************************************************
		* @description Bill to last name
		*/
		public String lastName {get;set;}

		/*******************************************************************************************************
		* @description Bill to company
		*/
		public String company {get;set;}

		/*******************************************************************************************************
		* @description Bill to street address
		*/
		public String address {get;set;}

		/*******************************************************************************************************
		* @description Bill to city
		*/
		public String city {get;set;}

		/*******************************************************************************************************
		* @description Bill to state
		*/
		public String state {get;set;}

		/*******************************************************************************************************
		* @description Bill to zip
		*/
		public String zip {get;set;}

		/*******************************************************************************************************
		* @description Bill to country
		*/
		public String country {get;set;}

		/*******************************************************************************************************
		* @description Bill to phone number
		*/
		public String phoneNumber {get;set;}

		/*******************************************************************************************************
		* @description Bill to fax number
		*/
		public String faxNumber {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of bill to
		* @example
		* BillTo billTo = new BillTo();
		*/
		public BillTo() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of bill to from merchant card source
		* @param Merchant card source
		* @example
		* BillTo billTo;
		* billTo = new BillTo(new merchant_Source_Card);
		*/
		public BillTo(merchant_Source_Card card) {
			this.firstName = card.firstName;
			this.lastName = card.lastName;
			this.company = card.company;
			this.address = String.isBlank(card.address1) ? '' : card.address1;
			this.address += String.isBlank(card.address2) ? '' : ' ' + card.address2;
			this.city = card.city;
			this.state = card.state;
			this.zip = card.postalCode;
			this.country = card.country;
			this.phoneNumber = card.phone;
		}

		/*******************************************************************************************************
		* @description Populate bill to from merchant transaction options. Note that we're only
		* going to update bill to details from transaction options if not already set
		* @param Merchant transaction options
		* @example
		* BillTo billTo = new BillTo();
		* billTo.addOptions(new merchant_TransactionOptions());
		*/
		public void addOptions(merchant_TransactionOptions options) {
			if(String.isNotBlank(options.billingName)) {
				List<String> nameParts = options.billingName.split(' ');
				if(nameParts.size() > 0) {
					if (String.isBlank(this.firstName)) this.firstName = nameParts[0];
				}
				if(nameParts.size() > 1) {
					if (String.isBlank(this.lastName)) this.lastName = nameParts[1];
				}
			}
			if (String.isBlank(this.company)) this.company = options.billingCompany;
			if (String.isBlank(this.address)) {
				this.address = String.isBlank(options.billingAddress1) ? '' : options.billingAddress1;
				this.address += String.isBlank(options.billingAddress2) ? '' : ' ' + options.billingAddress2;
			}
			if (String.isBlank(this.city)) this.city = options.billingCity;
			if (String.isBlank(this.state)) this.state = options.billingState;
			if (String.isBlank(this.zip)) this.zip = options.billingPostalCode;
			if (String.isBlank(this.country)) this.country = options.billingCountry;
			if (String.isBlank(this.phoneNumber)) this.phoneNumber = options.billingPhone;
		}

		/*******************************************************************************************************
		* @description Serialize bill to into json string
		* @return JSON serialized string representation of bill to object
		* @example
		* String jsonString = billTo.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize bill to into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();

				// "firstName": "value",
				if (String.isNotBlank(this.firstName)) generator.writeStringField('firstName', this.firstName);

				// "lastName": "value"
				if (String.isNotBlank(this.lastName)) generator.writeStringField('lastName', this.lastName);

				// "company": "value"
				if (String.isNotBlank(this.company)) generator.writeStringField('company', this.company);

				// "address": "value"
				if (String.isNotBlank(this.address)) generator.writeStringField('address', this.address);

				// "city": "value"
				if (String.isNotBlank(this.city)) generator.writeStringField('city', this.city);

				// "state": "value"
				if (String.isNotBlank(this.state)) generator.writeStringField('state', this.state);

				// "zip": "value"
				if (String.isNotBlank(this.zip)) generator.writeStringField('zip', this.zip);

				// "country": "value"
				if (String.isNotBlank(this.country)) generator.writeStringField('country', this.country);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant ship to details
	*/
	public class ShipTo {
		
		/*******************************************************************************************************
		* @description Ship to first name
		*/
		public String firstName {get;set;}

		/*******************************************************************************************************
		* @description Ship to last name
		*/
		public String lastName {get;set;}

		/*******************************************************************************************************
		* @description Ship to company
		*/
		public String company {get;set;}

		/*******************************************************************************************************
		* @description Ship to street address
		*/
		public String address {get;set;}

		/*******************************************************************************************************
		* @description Ship to city
		*/
		public String city {get;set;}

		/*******************************************************************************************************
		* @description Ship to state
		*/
		public String state {get;set;}

		/*******************************************************************************************************
		* @description Ship to zip
		*/
		public String zip {get;set;}

		/*******************************************************************************************************
		* @description Ship to country
		*/
		public String country {get;set;}

		/*******************************************************************************************************
		* @description Ship to customer ip address
		*/
		public String customerIP {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of ship to
		* @example
		* ShipTo shipTo = new ShipTo();
		*/
		public ShipTo() {
			// Do something
		}

		/*******************************************************************************************************
		* @description Generate new instance of ship to from merchant transaction options
		* @param Merchant transaction options
		* @example
		* ShipTo shipTo;
		* shipTo = new ShipTo(new merchant_TransactionOptions);
		*/
		public ShipTo(merchant_TransactionOptions options) {
			if(String.isNotBlank(options.shippingName)) {
				List<String> nameParts = options.shippingName.split(' ');
				if(nameParts.size() > 0) {
					this.firstName = nameParts[0];
				}
				if(nameParts.size() > 1) {
					this.lastName = nameParts[1];
				}
			}
			this.company = options.shippingCompany;
			this.address = String.isBlank(options.shippingAddress1) ? '' : options.shippingAddress1;
			this.address += String.isBlank(options.shippingAddress2) ? '' : ' ' + options.shippingAddress2;
			this.city = options.shippingCity;
			this.state = options.shippingState;
			this.zip = options.shippingPostalCode;
			this.country = options.shippingCountry;
			this.customerIP = options.ip;
		}

		/*******************************************************************************************************
		* @description Serialize ship to into json string
		* @return JSON serialized string representation of ship to object
		* @example
		* String jsonString = shipTo.serialize();
		*/
		public String serialize() {
			
			// Setup json string
			String jsonString;
			
			// Manually serialize ship to into json string using the json generator class
			JSONGenerator generator = JSON.createGenerator(true);
			
			// {
			generator.writeStartObject();

				// "firstName": "value",
				if (String.isNotBlank(this.firstName)) generator.writeStringField('firstName', this.firstName);

				// "lastName": "value"
				if (String.isNotBlank(this.lastName)) generator.writeStringField('lastName', this.lastName);

				// "company": "value"
				if (String.isNotBlank(this.company)) generator.writeStringField('company', this.company);

				// "address": "value"
				if (String.isNotBlank(this.address)) generator.writeStringField('address', this.address);

				// "city": "value"
				if (String.isNotBlank(this.city)) generator.writeStringField('city', this.city);

				// "state": "value"
				if (String.isNotBlank(this.state)) generator.writeStringField('state', this.state);

				// "zip": "value"
				if (String.isNotBlank(this.zip)) generator.writeStringField('zip', this.zip);

				// "country": "value"
				if (String.isNotBlank(this.country)) generator.writeStringField('country', this.country);

				// "customerIP": "value"
				if (String.isNotBlank(this.customerIP)) generator.writeStringField('customerIP', this.customerIP);

			generator.writeEndObject();
			// }

			// Grab json string
			jsonString = generator.getAsString();
			
			// Return json string
			return jsonString;
		}
	}

	/**
	 * Gateway API Response Classes
	 */

	/*******************************************************************************************************
	* @description Class to model authorize.net authenticate test response
	*/
	public class AuthenticateTestResponse {

		/*******************************************************************************************************
		* @description Authentication test response messages
		*/
		public Messages messages {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of authentication test response
		* @example
		* AuthenticateTestResponse atr = new AuthenticateTestResponse();
		*/
		public AuthenticateTestResponse() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model create transaction response
	*/
	public class CreateTransactionResponse {

		/*******************************************************************************************************
		* @description Merchant-assigned reference ID for the request. If included in the request, this value
		* will be included in the response. This feature might be especially useful for multi-threaded
		* applications.
		*/
		public String refId {get;set;}

		/*******************************************************************************************************
		* @description Response messages
		*/
		public Messages messages {get;set;}

		/*******************************************************************************************************
		* @description Transaction response
		*/
		public TransactionResponse transactionResponse {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of create transaction response
		* @example
		* CreateTransactionResponse ccpr = new CreateTransactionResponse();
		*/
		public CreateTransactionResponse() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model create customer profile response
	*/
	public class CreateCustomerProfileResponse {

		/*******************************************************************************************************
		* @description Merchant-assigned reference ID for the request. If included in the request, this value
		* will be included in the response. This feature might be especially useful for multi-threaded
		* applications.
		*/
		public String refId {get;set;}

		/*******************************************************************************************************
		* @description Payment gateway assigned ID associated with the customer profile. This output is present
		* only for successful requests.
		*/
		public String customerProfileId {get;set;}

		/*******************************************************************************************************
		* @description A list of all payment profile IDs created with the request. This output is present only
		* for requests that contain one or more payment profiles.
		*
		* The payment profile IDs are returned in the same order as they were in the request.
		*/
		public List<String> customerPaymentProfileIdList {get;set;}

		/*******************************************************************************************************
		* @description A list of all shipping profile IDs created with the request. This output is present only
		* for requests that contain multiple shipping profiles.
		*
		* The shipping profile IDs are returned in the same order as they were in the request.
		*/
		public List<String> customerShippingAddressIdList {get;set;}

		/*******************************************************************************************************
		* @description A list of the direct response results for the validation transaction for each payment
		* profile. This output is present only if the ValidationMode input element is passed with a value of
		* testMode or liveMode.
		*
		* The list is returned in the same order as the payment profiles were submitted in the request.
		*/
		public List<String> validationDirectResponseList {get;set;}

		/*******************************************************************************************************
		* @description Response messages
		*/
		public Messages messages {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of create customer profile response
		* @example
		* CreateCustomerProfileResponse ccpr = new CreateCustomerProfileResponse();
		*/
		public CreateCustomerProfileResponse() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model delete customer profile response
	*/
	public class DeleteCustomerProfileResponse {

		/*******************************************************************************************************
		* @description Merchant-assigned reference ID for the request. If included in the request, this value
		* will be included in the response. This feature might be especially useful for multi-threaded
		* applications.
		*/
		public String refId {get;set;}

		/*******************************************************************************************************
		* @description Response messages
		*/
		public Messages messages {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of delete customer profile response
		* @example
		* DeleteCustomerProfileResponse dcpr = new DeleteCustomerProfileResponse();
		*/
		public DeleteCustomerProfileResponse() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant transaction response
	*/
	public class TransactionResponse {

		/*******************************************************************************************************
		* @description Transaction response code
		*/
		public String responseCode {get;set;}

		/*******************************************************************************************************
		* @description Transaction auth code
		*/
		public String authCode {get;set;}

		/*******************************************************************************************************
		* @description Transaction avs result code
		*/
		public String avsResultCode {get;set;}

		/*******************************************************************************************************
		* @description Transaction cvv result code
		*/
		public String cvvResultCode {get;set;}

		/*******************************************************************************************************
		* @description Transaction cavv result code
		*/
		public String cavvResultCode {get;set;}

		/*******************************************************************************************************
		* @description The payment gateway assigned identification number for transaction. The transId value
		* must be used for any follow-on transactions such as a credit, prior authorization and capture,
		* or void.
		*/
		public String transId {get;set;}

		/*******************************************************************************************************
		* @description The transaction ID of a related, previously settled transaction. 
		*/
		public String refTransId {get;set;}

		/*******************************************************************************************************
		* @description Payment gateway-generated MD5 hash value that can be used to authenticate the
		* transaction response. Because transaction responses are returned using an SSL connection, this
		* feature is not necessary for AIM.
		*/
		public String transHash {get;set;}

		/*******************************************************************************************************
		* @description Last four digits of the card provided.
		*/
		public String accountNumber {get;set;}

		/*******************************************************************************************************
		* @description Last four digits of the card provided.
		*/
		public String accountType {get;set;}

		/*******************************************************************************************************
		* @description Transaction response messages
		*/
		public List<TransactionResponseMessage> messages {get;set;}

		/*******************************************************************************************************
		* @description Transaction response errors
		*/
		public List<TransactionResponseError> errors {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of transaction response
		* @example
		* TransactionResponse tr = new TransactionResponse();
		*/
		public TransactionResponse() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant messages response
	*/
	public class Messages {

		/*******************************************************************************************************
		* @description Ok or Error. Contains additional information about the status of the request.	
		*/
		public String resultCode {get;set;}

		/*******************************************************************************************************
		* @description Messages message array
		*/
		public List<Message> message {
			get {
				if(message == null) {
					message = new List<Message>();
				}
				return message;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Generate new instance of messages
		* @example
		* Messages msgs = new Messages();
		*/
		public Messages() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant response messages
	*/
	public class Message {

		/*******************************************************************************************************
		* @description Code number for message. 
		*/
		String code {get;set;}

		/*******************************************************************************************************
		* @description Text for the error message. 
		*/
		String text {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of message.
		* @example
		* Message msg = new Message();
		*/
		public Message() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant transaction response messages. These messages contain detailed
	* information about the status of a particular transaction. 
	*/
	public class TransactionResponseMessage {

		/*******************************************************************************************************
		* @description Response code that represents the status. 
		*/
		public String code {get;set;}

		/*******************************************************************************************************
		* @description Text description of the status. 
		*/
		public String description {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of transaction response message
		* @example
		* TransactionResponseMessage msg = new TransactionResponseMessage();
		*/
		public TransactionResponseMessage() {
			// Do something
		}
	}

	/*******************************************************************************************************
	* @description Class to model merchant transaction response errors. This element contains detailed
	* information about any errors returned. 
	*/
	public class TransactionResponseError {

		/*******************************************************************************************************
		* @description Error code returned. 
		*/
		public String errorCode {
			get {
				
				// Prefix error codes with an "E" to deal with ambiguous response codes from Authorize.net
				if(String.isNotBlank(errorCode) && !errorCode.contains('E')) {
					errorCode = 'E' + errorCode;
				}
				return errorCode;
			}
			set;
		}

		/*******************************************************************************************************
		* @description Text description of error.
		*/
		public String errorText {get;set;}

		/*******************************************************************************************************
		* @description Generate new instance of transaction response error
		* @example
		* TransactionResponseError error = new TransactionResponseError();
		*/
		public TransactionResponseError() {
			// Do something
		}
	}

	/**
	 * Gateway Constructor/Methods
	 */

	/*******************************************************************************************************
	* @description Initialize new gateway instance
	* @example
	* merchant_Gateway_AuthorizeDotNet gateway = new merchant_Gateway_AuthorizeDotNet();
	*/
	public merchant_Gateway_AuthorizeDotNet() {
		
		// Set standard gateway options
		this.name = 'AuthorizeDotNet';
		this.displayName = 'Authorize.Net';
		this.testUrl = 'https://apitest.authorize.net/xml/v1/request.api';
		this.liveUrl = 'https://api.authorize.net/xml/v1/request.api';
		this.homepageUrl = 'http://www.authorize.net';
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
			'Checking' => BANK_ACCOUNT_TYPE_CHECKING,
			'Savings' => BANK_ACCOUNT_TYPE_SAVINGS,
			'Business Checking' => BANK_ACCOUNT_TYPE_BUSINESS_CHECKING
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
	        'held_for_review' => this.standardResponseCodes.get('held_for_review'),

	        // API response codes
	        'E00006' => this.standardResponseCodes.get('authentication_error'),
	        'E00007' => this.standardResponseCodes.get('authentication_error'),
	        'E00008' => this.standardResponseCodes.get('authentication_error'),
	        'E00010' => this.standardResponseCodes.get('authentication_error'),
	        'E00011' => this.standardResponseCodes.get('authentication_error'),
	        'E00059' => this.standardResponseCodes.get('authentication_error'),
	        'E00001' => this.standardResponseCodes.get('processing_error'),

	        // Basic transaction response codes
	        RESPONSE_CODE_APPROVED => this.standardResponseCodes.get('success'),
	        RESPONSE_CODE_DECLINED => this.standardResponseCodes.get('card_declined'),
	        RESPONSE_CODE_ERROR => this.standardResponseCodes.get('processing_error'),
	        RESPONSE_CODE_HELD => this.standardResponseCodes.get('held_for_review'),

	        // Detailed transaction response codes; see reference below.
	        // http://developer.authorize.net/api/reference/dist/json/responseCodes.json
	        'E1' => this.standardResponseCodes.get('success'),
	        'E2' => this.standardResponseCodes.get('card_declined'),
	        'E3' => this.standardResponseCodes.get('call_issuer'),
	        'E4' => this.standardResponseCodes.get('pickup_card'),
	        'E5' => this.standardResponseCodes.get('invalid_request_error'),
	        'E6' => this.standardResponseCodes.get('invalid_number'),
	        'E7' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'E8' => this.standardResponseCodes.get('expired_card'),
	        'E9' => this.standardResponseCodes.get('invalid_routing_number'),
	        'E10' => this.standardResponseCodes.get('invalid_account_number'),
	        'E13' => this.standardResponseCodes.get('authentication_error'),
	        'E27' => this.standardResponseCodes.get('incorrect_address'),
	        'E35' => this.standardResponseCodes.get('processing_error'),
	        'E36' => this.standardResponseCodes.get('processing_error'),
	        'E37' => this.standardResponseCodes.get('invalid_number'),
	        'E43' => this.standardResponseCodes.get('processing_error'),
	        'E44' => this.standardResponseCodes.get('incorrect_cvc'),
	        'E45' => this.standardResponseCodes.get('invalid_cvc'),
	        'E46' => this.standardResponseCodes.get('authentication_error'),
	        'E65' => this.standardResponseCodes.get('incorrect_cvc'),
	        'E78' => this.standardResponseCodes.get('invalid_cvc'),
	        'E101' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E102' => this.standardResponseCodes.get('authentication_error'),
	        'E103' => this.standardResponseCodes.get('authentication_error'),
	        'E104' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E105' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E106' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E107' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E108' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E109' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E110' => this.standardResponseCodes.get('incorrect_account_info'),
	        'E123' => this.standardResponseCodes.get('authentication_error'),
	        'E127' => this.standardResponseCodes.get('incorrect_address'),
	        'E193' => this.standardResponseCodes.get('held_for_review'),
	        'E200' => this.standardResponseCodes.get('invalid_number'),
	        'E201' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'E248' => this.standardResponseCodes.get('invalid_check_number'),
	        'E252' => this.standardResponseCodes.get('held_for_review'),
	        'E253' => this.standardResponseCodes.get('held_for_review'),
	        'E290' => this.standardResponseCodes.get('incorrect_address'),
	        'E315' => this.standardResponseCodes.get('invalid_number'),
	        'E316' => this.standardResponseCodes.get('invalid_expiry_date'),
	        'E317' => this.standardResponseCodes.get('expired_card')
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
		AuthenticateTestRequest authenticationTestRequest = new AuthenticateTestRequest();

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_VERIFY => authenticationTestRequest
		};

		// Process request
		merchant_Response authenticationTestResponse = this.request(TRANSACTION_VERIFY, body);

		// Confirm successful request
		verified = authenticationTestResponse.success;

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
		CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
			TRANSACTION_PURCHASE
		);
		createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_PURCHASE => createTransactionRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_PURCHASE, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_PURCHASE, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_PURCHASE, body);
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
		CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
			TRANSACTION_AUTHORIZE
		);
		createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_AUTHORIZE => createTransactionRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_AUTHORIZE, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_AUTHORIZE, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_AUTHORIZE, body);
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
				'Please use a "Reference" payment source to use Authorize.Net\'s "Capture" functionality.'
			);
		}

		// Build request
		CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
			TRANSACTION_CAPTURE
		);
		createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_CAPTURE => createTransactionRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_CAPTURE, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_CAPTURE, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_CAPTURE, body);
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
				'Please use a "Reference" payment source to use Authorize.Net\'s "Void" functionality.'
			);
		}

		// Build request
		CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
			TRANSACTION_VOID
		);

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_VOID => createTransactionRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_VOID, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_VOID, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_VOID, body);
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
				'Please use a "Reference" payment source to use Authorize.Net\'s "Refund" functionality.'
			);
		}

		// Build request
		CreateTransactionRequest createTransactionRequest = new CreateTransactionRequest();
		createTransactionRequest.transactionRequest.transactionType = this.transactionRequestTypesMap.get(
			TRANSACTION_REFUND
		);
		createTransactionRequest.transactionRequest.amount = getDollarAmount(amount);

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_REFUND => createTransactionRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_REFUND, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_REFUND, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_REFUND, body);
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
		CreateCustomerProfileRequest createCustomerProfileRequest = new CreateCustomerProfileRequest();

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_STORE => createCustomerProfileRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_STORE, body, source);

		// Add transaction options
		this.addOptions(TRANSACTION_STORE, body, options);

		// Send the transaction with body
		return this.request(TRANSACTION_STORE, body);
	}

	/*******************************************************************************************************
	* @description Complete an unstore which deletes a previously stored card from a previous customer.
	* Please note that if we delete the last source from a customer the customer still remains.
	* @param Token payment source which for authorize.net is in the following format; customerId::sourceId
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source, options);
	*/
	public override merchant_Response unstore(merchant_Source source, merchant_TransactionOptions options) {
		
		// First ensure token payment source
		if (!(source instanceof merchant_Source_Token)) {
			throw new Merchant.UnsupportedPaymentSourceException(
				'Please use a "Token" payment source to use Authorize.Net\'s "Unstore" functionality.'
			);
		}

		// Build request
		DeleteCustomerProfileRequest deleteCustomerProfileRequest = new DeleteCustomerProfileRequest();

		// Add request to body
		Map<String, Object> body = new Map<String, Object> {
			TRANSACTION_UNSTORE => deleteCustomerProfileRequest
		};

		// Add payment source
		this.addSource(TRANSACTION_UNSTORE, body, source);

		// Send the transaction with body
		return this.request(TRANSACTION_UNSTORE, body);
	}

	/*******************************************************************************************************
	* @description Add payment source to transaction body by parsing the source object/parameter
	* @param Request body to populate with payment source
	* @param The payment source to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* gateway.addSource('purchase', body, source);
	*/
	private void addSource(String action, Map<String, Object> body, merchant_Source source) {
		if (source instanceof merchant_Source_Card) {
			this.addSourceCard(action, body, (merchant_Source_Card)source);
		} else if (source instanceof merchant_Source_Bank) {
			this.addSourceBank(action, body, (merchant_Source_Bank)source);
		} else if (source instanceof merchant_Source_Token) {
			this.addSourceToken(action, body, (merchant_Source_Token)source);
		} else if (source instanceof merchant_Source_Reference) {
			this.addSourceReference(action, body, (merchant_Source_Reference)source);
		}
	}

	/*******************************************************************************************************
	* @description Add card payment source to transaction body by parsing the source object/parameter
	* @param Request body map to populate with payment source
	* @param The card payment source to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* gateway.addSourceCard('purchase', body, source);
	*/
	private void addSourceCard(String action, Map<String, Object> body, merchant_Source_Card source) {
		
		// Handle create customer profile requests
		if(action == TRANSACTION_STORE) {
			
			// Create customer profile request handle
			CreateCustomerProfileRequest createCustomerProfileRequest = (
				(CreateCustomerProfileRequest)body.get(action)
			);

			// Create new customer profile
			Profile customerProfile = new Profile();
			customerProfile.paymentProfiles = new PaymentProfiles();

			// Create new credit card
			CreditCard creditCard = new CreditCard(source);

			// Create new payment from credit card
			Payment payment = new Payment(creditCard);

			// Create new bill to
			BillTo billTo = new BillTo(source);

			// Add bill to to customer payment profiles
			customerProfile.paymentProfiles.billTo = billTo;

			// Add payment to customer payment profiles
			customerProfile.paymentProfiles.payment = payment;
			
			// Add customer profile to request
			createCustomerProfileRequest.profile = customerProfile;
		} else {

			// Create transaction request handle
			CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

			// Create new credit card
			CreditCard creditCard = new CreditCard(source);

			// Create new payment from credit card
			Payment payment = new Payment(creditCard);

			// Create new bill to
			BillTo billTo = new BillTo(source);

			// Add payment to request
			createTransactionRequest.transactionRequest.payment = payment;

			// Add bill to address to request
			createTransactionRequest.transactionRequest.billTo = billTo;
		}
	}

	/*******************************************************************************************************
	* @description Add bank payment source to transaction body by parsing the source object/parameter
	* @param Request body map to populate with payment source
	* @param The bank payment source to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* gateway.addSourceBank('purchase', body, source);
	*/
	private void addSourceBank(String action, Map<String, Object> body, merchant_Source_Bank source) {
		
		// Handle create customer profile requests
		if(action == TRANSACTION_STORE) {
			
			// Create customer profile request handle
			CreateCustomerProfileRequest createCustomerProfileRequest = (
				(CreateCustomerProfileRequest)body.get(action)
			);

			// Create new customer profile
			Profile customerProfile = new Profile();
			customerProfile.paymentProfiles = new PaymentProfiles();

			// Create new bank account
			BankAccount bankAccount = new BankAccount(source);

			// Convert bank account type from label to key
			bankAccount.accountType = this.supportedBankAccountTypesMap.get(bankAccount.accountType);

			// Figure out echeck type.
			// Reference Below:
			// https://www.authorize.net/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm
			if(bankAccount.accountType == BANK_ACCOUNT_TYPE_BUSINESS_CHECKING) {
				bankAccount.echeckType = ECHECK_TYPE_CCD;
			} else {
				bankAccount.echeckType = ECHECK_TYPE_PPD;
			}

			// Create new payment from bank account
			Payment payment = new Payment(bankAccount);

			// Add payment to customer payment profiles
			customerProfile.paymentProfiles.payment = payment;
			
			// Add customer profile to request
			createCustomerProfileRequest.profile = customerProfile;
		} else {

			// Create transaction request handle
			CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

			// Create new bank account
			BankAccount bankAccount = new BankAccount(source);

			// Convert bank account type from label to key
			bankAccount.accountType = this.supportedBankAccountTypesMap.get(bankAccount.accountType);

			// Figure out echeck type.
			// Reference Below:
			// https://www.authorize.net/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm
			if(bankAccount.accountType == BANK_ACCOUNT_TYPE_BUSINESS_CHECKING) {
				bankAccount.echeckType = ECHECK_TYPE_CCD;
			} else if (action == TRANSACTION_REFUND) {
				bankAccount.echeckType = ECHECK_TYPE_PPD;
			} else {
				bankAccount.echeckType = DEFAULT_ECHECK_TYPE;
			}

			// Create new payment from bank account
			Payment payment = new Payment(bankAccount);

			// Add payment to request
			createTransactionRequest.transactionRequest.payment = payment;
		}
	}

	/*******************************************************************************************************
	* @description Add reference payment source to transaction body by parsing the source object/parameter
	* @param Parameters map to populate with payment source
	* @param The reference payment source to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* gateway.addSourceReference('authorize', body, source);
	*/
	private void addSourceReference(String action, Map<String, Object> body, merchant_Source_Reference source) {
		
		// TODO: Refactor the code below to store reference as JSON instead of just a :: delimited string

		// Create transaction request handle
		CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);

		// Parse reference
		String refTransId;
		String accountNumber;
		String expirationDate;
		String accountType;
		String routingNumber;
		String nameOnAccount;
		String bankName;
		Boolean isCardSource = true;
		if(source.reference.contains('::')) {
			List<String> referenceParts = source.reference.split('::');
			if (referenceParts.size() > 0) refTransId = referenceParts[0];
			if (referenceParts.size() > 1) accountNumber = referenceParts[1];
			if (referenceParts.size() > 5) {
				accountType = referenceParts[2];
				routingNumber = referenceParts[3];
				nameOnAccount = referenceParts[4];
				bankName = referenceParts[5];

				// If more than 5 reference parts exists then this is definitely a bank payment source
				isCardSource = false;
			} else if (referenceParts.size() > 2) {
				expirationDate = referenceParts[2];
			}
		} else {
			refTransId = source.reference;
		}

		// Add transaction reference id
		createTransactionRequest.transactionRequest.refTransId = refTransId;

		// Add payment for refunds
		if(action == TRANSACTION_REFUND && String.isNotBlank(accountNumber)) {
			Payment payment;
			if(isCardSource) {
				
				// Create new credit card
				CreditCard creditCard = new CreditCard();
				creditCard.cardNumber = accountNumber;
				creditCard.expirationDate = expirationDate;

				// Create new payment from credit card
				payment = new Payment(creditCard);
			} else {

				// Create new bank account
				BankAccount bankAccount = new BankAccount();
				bankAccount.accountType = accountType;
				bankAccount.routingNumber = routingNumber;
				bankAccount.accountNumber = accountNumber;
				bankAccount.nameOnAccount = nameOnAccount;
				bankAccount.bankName = bankName;

				// PPD seems to be required for bank refunds
				bankAccount.echeckType = ECHECK_TYPE_PPD;

				// Create new payment from bank account
				payment = new Payment(bankAccount);
			}

			// Add payment to request
			createTransactionRequest.transactionRequest.payment = payment;
		}
	}

	/*******************************************************************************************************
	* @description Add token payment source to transaction body by parsing the source object/parameter
	* @param body map to populate with payment source
	* @param The token payment source to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* gateway.addSourceToken('purchase', body, source);
	*/
	private void addSourceToken(String action, Map<String, Object> body, merchant_Source_Token source) {
		
		// Create delete customer profile request handle
		DeleteCustomerProfileRequest deleteCustomerProfileRequest = (
			(DeleteCustomerProfileRequest)body.get(action)
		);
		deleteCustomerProfileRequest.customerProfileId = source.token;
	}

	/*******************************************************************************************************
	* @description Add transaction options to transaction body by parsing the options parameter
	* @param Gateway transaction action
	* @param body map to populate with transaction options
	* @param The options parameter to parse
	* @example
	* Map<String, Object> body = new Map<String, Object>();
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	* gateway.addOptions('purchase', body, options);
	*/
	private void addOptions(String action, Map<String, Object> body, merchant_TransactionOptions options) {
		
		// Handle create customer profile requests
		if(action == TRANSACTION_STORE) {

			// Create customer profile request handle
			CreateCustomerProfileRequest createCustomerProfileRequest = (
				(CreateCustomerProfileRequest)body.get(action)
			);

			// Add merchant assigned id
			createCustomerProfileRequest.profile.merchantCustomerId = options.customer;

			// Add description
			createCustomerProfileRequest.profile.description = options.description;

			// Add customer email
			createCustomerProfileRequest.profile.email = options.email;

			// At least one of the fields above must be filled in otherwise the store request will fail
			if(
				String.isBlank(options.customer) &&
				String.isBlank(options.description) &&
				String.isBlank(options.email)
			) {
				
				// Set merchant customer id using reference id
				createCustomerProfileRequest.profile.merchantCustomerId = createCustomerProfileRequest.refId;
			}

			// Add bill to options
			createCustomerProfileRequest.profile.paymentProfiles.billTo.addOptions(options);

			// Add ship to options
			ShipTo shipTo = new ShipTo(options);
			createCustomerProfileRequest.profile.shipToList.add(shipTo);
		} else {

			// Create transaction request handle
			CreateTransactionRequest createTransactionRequest = (CreateTransactionRequest)body.get(action);
			
			// Add order options
			Order order = new Order(options);
			createTransactionRequest.transactionRequest.order = order;

			// Add customer options
			Customer customer = new Customer(options);
			createTransactionRequest.transactionRequest.customer = customer;

			// Add bill to options
			createTransactionRequest.transactionRequest.billTo.addOptions(options);

			// Add ship to options
			ShipTo shipTo = new ShipTo(options);
			createTransactionRequest.transactionRequest.shipTo = shipTo;
		}
	}

	/*******************************************************************************************************
	* @description Commit gateway transaction request
	* @param Gateway transaction action
	* @param Gateway http request body
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.request(action, body);
	*/
	public override merchant_Response request(String action, Map<String, Object> body) {

		// Set the API endpoint for use with this request		
		String endpoint = this.endpoint(action, body);

		// Set the API request method (POST, GET, PUT, etc...)
		String method = this.transactionEndpointsMap.get(action).get('method');

		// API credentials are added to the request payload; adding dummy credentials for emphasis.
		merchant_Request.HttpCredentials credentials;
		credentials = new merchant_Request.HttpCredentials('payload', 'payload');

		// Setup http request payload
		String payload = this.payload(action, body);
		
		// Setup request http content with the above generated payload
		merchant_Request.HttpContent content = new merchant_Request.HttpContent('application/json', payload);
		
		// Create and execute merchant request
		merchant_Request request = new merchant_Request(credentials, endpoint, method, content, action);

		// Return standard merchant response object
		return this.response(action, body, request.execute());
	}

	/*******************************************************************************************************
	 * Convenience Methods
	 */


	 /*******************************************************************************************************
	 * @description Get given amount in cents in dollars
	 * @param Amount in cents
	 * @return Amount converted to dollars
	 * @example
	 * Decimal dollarAmount = gateway.getDollarAmount(100);
	 */
	 private Decimal getDollarAmount(Integer amount) {
	 	return (
			(amount != null && amount != 0) ?
			amount / 100 :
			0.00
		);
	 }

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
	* @param Gateway http request body; optional.
	* @return Fully built API endpoint URL
	* @example
	* String endpoint = gateway.endpoint('purchase', null);
	*/
	private String endpoint(String action, Map<String, Object> body) {
		String endpoint = null;
		endpoint = this.apiURL + this.transactionEndpointsMap.get(action).get('url');
		return endpoint;
	}

	/*******************************************************************************************************
	* @description Convenience method for building the HTTP request payload
	* @param Gateway transaction action
	* @param Gateway http request body
	* @return Return stringified payload
	* @example
	* HttpRequest request = new HttpRequest();
	* String payload = gateway.payload('purchase', body);
	* request.setBody(payload);
	*/
	private String payload(String action, Map<String, Object> body) {

		// Build request body/payload
		String payload = '';
		
		// Setup gateway/merchant authentication as all transactions require authentication
		MerchantAuthentication merchantAuthentication;
		merchantAuthentication = new MerchantAuthentication(this.login,	this.password);

		// Handle each transaction action
		if(action == TRANSACTION_VERIFY) {

			// Grab/Cast transaction request
			AuthenticateTestRequest authenticationTestRequest;
			authenticationTestRequest = (AuthenticateTestRequest)body.get(TRANSACTION_VERIFY);

			// Add request authentication
			authenticationTestRequest.merchantAuthentication = merchantAuthentication;

			// Get payload
			payload = authenticationTestRequest.serialize();
		} else if (action == TRANSACTION_STORE) {

			// Grab/Cast create customer profile request
			CreateCustomerProfileRequest createCustomerProfileRequest;
			createCustomerProfileRequest = (CreateCustomerProfileRequest)body.get(action);

			// Add request authentication
			createCustomerProfileRequest.merchantAuthentication = merchantAuthentication;

			// Get payload
			payload = createCustomerProfileRequest.serialize();
		} else if (action == TRANSACTION_UNSTORE) {

			// Grab/Cast delete customer profile request
			DeleteCustomerProfileRequest deleteCustomerProfileRequest;
			deleteCustomerProfileRequest = (DeleteCustomerProfileRequest)body.get(action);

			// Add request authentication
			deleteCustomerProfileRequest.merchantAuthentication = merchantAuthentication;

			// Get payload
			payload = deleteCustomerProfileRequest.serialize();
		} else {

			// Grab/Cast transaction request
			CreateTransactionRequest createTransactionRequest;
			createTransactionRequest = (CreateTransactionRequest)body.get(action);

			// Add request authentication
			createTransactionRequest.merchantAuthentication = merchantAuthentication;

			// Get payload
			payload = createTransactionRequest.serialize();
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
			
			// Remove 'ZERO WIDTH NO-BREAK SPACE' Unicode character if present
			if(body.codePointAt(0) == 65279) {
				body = body.replace('\uFEFF', '');
			}

			// Deserialize response into a generic map for easily working with the data
			parsed = (Map<String, Object>)JSON.deserializeUntyped(body);
			
			/**
			 * Deserialize Various Responses
			 */

			// Handle verify transactions
			if(action == TRANSACTION_VERIFY) {
				AuthenticateTestResponse authenticationTestResponse;
				authenticationTestResponse = (AuthenticateTestResponse)JSON.deserialize(
					body,
					merchant_Gateway_AuthorizeDotNet.AuthenticateTestResponse.class
				);
				parsed.put('messages', authenticationTestResponse.messages);
			}

			// Handle store transactions
			else if (action == TRANSACTION_STORE) {
				CreateCustomerProfileResponse createCustomerProfileResponse;
				createCustomerProfileResponse = (CreateCustomerProfileResponse)JSON.deserialize(
					body,
					merchant_Gateway_AuthorizeDotNet.CreateCustomerProfileResponse.class
				);
				parsed.put('messages', createCustomerProfileResponse.messages);
			}

			// Handle unstore transactions
			else if (action == TRANSACTION_UNSTORE) {
				DeleteCustomerProfileResponse deleteCustomerProfileResponse;
				deleteCustomerProfileResponse = (DeleteCustomerProfileResponse)JSON.deserialize(
					body,
					merchant_Gateway_AuthorizeDotNet.DeleteCustomerProfileResponse.class
				);
				parsed.put('messages', deleteCustomerProfileResponse.messages);
			}

			// Handle all other payment transactions
			else {
				CreateTransactionResponse createTransactionResponse;
				createTransactionResponse = (CreateTransactionResponse)JSON.deserialize(
					body,
					merchant_Gateway_AuthorizeDotNet.CreateTransactionResponse.class
				);
				parsed.put('messages', createTransactionResponse.messages);
				parsed.put('transactionResponse', createTransactionResponse.transactionResponse);
			}
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
	* @description Convenience method for figuring out if transaction was successful or not
	* @param Gateway transaction action
	* @param Parsed HTTP response body
	* @return Whether or not transaction was successful
	* @example
	* Boolean success = gateway.success('purchase', parsedResponse);
	*/
	private Boolean success(String action, Map<String, Object> parsedResponse) {
		
		// Default success to false
		Boolean success = false;

		// If response doesn't included messages then something went wrong
		if(!parsedResponse.containsKey('messages')) return success;

		// Cast api response messages
		Messages responseMessages = (Messages)parsedResponse.get('messages');
		
		// Check if api request was successful
		if (responseMessages.resultCode == API_RESULT_CODE_OK) {

			// Account for customer profile transactions
			if(action == TRANSACTION_STORE || action == TRANSACTION_UNSTORE) {
				
				// Mark store transaction successful
				success = true;
			} else {

				// If response doesn't included transaction response then something went wrong
				if(!parsedResponse.containsKey('transactionResponse')) return success;
				
				// Cast transaction response
				TransactionResponse transactionResponse = (
					(TransactionResponse)parsedResponse.get('transactionResponse')
				);

				// Check if the actual payment transaction was successful
				if(transactionResponse.responseCode == RESPONSE_CODE_APPROVED) {
					
					// Mark transaction successful
					success = true;
				}
			}
		}
		
		// Return transaction success result
		return success;
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
		
		// Default null code
		String code = null;

		// If response doesn't included messages then something went wrong
		if(!parsedResponse.containsKey('messages')) return code;

		// Cast api response messages
		Messages responseMessages = (Messages)parsedResponse.get('messages');

		// Check if api request failed
		if (responseMessages.resultCode == API_RESULT_CODE_ERROR) {
			
			// Check for transaction error
			if(parsedResponse.get('transactionResponse') != null) {

				// Cast transaction response
				TransactionResponse transactionResponse = (
					(TransactionResponse)parsedResponse.get('transactionResponse')
				);

				// Set response code
				code = this.standardResponseCodesMap.get(transactionResponse.responseCode);

				// Set more detailed response code
				if(transactionResponse.responseCode != RESPONSE_CODE_APPROVED) {
					
					// Process first transaction response error if code still hasn't been figured out
					if(
						transactionResponse.errors != null &&
						transactionResponse.errors.size() > 0
					) {
						TransactionResponseError transactionResponseError = transactionResponse.errors[0];
						code = standardResponseCodesMap.get(transactionResponseError.errorCode);
					}
				}

			}

			// Process first error message if code still hasn't been figured out
			if(
				code == null &&
				responseMessages.message != null &&
				responseMessages.message.size() > 0
			) {
				Message errorMessage = responseMessages.message[0];
				code = standardResponseCodesMap.get(errorMessage.code);
			}

			// Default invalid request error
		   	if (code == null) code = 'invalid_request_error';
		}

		// Next let's check if the actual payment transaction was successful
		else {

			// Account for customer profile transactions
			if(action != TRANSACTION_STORE && action != TRANSACTION_UNSTORE) {
				
				// If response doesn't included transaction response then something went wrong
				if(!parsedResponse.containsKey('transactionResponse')) return code;
				
				// Cast transaction response
				TransactionResponse transactionResponse = (
					(TransactionResponse)parsedResponse.get('transactionResponse')
				);

				// Set response code
				code = this.standardResponseCodesMap.get(transactionResponse.responseCode);

				// Set more detailed response code
				if(transactionResponse.responseCode != RESPONSE_CODE_APPROVED) {

					// Process first transaction response error if code still hasn't been figured out
					if(
						transactionResponse.errors != null &&
						transactionResponse.errors.size() > 0
					) {
						TransactionResponseError transactionResponseError = transactionResponse.errors[0];
						code = standardResponseCodesMap.get(transactionResponseError.errorCode);
					}

				}
			}

			// Default success
	   		if (code == null) code = 'success';
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
		
		// Default null details
		String details = null;

		// If response doesn't included messages then something went wrong
		if(!parsedResponse.containsKey('messages')) return details;

		// Cast api response messages
		Messages responseMessages = (Messages)parsedResponse.get('messages');

		// Check for transaction response
		if(parsedResponse.get('transactionResponse') != null) {

			// Cast transaction response
			TransactionResponse transactionResponse = (
				(TransactionResponse)parsedResponse.get('transactionResponse')
			);

			// Process first transaction response error message if available
			if(
				transactionResponse.errors != null &&
				transactionResponse.errors.size() > 0
			) {
				TransactionResponseError transactionResponseError = transactionResponse.errors[0];
				details = transactionResponseError.errorText;
			}

			// Process first transaction response message if available
			if(
				transactionResponse.messages != null &&
				transactionResponse.messages.size() > 0
			) {
				TransactionResponseMessage transactionResponseMessage = transactionResponse.messages[0];
				details = transactionResponseMessage.description;
			}
		}

		// Process first api response message if available, and details still hasn't been set
		if(
			details == null &&
			responseMessages.message != null &&
			responseMessages.message.size() > 0
		) {
			Message responseMessage = responseMessages.message[0];
			details = responseMessage.text;
		}

		// Default details if not yet set
		if(details == null) {
			details = (
				responseMessages.resultCode == API_RESULT_CODE_ERROR ?
				'The ' + action + ' transaction was not completed successfully' :
				'The ' + action + ' transaction completed successfully'
			);
		}
		return details;
	}

	/*******************************************************************************************************
	* @description Convenience method for obtaining the gateway transaction reference
	* @param Gateway transaction action
	* @param Gateway http request body
	* @param Parsed HTTP response body
	* @return A transaction reference
	* @example
	* String reference = gateway.message('purchase', parsedResponse);
	*/
	private String reference(String action, Map<String, Object> body, Map<String, Object> parsedResponse) {
		String reference = null;
		
		// Grab transaction reference if applicable
		if(parsedResponse.get('transactionResponse') != null) {
			TransactionResponse transactionResponse = (TransactionResponse)parsedResponse.get('transactionResponse');
			reference = transactionResponse.transId;

			// Add payment details for later use in refunds
			if(action == TRANSACTION_PURCHASE || action == TRANSACTION_AUTHORIZE) {
				
				// Add last four digits of card number
				if(String.isNotBlank(transactionResponse.accountNumber)) {
					if (transactionResponse.accountType != RESPONSE_ACCOUNT_TYPE_ECHECK) {
						
						// Remove Xs for card payments
						reference += '::' + transactionResponse.accountNumber.substringAfterLast('X');
					} else {

						// Don't remove Xs for bank payments
						reference += '::' + transactionResponse.accountNumber;
					}
				}

				// Add card expiration date if credit card transaction
				CreateTransactionRequest createTransactionRequest;
				createTransactionRequest = (CreateTransactionRequest)body.get(action);
				if (transactionResponse.accountType != RESPONSE_ACCOUNT_TYPE_ECHECK) {
					reference += '::' + createTransactionRequest.transactionRequest.payment.creditCard.expirationDate;
				} else {

					// Add additional bank details
					reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.accountType;
					reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.routingNumber;
					reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.nameOnAccount;
					reference += '::' + createTransactionRequest.transactionRequest.payment.bankAccount.bankName;
				}
			}

			// Handle void reference ids because a separate id isn't generated
			if (action == TRANSACTION_VOID) reference += '::VOID';
		} else if(parsedResponse.containsKey('customerProfileId')) {
			
			// Grab the newly stored customer profile id
			reference = (String)parsedResponse.get('customerProfileId');
		}
		
		// Catch all reference; authorize.net always returns a reference id if supplied in the request
		if (String.isBlank(reference) && String.isNotBlank(String.valueOf(parsedResponse.get('refId')))) {
			reference = String.valueOf(parsedResponse.get('refId'));
		}
		return reference;
	}

	/*******************************************************************************************************
	* @description Convenience method for building the standard gateway transaction response
	* @param Gateway transaction action
	* @param Gateway http request body
	* @param Parsed gateway transaction response
	* @return A standard gateway transaction response object
	* @example
	* merchant_Response response = gateway.response('purchase', response);
	*/
	private merchant_Response response(String action, Map<String, Object> body, HttpResponse response) {
		System.debug('*** AuthorizeDotNet RESPONSE: ' + response.getBody());

		// Grab http response body which can be later parsed
		String responseBody = response.getBody();

		// First let's parse the response
		Map<String, Object> parsedResponse = this.parse(action, responseBody);

		// Figure out if the request was successful
		Boolean success = this.success(action, parsedResponse);

		// Get request/response code
		String code = this.code(action, parsedResponse);

		// Get request/response message
		String message = this.standardResponseMessages.get(code);

		// Get request/response message details
		String details = this.details(action, parsedResponse);

		// Get transaction reference
		String reference = this.reference(action, body, parsedResponse);

		// Return standard response
		return new merchant_Response(success, code, message, details, responseBody, reference);
	}
}
/**
* @author Charles Naccio
* @date 8/26/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Gateway class is the base class for all Merchant gateway implementations.
* This abstract class should be extended by all payment gateways throughout the Merchant system.
* It defines the various common attributes and methods that all gateways should have.
*/
public with sharing abstract class merchant_Gateway {

	/*******************************************************************************************************
	* @description Gateway transaction actions
	*/
	public static final String TRANSACTION_VERIFY = 'verify';
	public static final String TRANSACTION_PURCHASE = 'purchase';
	public static final String TRANSACTION_AUTHORIZE = 'authorize';
	public static final String TRANSACTION_CAPTURE = 'capture';
	public static final String TRANSACTION_VOID = 'void';
	public static final String TRANSACTION_REFUND = 'refund';
	public static final String TRANSACTION_CREDIT = 'credit';
	public static final String TRANSACTION_STORE = 'store';
	public static final String TRANSACTION_UNSTORE = 'unstore';

	/*******************************************************************************************************
	* @description Gateway name
	*/
	public String name {get; protected set;}

	/*******************************************************************************************************
	* @description Gateway display name used for intelligent display within apps
	*/
	public String displayName {get; protected set;}

	/*******************************************************************************************************
	* @description Gateway test url for sending test requests
	*/
	public String testUrl {get; protected set;}

	/*******************************************************************************************************
	* @description Gateway live url for sending requests
	*/
	public String liveUrl {get; protected set;}

	/*******************************************************************************************************
	* @description Gateway login. This can either be an actual login to be used with password below, 
	* or an API key; whichever is needed for authentication.
	*/
	public String login;

	/*******************************************************************************************************
	* @description Gateway password if applicable
	*/
	public String password;

	/*******************************************************************************************************
	* @description Gateway homepage url
	*/
	public String homepageUrl {get; protected set;}

	/*******************************************************************************************************
	* @description Gateway application id
	*/
	public String applicationId;

	/*******************************************************************************************************
	* @description If gateway is in test mode; defaults to false.
	*/
	public String testMode = 'false';

	/*******************************************************************************************************
	* @description Default currency. You need to set the default currency of the gateway if the gateway 
	* supports multiple currencies.
	*/
	public String defaultCurrency {get {return defaultCurrency == null ? 'USD' : defaultCurrency;} set;}

	/*******************************************************************************************************
	* @description Payment sources supported by the gateway.
	* Payment Sources:
	*    'Card' - Credit or Debit card
	*    'Bank' - Check or ACH
	*    'Reference' - Reference from previous transaction
	*    'Token' - Previously stored payment token
	*/
	public Set<String> supportedPaymentSources {get; protected set;}

	/*******************************************************************************************************
	* @description Transactions supported by the gateway.
	* Transactions:
	*    'purchase' - Complete a purchase
	*    'authorize' - Preauth a payment
	*    'capture' - Capture a preauth
	*    'void' - Void a previous transaction
	*    'refund' - Refund a previous transaction
	*    'credit' - Credit money back to a payment source
	*    'store' - Store a payment method with gateway
	*    'unstore' - Unstore a previously stored payment method
	*/
	public Set<String> supportedTransactions {get; protected set;}

	/*******************************************************************************************************
	* @description Card types supported by the gateway
	* Card Types:
	* 	'VISA' – Visa
	* 	'MASTER' – MasterCard
	* 	'DISCOVER' – Discover Card
	* 	'AMERICAN' – American Express
	* 	'DINERS' – Diners Club
	* 	'JCB' – JCB
	* 	'SWITCH' – UK Maestro, formerly Switch
	* 	'SOLO' – Solo
	* 	'DANKORT' – Dankort
	* 	'MAESTRO' – International Maestro
	* 	'FORBURGSFORENINGEN' – Forbrugsforeningen
	* 	'LASER' – Laser
	*/
	public Set<String> supportedCardTypes {get; protected set;}

	/*******************************************************************************************************
	* @description Bank account types supported by the gateway
	* Bank Account Types:
	* 	'CHECKING' – Checking
	* 	'SAVINGS' – Savings
	*/
	public Set<String> supportedBankAccountTypes {get; protected set;}

	/*******************************************************************************************************
	* @description Countries supported by the gateway.
	* Countries:
	*    'AF' - Afghanistan
	*    'AL' - Albania
	*    'DZ' - Algeria
	*    'AS' - American Samoa
	*    'AD' - Andorra
	*    'AO' - Angola
	*    'AI' - Anguilla
	*    'AG' - Antigua and Barbuda
	*    'AR' - Argentina
	*    'AM' - Armenia
	*    'AW' - Aruba
	*    'AU' - Australia
	*    'AT' - Austria
	*    'AZ' - Azerbaijan
	*    'BS' - Bahamas
	*    'BH' - Bahrain
	*    'BD' - Bangladesh
	*    'BB' - Barbados
	*    'BY' - Belarus
	*    'BE' - Belgium
	*    'BZ' - Belize
	*    'BJ' - Benin
	*    'BM' - Bermuda
	*    'BT' - Bhutan
	*    'BO' - Bolivia
	*    'BA' - Bosnia and Herzegovina
	*    'BW' - Botswana
	*    'BV' - Bouvet Island
	*    'BR' - Brazil
	*    'IO' - British Indian Ocean Territory
	*    'BN' - Brunei Darussalam
	*    'BG' - Bulgaria
	*    'BF' - Burkina Faso
	*    'BI' - Burundi
	*    'KH' - Cambodia
	*    'CM' - Cameroon
	*    'CA' - Canada
	*    'CV' - Cape Verde
	*    'KY' - Cayman Islands
	*    'CF' - Central African Republic
	*    'TD' - Chad
	*    'CL' - Chile
	*    'CN' - China
	*    'CX' - Christmas Island
	*    'CC' - Cocos (Keeling) Islands
	*    'CO' - Colombia
	*    'KM' - Comoros
	*    'CG' - Congo
	*    'CD' - Congo, the Democratic Republic of the
	*    'CK' - Cook Islands
	*    'CR' - Costa Rica
	*    'CI' - Cote D\'Ivoire
	*    'HR' - Croatia
	*    'CU' - Cuba
	*    'CW' - Curaçao
	*    'CY' - Cyprus
	*    'CZ' - Czech Republic
	*    'DK' - Denmark
	*    'DJ' - Djibouti
	*    'DM' - Dominica
	*    'DO' - Dominican Republic
	*    'EC' - Ecuador
	*    'EG' - Egypt
	*    'SV' - El Salvador
	*    'GQ' - Equatorial Guinea
	*    'ER' - Eritrea
	*    'EE' - Estonia
	*    'ET' - Ethiopia
	*    'FK' - Falkland Islands (Malvinas)
	*    'FO' - Faroe Islands
	*    'FJ' - Fiji
	*    'FI' - Finland
	*    'FR' - France
	*    'GF' - French Guiana
	*    'PF' - French Polynesia
	*    'TF' - French Southern Territories
	*    'GA' - Gabon
	*    'GM' - Gambia
	*    'GE' - Georgia
	*    'DE' - Germany
	*    'GH' - Ghana
	*    'GI' - Gibraltar
	*    'GR' - Greece
	*    'GL' - Greenland
	*    'GD' - Grenada
	*    'GP' - Guadeloupe
	*    'GU' - Guam
	*    'GT' - Guatemala
	*    'GG' - Guernsey
	*    'GN' - Guinea
	*    'GW' - Guinea-Bissau
	*    'GY' - Guyana
	*    'HT' - Haiti
	*    'HM' - Heard Island And Mcdonald Islands
	*    'VA' - Holy See (Vatican City State)
	*    'HN' - Honduras
	*    'HK' - Hong Kong
	*    'HU' - Hungary
	*    'IS' - Iceland
	*    'IN' - India
	*    'ID' - Indonesia
	*    'IR' - Iran, Islamic Republic of
	*    'IQ' - Iraq
	*    'IE' - Ireland
	*    'IM' - Isle Of Man
	*    'IL' - Israel
	*    'IT' - Italy
	*    'JM' - Jamaica
	*    'JP' - Japan
	*    'JE' - Jersey
	*    'JO' - Jordan
	*    'KZ' - Kazakhstan
	*    'KE' - Kenya
	*    'KI' - Kiribati
	*    'KP' - Korea, Democratic People\'s Republic of
	*    'KR' - Korea, Republic of
	*    'KV' - Kosovo
	*    'KW' - Kuwait
	*    'KG' - Kyrgyzstan
	*    'LA' - Lao People\'s Democratic Republic
	*    'LV' - Latvia
	*    'LB' - Lebanon
	*    'LS' - Lesotho
	*    'LR' - Liberia
	*    'LY' - Libyan Arab Jamahiriya
	*    'LI' - Liechtenstein
	*    'LT' - Lithuania
	*    'LU' - Luxembourg
	*    'MO' - Macao
	*    'MK' - Macedonia, the Former Yugoslav Republic of
	*    'MG' - Madagascar
	*    'MW' - Malawi
	*    'MY' - Malaysia
	*    'MV' - Maldives
	*    'ML' - Mali
	*    'MT' - Malta
	*    'MH' - Marshall Islands
	*    'MQ' - Martinique
	*    'MR' - Mauritania
	*    'MU' - Mauritius
	*    'YT' - Mayotte
	*    'MX' - Mexico
	*    'FM' - Micronesia, Federated States of
	*    'MD' - Moldova, Republic of
	*    'MC' - Monaco
	*    'MN' - Mongolia
	*    'ME' - Montenegro
	*    'MS' - Montserrat
	*    'MA' - Morocco
	*    'MZ' - Mozambique
	*    'MM' - Myanmar
	*    'NA' - Namibia
	*    'NR' - Nauru
	*    'NP' - Nepal
	*    'NL' - Netherlands
	*    'AN' - Netherlands Antilles
	*    'NC' - New Caledonia
	*    'NZ' - New Zealand
	*    'NI' - Nicaragua
	*    'NE' - Niger
	*    'NG' - Nigeria
	*    'NU' - Niue
	*    'NF' - Norfolk Island
	*    'MP' - Northern Mariana Islands
	*    'NO' - Norway
	*    'OM' - Oman
	*    'PK' - Pakistan
	*    'PW' - Palau
	*    'PS' - Palestinian Territory, Occupied
	*    'PA' - Panama
	*    'PG' - Papua New Guinea
	*    'PY' - Paraguay
	*    'PE' - Peru
	*    'PH' - Philippines
	*    'PN' - Pitcairn
	*    'PL' - Poland
	*    'PT' - Portugal
	*    'PR' - Puerto Rico
	*    'QA' - Qatar
	*    'RE' - Reunion
	*    'RO' - Romania
	*    'RU' - Russian Federation
	*    'RW' - Rwanda
	*    'BL' - Saint Barthélemy
	*    'SH' - Saint Helena
	*    'KN' - Saint Kitts and Nevis
	*    'LC' - Saint Lucia
	*    'MF' - Saint Martin (French part)
	*    'PM' - Saint Pierre and Miquelon
	*    'VC' - Saint Vincent and the Grenadines
	*    'WS' - Samoa
	*    'SM' - San Marino
	*    'ST' - Sao Tome and Principe
	*    'SA' - Saudi Arabia
	*    'SN' - Senegal
	*    'RS' - Serbia
	*    'SC' - Seychelles
	*    'SL' - Sierra Leone
	*    'SG' - Singapore
	*    'SK' - Slovakia
	*    'SI' - Slovenia
	*    'SB' - Solomon Islands
	*    'SO' - Somalia
	*    'ZA' - South Africa
	*    'GS' - South Georgia and the South Sandwich Islands
	*    'ES' - Spain
	*    'LK' - Sri Lanka
	*    'SD' - Sudan
	*    'SR' - Suriname
	*    'SJ' - Svalbard and Jan Mayen
	*    'SZ' - Swaziland
	*    'SE' - Sweden
	*    'CH' - Switzerland
	*    'SY' - Syrian Arab Republic
	*    'TW' - Taiwan, Province of China
	*    'TJ' - Tajikistan
	*    'TZ' - Tanzania, United Republic of
	*    'TH' - Thailand
	*    'TL' - Timor Leste
	*    'TG' - Togo
	*    'TK' - Tokelau
	*    'TO' - Tonga
	*    'TT' - Trinidad and Tobago
	*    'TN' - Tunisia
	*    'TR' - Turkey
	*    'TM' - Turkmenistan
	*    'TC' - Turks and Caicos Islands
	*    'TV' - Tuvalu
	*    'UG' - Uganda
	*    'UA' - Ukraine
	*    'AE' - United Arab Emirates
	*    'GB' - United Kingdom
	*    'US' - United States
	*    'UM' - United States Minor Outlying Islands
	*    'UY' - Uruguay
	*    'UZ' - Uzbekistan
	*    'VU' - Vanuatu
	*    'VE' - Venezuela
	*    'VN' - Viet Nam
	*    'VG' - Virgin Islands, British
	*    'VI' - Virgin Islands, U.S.
	*    'WF' - Wallis and Futuna
	*    'EH' - Western Sahara
	*    'YE' - Yemen
	*    'ZM' - Zambia
	*    'ZW' - Zimbabwe
	*    'AX' - Åland Islands
	*/
	public Set<String> supportedCountries {get; protected set;}

	/*******************************************************************************************************
	* @description Options required to create this gateway
	*/
	public Set<String> requiredOptions;

	/*******************************************************************************************************
	* @description All configurable gateway options
	*/
	public Set<String> allOptions {
		get {
			return new Set<String> {
				'login',
				'password',
				'applicationId',
				'testMode'
			};
		}
		private set;
	}

	/*******************************************************************************************************
	* @description Standard gateway response codes used to provide consistency across all gateways
	*/
	public Map<String, String> standardResponseCodes {
		get {
			return new Map<String, String> {
				'success' => 'success',
				'authentication_error' => 'authentication_error',
				'incorrect_number' => 'incorrect_number',
				'incorrect_account_info' => 'incorrect_account_info',
				'incorrect_routing_number' => 'incorrect_routing_number',
		        'incorrect_account_number' => 'incorrect_account_number',
		        'incorrect_check_number' => 'incorrect_check_number',
		        'invalid_number' => 'invalid_number',
		        'invalid_account_info' => 'invalid_account_info',
		        'invalid_routing_number' => 'invalid_routing_number',
		        'invalid_account_number' => 'invalid_account_number',
		        'invalid_check_number' => 'invalid_check_number',
		        'invalid_expiry_date' => 'invalid_expiry_date',
		        'invalid_cvc' => 'invalid_cvc',
		        'expired_card' => 'expired_card',
		        'incorrect_cvc' => 'incorrect_cvc',
		        'incorrect_zip' => 'incorrect_zip',
		        'incorrect_address' => 'incorrect_address',
		        'incorrect_pin' => 'incorrect_pin',
		        'card_declined' => 'card_declined',
		        'processing_error' => 'processing_error',
		        'invalid_request_error' => 'invalid_request_error',
		        'call_issuer' => 'call_issuer',
		        'pickup_card' => 'pickup_card',
		        'expired_auth' => 'expired_auth',
		        'held_for_review' => 'held_for_review'
			};
		}
		private set;
	}

	/*******************************************************************************************************
	* @description Standard gateway response messages used to provide consistent response messages across all
	* gateways.
	*/
	public Map<String, String> standardResponseMessages {
		get {
			return new Map<String, String> {
				'success' => 'Transaction was successful',
				'authentication_error' => 'Gateway authentication failed',
				'incorrect_number' => 'Card number is incorrect',
				'incorrect_account_info' => 'Bank account info was not matched by processor (name on account, type, etc...)',
				'incorrect_routing_number' => 'Bank routing number is incorrect',
				'incorrect_account_number' => 'Bank account number is incorrect',
				'incorrect_check_number' => 'Check number is incorrect',
				'invalid_number' => 'Card number is not a valid credit card number',
				'invalid_account_info' => 'Bank account info invalid (name on account, type, etc...)',
				'invalid_routing_number' => 'Bank routing number is not a valid routing number',
				'invalid_account_number' => 'Bank account number is not a valid account number',
				'invalid_check_number' => 'Check number is invalid',
				'invalid_expiry_date' => 'Expiry date does not match correct formatting',
				'invalid_cvc' => 'Security codes does not match correct format (3-4 digits)',
				'expired_card' => 'Card number is expired',
				'incorrect_cvc' => 'Security code was not matched by the processor',
				'incorrect_zip' => 'Zip code is not in correct format',
				'incorrect_address' => 'Billing address info was not matched by the processor',
				'incorrect_pin' => 'Card PIN is incorrect',
				'card_declined' => 'Card number declined by processor',
				'processing_error' => 'Processor error',
				'invalid_request_error' => 'An invalid request was sent to the payment provider',
				'call_issuer' => 'Transaction requires voice authentication, call issuer',
				'pickup_card' => 'Issuer requests that you pickup the card from merchant',
				'expired_auth' => 'Authorization has expired, and cannot be captured',
				'held_for_review' => 'Transaction is being held for review, and must be manually approved by merchant.'
			};
		}
		private set;
	}

	/*******************************************************************************************************
	* @description Initialize new gateway instance
	* @example
	* merchant_Gateway_* gateway = new merchant_Gateway_*();
	*/
	protected merchant_Gateway() {
		// Do something
	}

	/*******************************************************************************************************
	* @description Validate that required gateway options exists in gateway options parameter
	* @param Gateway options
	* @example
	* gateway.validateRequiredOptions(options);
	*/
	public virtual void validateRequiredOptions(Map<String, Object> options) {
		if (this.requiredOptions != null) {
			Set<String> requiredOptions = new Set<String>(this.requiredOptions);
			requiredOptions.removeAll(options.keySet());
			for (String option : requiredOptions) {
				throw new Merchant.RequiredOptionMissingException('Missing required gateway option: "' + option + '"');
			}
		}
	}	

	/*******************************************************************************************************
	* @description Set gateway options; unknown options are ignored.
	* @param gateway options
	* @example
	* gateway.set(new Map<String, Object> {
	* 	'name' => 'Stripe',
	* 	'testMode' => 'true'
	* });
	*/
	public virtual void set(Map<String, Object> options) {
		for (String name : options.keySet()) {
			if (name == 'login') this.login = (String)options.get(name);
			if (name == 'password') this.password = (String)options.get(name);
			if (name == 'applicationId') this.applicationId = (String)options.get(name);
			if (name == 'testMode') this.testMode = (String)options.get(name);
		}
	}

	/*******************************************************************************************************
	* @description Verify gateway connectivity/readiness
	* @return True if interaction with gateway was successful; otherwise false.
	* @example
	* Boolean gatewayVerified = gateway.verify();
	*/
	public abstract Boolean verify();

	/*******************************************************************************************************
	* @description Complete a purchase
	* @param Purchase amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.purchase(100, source, options);
	*/
	public abstract merchant_Response purchase(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a authorize
	* @param Authorize amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.authorize(100, source, options);
	*/
	public abstract merchant_Response authorize(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a capture
	* @param Capture amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.capture(100, source, options);
	*/
	public abstract merchant_Response capture(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a void
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.void(source, options);
	*/
	public abstract merchant_Response void(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a refund
	* @param Refund amount
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.refund(100, source, options);
	*/
	public abstract merchant_Response refund(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a credit
	* @param Credit amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.credit(100, source, options);
	*/
	public abstract merchant_Response credit(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a store
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.store(source, options);
	*/
	public abstract merchant_Response store(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a unstore
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.unstore(source, options);
	*/
	public abstract merchant_Response unstore(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Send gateway transaction request
	* @param Gateway transaction action
	* @param Transaction parameters
	* @return Gateway response
	* @example
	* merchant_Response response = gateway.request(action, parameters);
	*/
	public abstract merchant_Response request(String action, Map<String, Object> parameters);
}
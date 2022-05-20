/**
* @author Charles Naccio
* @date 8/26/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Card payment source class defines and abstracts all card source payment types used
* throughout the Merchant library. 
*/
public with sharing class merchant_Source_Card extends merchant_Source {
	
	/*******************************************************************************************************
	* @description Card brand/type (visa, master card, etc...)
	*/
	public String brand;

	/*******************************************************************************************************
	* @description Card number
	*/
	public String cardNumber;

	/*******************************************************************************************************
	* @description Card expiration month
	*/
	public String month;

	/*******************************************************************************************************
	* @description Card expiration year
	*/
	public String year;

	/*******************************************************************************************************
	* @description Card start month
	*/
	public String startMonth;

	/*******************************************************************************************************
	* @description Card start year
	*/
	public String startYear;

	/*******************************************************************************************************
	* @description Card security code
	*/
	public String cvv;

	/*******************************************************************************************************
	* @description Card issue number required for some gateways
	*/
	public String issueNumber;

	/*******************************************************************************************************
	* @description Card billing company name
	*/
	public String company;

	/*******************************************************************************************************
	* @description Card billing first name
	*/
	public String firstName;

	/*******************************************************************************************************
	* @description Card billing last name
	*/
	public String lastName;

	/*******************************************************************************************************
	* @description Card billing full name
	*/
	public String fullName {
		get {
			this.fullName = this.getFullName();
			return this.fullName;
		}
		set;
	}


	/*******************************************************************************************************
	* @description Card billing address line 1
	*/
	public String address1;

	/*******************************************************************************************************
	* @description Card billing address line 2
	*/
	public String address2;

	/*******************************************************************************************************
	* @description Card billing city
	*/
	public String city;

	/*******************************************************************************************************
	* @description Card billing postal/zip code
	*/
	public String postalCode;

	/*******************************************************************************************************
	* @description Card billing state/province
	*/
	public String state;

	/*******************************************************************************************************
	* @description Card billing country
	*/
	public String country;

	/*******************************************************************************************************
	* @description Card billing phone
	*/
	public String phone;

	/*******************************************************************************************************
	* @description Initialize new card payment source
	* @example
	* merchant_Source_Card card = new merchant_Source_Card();
	*/
	public merchant_Source_Card() {
		this.name = 'Card';
		this.allOptions = new Set<String> {
			'brand',
			'cardNumber',
			'month',
			'year',
			'startMonth',
			'startYear',
			'cvv',
			'issueNumber',
			'company',
			'firstName',
			'lastName',
			'address1',
			'address2',
			'city',
			'postalCode',
			'state',
			'country',
			'phone'
		};
		this.requiredOptions = new Set<String> {
			'firstName',
			'lastName',
			'cardNumber',
			'month',
			'year',
			'cvv',
			'postalCode'
		};
	}

	/*******************************************************************************************************
	* @description Validate that required payment source options exists in payment source options parameter
	* @param Payment source options
	* @example
	* source.validateRequiredOptions(options);
	*/
	public override void validateRequiredOptions(Map<String, Object> options) {
		if (this.requiredOptions != null) {
			Set<String> requiredOptions = new Set<String>(this.requiredOptions);
			requiredOptions.removeAll(options.keySet());
			for (String option : requiredOptions) {

				// Account for either/or values
				if(option == 'firstName' && String.isNotBlank(this.fullName)) continue;
				if(option == 'lastName' && String.isNotBlank(this.fullName)) continue;

				String errorMsg = 'Missing required payment source option: "' + option + '"';
				throw new Merchant.RequiredOptionMissingException(errorMsg);
			}
		}
	}

	/*******************************************************************************************************
	* @description Set card options; unknown options are ignored.
	* @param Card options
	* @example
	* card.set(new Map<String, Object> {
	* 	'company' => 'Workless, LLC',
	* 	'firstName' => 'Charles',
	* 	'lastName' => 'Naccio',
	* 	'cardNumber' => '4444333322221111',
	* 	'cvv' => '123',
	* 	'month' => '12',
	* 	'year' => '2017',
	* 	'postalCode' => '75070'
	* });
	*/
	public override void set(Map<String, Object> options) {
		for (String name : options.keySet()) {
			if (name == 'brand') this.brand = (String)options.get(name);
			if (name == 'cardNumber') this.cardNumber = (String)options.get(name);
			if (name == 'month') this.month = (String)options.get(name);
			if (name == 'year') this.year = (String)options.get(name);
			if (name == 'startMonth') this.startMonth = (String)options.get(name);
			if (name == 'startYear') this.startYear = (String)options.get(name);
			if (name == 'cvv') this.cvv = (String)options.get(name);
			if (name == 'issueNumber') this.issueNumber = (String)options.get(name);
			if (name == 'company') this.company = (String)options.get(name);
			if (name == 'firstName') this.firstName = (String)options.get(name);
			if (name == 'lastName') this.lastName = (String)options.get(name);
			if (name == 'fullName') this.fullName = (String)options.get(name);
			if (name == 'address1') this.address1 = (String)options.get(name);
			if (name == 'address2') this.address2 = (String)options.get(name);
			if (name == 'city') this.city = (String)options.get(name);
			if (name == 'postalCode') this.postalCode = (String)options.get(name);
			if (name == 'state') this.state = (String)options.get(name);
			if (name == 'country') this.country = (String)options.get(name);
			if (name == 'phone') this.phone = (String)options.get(name);
		}
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of bank account number.
	* @return Last 4 digits/characters of bank account number.
	* @example
	* bank.getLastFour();
	*/
	public override String getLastFour() {
		String lastFour = this.cardNumber.right(4);
		return lastFour;
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of bank account number masked.
	* @return Masked bank account number except for the last 4 digits/characters
	* @example
	* bank.getLastFourMasked();
	*/
	public override String getLastFourMasked() {
		return getLastFourMasked('X');
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of bank account number masked with provided
	* masking character.
	* @param Masking character
	* @return Masked bank account number except for the last 4 digits/characters
	* @example
	* bank.getLastFourMasked('*');
	*/
	public override String getLastFourMasked(String mask) {
		if (mask == null) mask = 'X';
		Integer maskLength = this.cardNumber.length() -4;
		String cardNumberMasked = mask.repeat(maskLength) + this.getLastFour();
		return cardNumberMasked;
	}

	/*******************************************************************************************************
	* @description Get the full card billing name
	* @return The full billing card name
	* @example
	* String fullCardName = card.getFullName();
	*/
	private String getFullName() {
		String fullName = '';
		if(String.isNotBlank(this.firstName) || String.isNotBlank(this.lastName)) {
			fullName = (
				String.isEmpty(this.lastName) ?
				this.firstName :
				(
					String.isEmpty(this.firstName) ? this.lastName : this.firstName + ' ' + this.lastName
				)
			);
		}
		return fullName;
	}
}
/**
* @author Charles Naccio
* @date 9/13/2015
*
* @group "Merchant"
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description Standard gateway transaction options class. By using a set of standard options for every gateway 
* transaction it allows for changing the underlying gateway without having to change any code, or how the gateway 
* transaction options are setup, or used.
*/
public with sharing class merchant_TransactionOptions {
	
	/*******************************************************************************************************
	* @description Transaction currency. Please note that currencie is misspelled on purpose because 
	* "currency" is a reserved word.
	*/
	public String currencie;

	/*******************************************************************************************************
	* @description Transaction order id
	*/
	public String orderId;

	/*******************************************************************************************************
	* @description Transaction ip address
	*/
	public String ip;

	/*******************************************************************************************************
	* @description Transaction customer
	*/
	public String customer;

	/*******************************************************************************************************
	* @description Transaction invoice
	*/
	public String invoice;

	/*******************************************************************************************************
	* @description Transaction merchant
	*/
	public String merchant;

	/*******************************************************************************************************
	* @description Indication that the merchant transfer should be reversed, or not when refunding a purchase.
	*/
	public String reverseMerchant;

	/*******************************************************************************************************
	* @description Transaction merchant fee in cents. i.e. $1.00 would be 100
	*/
	public String merchantFee;

	/*******************************************************************************************************
	* @description Indication that the merchant fee should be refunded, or not when refunding a purchase.
	*/
	public String refundMerchantFee;

	/*******************************************************************************************************
	* @description Transaction description
	*/
	public String description;

	/*******************************************************************************************************
	* @description Transaction reason typically used for voids, and refunds.
	*/
	public String reason;

	/*******************************************************************************************************
	* @description Transaction statement description
	*/
	public String statementDescription;

	/*******************************************************************************************************
	* @description Transaction name
	*/
	public String name;

	/*******************************************************************************************************
	* @description Transaction company
	*/
	public String company;

	/*******************************************************************************************************
	* @description Transaction address line 1
	*/
	public String address1;

	/*******************************************************************************************************
	* @description Transaction address line 2
	*/
	public String address2;

	/*******************************************************************************************************
	* @description Transaction city
	*/
	public String city;

	/*******************************************************************************************************
	* @description Transaction postal/zip code
	*/
	public String postalCode;

	/*******************************************************************************************************
	* @description Transaction state
	*/
	public String state;

	/*******************************************************************************************************
	* @description Transaction country
	*/
	public String country;

	/*******************************************************************************************************
	* @description Transaction email address
	*/
	public String email;

	/*******************************************************************************************************
	* @description Transaction phone number
	*/
	public String phone;

	/*******************************************************************************************************
	* @description Transaction billing name
	*/
	public String billingName {
		get {return String.isEmpty(this.billingName) ? this.name : this.billingName;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing company
	*/
	public String billingCompany {
		get {return String.isEmpty(this.billingCompany) ? this.company : this.billingCompany;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing address line 1
	*/
	public String billingAddress1 {
		get {return String.isEmpty(this.billingAddress1) ? this.address1 : this.billingAddress1;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing address line 2
	*/
	public String billingAddress2 {
		get {return String.isEmpty(this.billingAddress2) ? this.address2 : this.billingAddress2;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing city
	*/
	public String billingCity {
		get {return String.isEmpty(this.billingCity) ? this.city : this.billingCity;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing postal/zip code
	*/
	public String billingPostalCode {
		get {return String.isEmpty(this.billingPostalCode) ? this.postalCode : this.billingPostalCode;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing state
	*/
	public String billingState {
		get {return String.isEmpty(this.billingState) ? this.state : this.billingState;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing country
	*/
	public String billingCountry {
		get {return String.isEmpty(this.billingCountry) ? this.country : this.billingCountry;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction billing phone number
	*/
	public String billingPhone {
		get {return String.isEmpty(this.billingPhone) ? this.phone : this.billingPhone;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping name
	*/
	public String shippingName {
		get {return String.isEmpty(this.shippingName) ? this.name : this.shippingName;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping company
	*/
	public String shippingCompany {
		get {return String.isEmpty(this.shippingCompany) ? this.company : this.shippingCompany;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping address line 1
	*/
	public String shippingAddress1 {
		get {return String.isEmpty(this.shippingAddress1) ? this.address1 : this.shippingAddress1;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping address line 2
	*/
	public String shippingAddress2 {
		get {return String.isEmpty(this.shippingAddress2) ? this.address2 : this.shippingAddress2;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping city
	*/
	public String shippingCity {
		get {return String.isEmpty(this.shippingCity) ? this.city : this.shippingCity;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping postal/zip code
	*/
	public String shippingPostalCode {
		get {return String.isEmpty(this.shippingPostalCode) ? this.postalCode : this.shippingPostalCode;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping state
	*/
	public String shippingState {
		get {return String.isEmpty(this.shippingState) ? this.state : this.shippingState;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping country
	*/
	public String shippingCountry {
		get {return String.isEmpty(this.shippingCountry) ? this.country : this.shippingCountry;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping phone number
	*/
	public String shippingPhone {
		get {return String.isEmpty(this.shippingPhone) ? this.phone : this.shippingPhone;}
		set;
	}

	/*******************************************************************************************************
	* @description Transaction shipping carrier
	*/
	public String shippingCarrier;

	/*******************************************************************************************************
	* @description Transaction shipping tracking number
	*/
	public String shippingTrackingNumber;

	/*******************************************************************************************************
	* @description All configurable transaction options
	*/
	public Set<String> allOptions {
		get {
			return new Set<String> {
				'currencie',
				'orderId',
				'ip',
				'customer',
				'invoice',
				'merchant',
				'reverseMerchant',
				'merchantFee',
				'refundMerchantFee',
				'description',
				'reason',
				'statementDescription',
				'email',
				'phone',
				'name',
				'company',
				'address1',
				'address2',
				'city',
				'postalCode',
				'state',
				'country',
				'billingPhone',
				'billingName',
				'billingCompany',
				'billingAddress1',
				'billingAddress2',
				'billingCity',
				'billingPostalCode',
				'billingState',
				'billingCountry',
				'shippingPhone',
				'shippingName',
				'shippingCompany',
				'shippingAddress1',
				'shippingAddress2',
				'shippingCity',
				'shippingPostalCode',
				'shippingState',
				'shippingCountry',
				'shippingCarrier',
				'shippingTrackingNumber'
			};
		}
		private set;
	}

	/*******************************************************************************************************
	* @description Initialize new transaction options instance
	* @example
	* merchant_TransactionOptions options = new merchant_TransactionOptions();
	*/
	public merchant_TransactionOptions() {
		// Do something
	}

	/*******************************************************************************************************
	* @description Set transaction options; unknown options are ignored.
	* @param Card options
	* @example
	* transactionOptions.set(new Map<String, Object> {
	* 	'orderId' => '222323',
	* 	'customer' => 'Workless',
	* 	'email' => 'accountsPayable@workless.io',
	* 	'currencie' => 'USD'
	* });
	*/
	public void set(Map<String, Object> options) {
		for (String name : options.keySet()) {
			if (name == 'currencie') this.currencie = (String)options.get(name);
			if (name == 'orderId') this.orderId = (String)options.get(name);
			if (name == 'ip') this.ip = (String)options.get(name);
			if (name == 'customer') this.customer = (String)options.get(name);
			if (name == 'invoice') this.invoice = (String)options.get(name);
			if (name == 'merchant') this.merchant = (String)options.get(name);
			if (name == 'reverseMerchant') this.reverseMerchant = (String)options.get(name);
			if (name == 'merchantFee') this.merchantFee = (String)options.get(name);
			if (name == 'refundMerchantFee') this.refundMerchantFee = (String)options.get(name);
			System.debug(loggingLevel.Error, '*** options: ' + options);
			if (name == 'description') this.description = (String)options.get(name);
			if (name == 'reason') this.reason = (String)options.get(name);
			if (name == 'statementDescription') this.statementDescription = (String)options.get(name);
			if (name == 'email') this.email = (String)options.get(name);
			if (name == 'phone') this.phone = (String)options.get(name);
			if (name == 'name') this.name = (String)options.get(name);
			if (name == 'company') this.company = (String)options.get(name);
			if (name == 'address1') this.address1 = (String)options.get(name);
			if (name == 'address2') this.address2 = (String)options.get(name);
			if (name == 'city') this.city = (String)options.get(name);
			if (name == 'postalCode') this.postalCode = (String)options.get(name);
			if (name == 'state') this.state = (String)options.get(name);
			if (name == 'country') this.country = (String)options.get(name);
			if (name == 'billingPhone') this.billingPhone = (String)options.get(name);
			if (name == 'billingName') this.billingName = (String)options.get(name);
			if (name == 'billingCompany') this.billingCompany = (String)options.get(name);
			if (name == 'billingAddress1') this.billingAddress1 = (String)options.get(name);
			if (name == 'billingAddress2') this.billingAddress2 = (String)options.get(name);
			if (name == 'billingCity') this.billingCity = (String)options.get(name);
			if (name == 'billingPostalCode') this.billingPostalCode = (String)options.get(name);
			if (name == 'billingState') this.billingState = (String)options.get(name);
			if (name == 'billingCountry') this.billingCountry = (String)options.get(name);
			if (name == 'shippingPhone') this.shippingPhone = (String)options.get(name);
			if (name == 'shippingName') this.shippingName = (String)options.get(name);
			if (name == 'shippingCompany') this.shippingCompany = (String)options.get(name);
			if (name == 'shippingAddress1') this.shippingAddress1 = (String)options.get(name);
			if (name == 'shippingAddress2') this.shippingAddress2 = (String)options.get(name);
			if (name == 'shippingCity') this.shippingCity = (String)options.get(name);
			if (name == 'shippingPostalCode') this.shippingPostalCode = (String)options.get(name);
			if (name == 'shippingState') this.shippingState = (String)options.get(name);
			if (name == 'shippingCountry') this.shippingCountry = (String)options.get(name);
			if (name == 'shippingCarrier') this.shippingCarrier = (String)options.get(name);
			if (name == 'shippingTrackingNumber') this.shippingTrackingNumber = (String)options.get(name);
		}
	}
}
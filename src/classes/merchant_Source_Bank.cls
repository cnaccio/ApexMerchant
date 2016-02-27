/**
* @author Charles Naccio
* @date 12/25/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The bank payment source class defines and abstracts all bank source payment types used
* throughout the Merchant library. 
*/
public with sharing class merchant_Source_Bank extends merchant_Source {

	/*******************************************************************************************************
	* @description Name of bank such as Wells Fargo, Bank of America, Chase, etc...
	*/
	public String bankName;

	/*******************************************************************************************************
	* @description Name on bank account
	*/
	public String accountName;

	/*******************************************************************************************************
	* @description Bank account type (checking, or savings)
	*/
	public String accountType;

	/*******************************************************************************************************
	* @description Bank account number
	*/
	public String accountNumber;

	/*******************************************************************************************************
	* @description Bank routing number
	*/
	public String routingNumber;

	/*******************************************************************************************************
	* @description Initialize new bank payment source
	* @example
	* merchant_Source_Bank bank = new merchant_Source_Bank();
	*/
	public merchant_Source_Bank() {
		this.name = 'Bank';
		this.allOptions = new Set<String> {
			'bankName',
			'accountName',
			'accountType',
			'accountNumber',
			'routingNumber'
		};
		this.requiredOptions = new Set<String> {
			'bankName',
			'accountName',
			'accountType',
			'accountNumber',
			'routingNumber'
		};
	}

	/*******************************************************************************************************
	* @description Set bank options; unknown options are ignored.
	* @param Card options
	* @example
	* bank.set(new Map<String, Object> {
	* 	'key' => 'value'
	* });
	*/
	public override void set(Map<String, Object> options) {
		for (String name : options.keySet()) {
			if (name == 'bankName') this.bankName = (String)options.get(name);
			if (name == 'accountName') this.accountName = (String)options.get(name);
			if (name == 'accountType') this.accountType = (String)options.get(name);
			if (name == 'accountNumber') this.accountNumber = (String)options.get(name);
			if (name == 'routingNumber') this.routingNumber = (String)options.get(name);
		}
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of bank account number.
	* @return Last 4 digits/characters of bank account number.
	* @example
	* bank.getLastFour();
	*/
	public override String getLastFour() {
		String lastFour = this.accountNumber.right(4);
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
		Integer maskLength = this.accountNumber.length() -4;
		String accountNumberMasked = mask.repeat(maskLength) + this.getLastFour();
		return accountNumberMasked;
	}
}
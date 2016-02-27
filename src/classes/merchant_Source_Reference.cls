/**
* @author Charles Naccio
* @date 8/26/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Reference payment source class defines and abstracts all reference source payment types used
* throughout the Merchant library. A reference source will typically be a customer, card, or check Id.
*/
public with sharing class merchant_Source_Reference extends merchant_Source {
	
	/*******************************************************************************************************
	* @description The actual reference value for this reference payment source.
	*/
	public String reference;

	/*******************************************************************************************************
	* @description Initialize new Reference payment source
	* @example
	* merchant_Source_Reference reference = new merchant_Source_Reference();
	*/
	public merchant_Source_Reference() {
		this.name = 'Reference';
		this.allOptions = new Set<String> {
			'reference'
		};
		this.requiredOptions = new Set<String> {
			'reference'
		};
	}

	/*******************************************************************************************************
	* @description Initialize new Reference payment source from reference
	* @example
	* merchant_Source_Reference reference = new merchant_Source_Reference('customerId::sourceId');
	*/
	public merchant_Source_Reference(string reference) {
		this();
		this.reference = reference;
	}

	/*******************************************************************************************************
	* @description Set token options; unknown options are ignored.
	* @param Card options
	* @example
	* token.set(new Map<String, Object> {
	* 	'key' => 'value'
	* });
	*/
	public override void set(Map<String, Object> options) {
		for (String name : options.keySet()) {
			if (name == 'reference') this.reference = (String)options.get(name);
		}
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of reference number.
	* @return Last 4 digits/characters of reference number.
	* @example
	* reference.getLastFour();
	*/
	public override String getLastFour() {
		String lastFour = this.reference.right(4);
		return lastFour;
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of reference number masked.
	* @return Masked reference number except for the last 4 digits/characters
	* @example
	* reference.getLastFourMasked();
	*/
	public override String getLastFourMasked() {
		return getLastFourMasked('X');
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of reference number masked with provided
	* masking character.
	* @param Masking character
	* @return Masked reference number except for the last 4 digits/characters
	* @example
	* reference.getLastFourMasked('*');
	*/
	public override String getLastFourMasked(String mask) {
		if (mask == null) mask = 'X';
		Integer maskLength = this.reference.length() -4;
		String referenceMasked = mask.repeat(maskLength) + this.getLastFour();
		return referenceMasked;
	}
}
/**
* @author Charles Naccio
* @date 8/26/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Token payment source class defines and abstracts all token source payment types used
* throughout the Merchant library. 
*/
public with sharing class merchant_Source_Token extends merchant_Source {
	
	/*******************************************************************************************************
	* @description The actual token value for this token payment source.
	*/
	public String token;

	/*******************************************************************************************************
	* @description Initialize new token payment source
	* @example
	* merchant_Source_Token token = new merchant_Source_Token();
	*/
	public merchant_Source_Token() {
		this.name = 'Token';
		this.allOptions = new Set<String> {
			'token'
		};
		this.requiredOptions = new Set<String> {
			'token'
		};
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
			if (name == 'token') this.token = (String)options.get(name);
		}
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of token.
	* @return Last 4 digits/characters of token.
	* @example
	* token.getLastFour();
	*/
	public override String getLastFour() {
		String lastFour = this.token.right(4);
		return lastFour;
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of token masked.
	* @return Masked token except for the last 4 digits/characters
	* @example
	* token.getLastFourMasked();
	*/
	public override String getLastFourMasked() {
		return getLastFourMasked('X');
	}

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of token masked with provided
	* masking character.
	* @param Masking character
	* @return Masked token except for the last 4 digits/characters
	* @example
	* token.getLastFourMasked('*');
	*/
	public override String getLastFourMasked(String mask) {
		if (mask == null) mask = 'X';
		Integer maskLength = this.token.length() -4;
		String tokenMasked = mask.repeat(maskLength) + this.getLastFour();
		return tokenMasked;
	}
}
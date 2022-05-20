/**
* @author Charles Naccio
* @date 09/05/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Source class is the base class for all payment source/method implementations. 
* This abstract class should be extended by all payment sources throughout the Merchant system.
* It defines the various common attributes and methods that all payment sources should have.
*/
public with sharing abstract class merchant_Source {
	
	/*******************************************************************************************************
	* @description Payment source name; Card, Check, Token, Reference, etc...
	*/
	public String name {get; protected set;}

	/*******************************************************************************************************
	* @description Options required to create this payment source
	*/
	public final Set<String> requiredOptions;

	/*******************************************************************************************************
	* @description All configurable payment source options
	*/
	public Set<String> allOptions {get; protected set;}

	/*******************************************************************************************************
	* @description Initialize new payment source instance.
	* @example
	* merchant_Source_* source = new merchant_Source_*();
	*/
	public merchant_Source() {
		// Do something
	}

	/*******************************************************************************************************
	* @description Validate that required payment source options exists in payment source options parameter
	* @param Payment source options
	* @example
	* source.validateRequiredOptions(options);
	*/
	public virtual void validateRequiredOptions(Map<String, Object> options) {
		if (this.requiredOptions != null) {
			Set<String> requiredOptions = new Set<String>(this.requiredOptions);
			requiredOptions.removeAll(options.keySet());
			for (String option : requiredOptions) {
				String errorMsg = 'Missing required payment source option: "' + option + '"';
				throw new Merchant.RequiredOptionMissingException(errorMsg);
			}
		}
	}	

	/*******************************************************************************************************
	* @description Set payment source options; unknown options are ignored.
	* @param payment source options
	* @example
	* source.set(new Map<String, Object> {
	* 	'type' => 'Card'
	* });
	*/
	public abstract void set(Map<String, Object> options);

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of payment source number; typically card number, or
	* bank account number.
	* @return Last 4 digits/characters of payment source number
	* @example
	* source.getLastFour();
	*/
	public abstract String getLastFour();

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of payment source number; typically card number, or
	* bank account number with remaining digits/characters masked.
	* @return Masked payment source number except for the last 4 digits/characters
	* @example
	* source.getLastFourMasked();
	*/
	public abstract String getLastFourMasked();

	/*******************************************************************************************************
	* @description Get last 4 digits/characters of payment source number; typically card number, or
	* bank account number with remaining digits/characters masked with provided masking character.
	* @param Masking character
	* @return Masked payment source number except for the last 4 digits/characters
	* @example
	* source.getLastFourMasked('*');
	*/
	public abstract String getLastFourMasked(String mask);

	/*******************************************************************************************************
	* @description Convert object instance to map
	* @return Map of string keys, and object values
	* @example
	* Map<String, Object> sourceMap = source.toMap();
	*/
	public virtual Map<String, Object> toMap() {
		return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this));
	}
}
/**
* @author Charles Naccio
* @date 10/28/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The merchant gateway interface is used to provide a consistent base gateway api.
*/
public interface merchant_IGateway {

	/*******************************************************************************************************
	* @description Validate that required gateway options exists in gateway options parameter
	* @param Gateway options
	* @example
	* validateRequiredOptions(options);
	*/
	void validateRequiredOptions(Map<String, Object> options);
	
	/*******************************************************************************************************
	* @description Set gateway options; unknown options are ignored.
	* @param gateway options
	* @example
	* set(new Map<String, Object> {
	* 	'name' => 'Stripe',
	* 	'testMode' => 'true'
	* });
	*/
	void set(Map<String, Object> options);

	/*******************************************************************************************************
	* @description Complete a purchase
	* @param Purchase amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = purchase(100, source, options);
	*/
	merchant_Response purchase(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a authorize
	* @param Authorize amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = authorize(100, source, options);
	*/
	merchant_Response authorize(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a capture
	* @param Capture amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = capture(100, source, options);
	*/
	merchant_Response capture(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a void
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = void(source, options);
	*/
	merchant_Response void(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a refund
	* @param Refund amount
	* @param Previous authorization or purchase reference
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = refund(100, source, options);
	*/
	merchant_Response refund(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a credit
	* @param Credit amount
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = credit(100, source, options);
	*/
	merchant_Response credit(Integer amount, merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a store
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = store(source, options);
	*/
	merchant_Response store(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Complete a unstore
	* @param Payment source
	* @param Optional transaction options
	* @return Gateway response
	* @example
	* merchant_Response response = unstore(source, options);
	*/
	merchant_Response unstore(merchant_Source source, merchant_TransactionOptions options);

	/*******************************************************************************************************
	* @description Send gateway transaction request
	* @param Gateway transaction action
	* @param Transaction parameters
	* @return Gateway response
	* @example
	* merchant_Response response = request(action, parameters);
	*/
	merchant_Response request(String action, Map<String, Object> parameters);
}
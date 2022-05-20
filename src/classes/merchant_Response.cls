/**
* @author Charles Naccio
* @date 9/6/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Response class defines the common response to be returned by each transaction gateway.
*/
public with sharing class merchant_Response {
	
	/*******************************************************************************************************
	* @description Was the transaction request/response successful?
	*/
	public Boolean success;

	/*******************************************************************************************************
	* @description Transaction request/response code
	*/
	public String code;

	/*******************************************************************************************************
	* @description Transaction request/response message
	*/
	public String message;

	/*******************************************************************************************************
	* @description Transaction request/response message details
	*/
	public String details;

	/*******************************************************************************************************
	* @description Transaction HTTP request/response body
	*/
	public String body;

	/*******************************************************************************************************
	* @description Reference information returned by the gateway to represent this transaction
	*/
	public String reference;

	/*******************************************************************************************************
	* @description Initialize new gateway transaction response instance
	* @example
	* merchant_Response response = new merchant_Response();
	*/
	public merchant_Response() {
		// Do something
	}

	/*******************************************************************************************************
	* @description Initialize new gateway transaction response instance
	* @param Was transaction request/response successful?
	* @param Transaction request/response code
	* @param Transaction request/response message
	* @param Transaction request/response message details
	* @param Transaction reference
	* @example
	* merchant_Response response = new merchant_Response(true, 
	* 													 'success',
	* 													 'Transaction successful', 
	* 													 'The purchase transaction was successful',
	* 													 '{"body": "http response body details"}',
	* 													 'ch_xkdj2333232xfrrr2');
	*/
	public merchant_Response(Boolean success, String code, String message, String details, String body, String reference) {
		this.success = success;
		this.code = code;
		this.message = message;
		this.details = details;
		this.body = body;
		this.reference = reference;
	}
}
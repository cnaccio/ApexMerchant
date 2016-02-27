/**
* @author Charles Naccio
* @date 9/27/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description The Request class provides a robust tool-set for communicating with gateway APIs in a consistent
* fashion. This class is modeled after the Financial Force ffhttp-core library found here 
* (https://github.com/financialforcedev/ffhttp-core). Each gateway will use this class for building and sending
* API requests.
*/
public with sharing class merchant_Request {
	
	/*******************************************************************************************************
	* @description HTTP header authorization static
	*/
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
	
	/*******************************************************************************************************
	* @description HTTP header content length static
	*/
	public static final String HTTP_HEADER_CONTENT_LENGTH = 'Content-Length';
	
	/*******************************************************************************************************
	* @description HTTP header content type static
	*/
	public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
	
	/*******************************************************************************************************
	* @description HTTP GET request endpoint separator
	*/
	public static final String HTTP_REQUEST_ENDPOINT_SEPARATOR = '&';
	
	/*******************************************************************************************************
	* @description HTTP GET request parameter separator
	*/
	public static final String HTTP_REQUEST_PARAMETER_SEPARATOR = '=';
	
	/*******************************************************************************************************
	* @description HTTP GET request parameter prefix
	*/
	public static final String HTTP_REQUEST_PARAMETER_PREFIX = '?';
	
	/*******************************************************************************************************
	* @description HTTP charset
	*/
	public static final String CHARSET_UTF8 = 'UTF-8';

	/*******************************************************************************************************
	* @description HTTP request endpoint
	*/
	private String endpoint {get;set;}

	/*******************************************************************************************************
	* @description HTTP request method
	*/
	private String method {get;set;}

	/*******************************************************************************************************
	* @description HTTP content for HTTP request
	*/
	private HttpContent content {get;set;}

	/*******************************************************************************************************
	* @description Credentials for HTTP request
	*/
	private HttpCredentials credentials {get;set;}

	/*******************************************************************************************************
	* @description Gateway transaction action
	*/
	private String action {get;set;}

	/*******************************************************************************************************
	* @description HTTP request parameters
	*/
	private Map<String, String> parameters {get;set;}

	/*******************************************************************************************************
	* @description Class to model HTTP request content
	*/
	public class HttpContent {

		/*******************************************************************************************************
		* @description HTTP content type
		*/
		private String type {get;set;}

		/*******************************************************************************************************
		* @description HTTP content
		*/
		private String content {get;set;}

		/*******************************************************************************************************
		* @description Initialize new HTTP content instance
		* @param HTTP content type
		* @param HTTP content
		* @example
		* merchant_Request.HttpContent content;
		* content = new merchant_Request.HttpContent('application/x-www-form-urlencoded', 'key=value');
		*/
		public HttpContent(String type, String content) {
			if(String.isBlank(type)) {
				throw new Merchant.InvalidParameterValueException('HTTP content type cannot be blank.');
			}
			if(String.isBlank(content)) {
				throw new Merchant.InvalidParameterValueException('HTTP content cannot be blank.');
			}
			this.type = type;
			this.content = content;
		}

		/*******************************************************************************************************
		* @description Initialize new HTTP content instance with empty content. This is primarily needed for
		* rest api requests that require no content/payload.
		* @param HTTP content type
		* @param HTTP content
		* @example
		* merchant_Request.HttpContent content;
		* content = new merchant_Request.HttpContent('application/x-www-form-urlencoded');
		*/
		public HttpContent(String type) {
			if(String.isBlank(type)) {
				throw new Merchant.InvalidParameterValueException('HTTP content type cannot be blank.');
			}
			this.type = type;
			this.content = '';

			// Show warning of empty http content in case it was an accident
			System.debug(System.LoggingLevel.WARN, '\n**** HTTP CONTENT IS EMPTY');
		}
	}

	/*******************************************************************************************************
	* @description Class to model HTTP request credentials 
	*/
	public class HttpCredentials {

		/*******************************************************************************************************
		* @description Credential token type
		*/
		private String tokenType {get;set;}

		/*******************************************************************************************************
		* @description Credential access token
		*/
		private String accessToken {get;set;}

		/*******************************************************************************************************
		* @description Credential authorization
		*/
		private String authorization {
			get {
				return this.tokenType + ' ' + this.accessToken;
			}
			private set;
		}

		/*******************************************************************************************************
		* @description Initialize new credentials instance
		* @param Type of credential token
		* @param The credential access token
		* @example
		* merchant_Request.HttpCredentials creds = new merchant_Request.HttpCredentials('Bearer', 'seCrEtAPIk3y');
		*/
		public HttpCredentials(String tokenType, String accessToken) {
			if(String.isBlank(tokenType)) {
				throw new Merchant.InvalidParameterValueException('Request token type cannot be blank.');
			}
			if(String.isBlank(accessToken)) {
				throw new Merchant.InvalidParameterValueException('Request access token cannot be blank.');
			}
			this.tokenType = tokenType;
			this.accessToken = accessToken;
		}
	}

	/*******************************************************************************************************
	* @description Initialize new gateway transaction request instance with parameters
	* @param HTTP credentials
	* @param HTTP endpoint
	* @param HTTP method
	* @param HTTP payload for request
	* @param Merchant action
	* @example
	* merchant_Request request = new merchant_Request(
	* 	credentials,
	* 	'api.string.com/v1/charges',
	* 	'POST',
	* 	content, 
	*   'purchase'
	* );
	*/
	public merchant_Request(HttpCredentials credentials, 
							String endpoint, 
							String method, 
							HttpContent content, 
							String action) {
		if(credentials == null) {
			throw new Merchant.InvalidParameterValueException('Request credentials cannot be null.');
		}
		if(String.isBlank(endpoint)) {
			throw new Merchant.InvalidParameterValueException('Request endpoint cannot be blank.');
		}
		if(String.isBlank(method)) {
			throw new Merchant.InvalidParameterValueException('Request method cannot be blank.');
		}
		if(content == null) {
			throw new Merchant.InvalidParameterValueException('Request content cannot be null.');
		}
		if(String.isBlank(action)) {
			throw new Merchant.InvalidParameterValueException('Request action cannot be blank.');
		}
		this.credentials = credentials;
		this.endpoint = endpoint;
		this.method = method;
		this.content = content;
		this.action = action;
	}

	/*******************************************************************************************************
	* @description Build and setup HTTP request for sending based on parameters/payload provided
	* @return A fully prepped HTTP request ready for sending
	* @example
	* HttpRequest merchantRequest = merchant_Request.build();
	*/
	private HttpRequest build() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint(this.endpoint);
		request.setMethod(this.method);
		request.setHeader(HTTP_HEADER_AUTHORIZATION, this.credentials.authorization);
		request.setBody(this.content.content);
		System.debug(System.LoggingLevel.INFO, '\n**** REQUEST BODY:\n' + request.getBody());
		request.setHeader(HTTP_HEADER_CONTENT_LENGTH, String.valueOf(this.content.content.length()));
		request.setHeader(HTTP_HEADER_CONTENT_TYPE, this.content.type);
		return request;
	}

	/*******************************************************************************************************
	* @description Execute gateway transaction request returning the parsed response
	* @return Returns the HTTP request body
	* @example
	* HttpResponse httpResponse = merchant_Request.execute();
	*/
	public HttpResponse execute() {
		
		// Setup HTTP request
		HttpRequest httpRequest = this.build();
		
		// Wrap request in try catch to handle errors gracefully
		try {
			
			// Send HTTP request
			HttpResponse httpResponse = new Http().send(httpRequest);

	        // Return HTTP response
	        return httpResponse;
		} catch (CalloutException ce) {

			// Debug gateway connection exception
			System.debug('\n**** GATEWAY CONNECTION EXCEPTION:\n' + ce);

			// Check for unauthorized endpoint exception which is typically due to a missing remote site setting
			if(ce.getMessage().contains('Unauthorized endpoint')) {
				
				// Get base url from endpoint
				String baseURL = '';
				String[] urlParts = this.endpoint.split('/');
				if(urlParts.size() > 2) {
					String protocol = urlParts[0];
					String host = urlParts[2];
					baseURL = protocol + '//' + host;
				} else {
					baseURL = this.endpoint;
				}

				// Throw configuration exception
				String[] errorMsg = new String[] {};
				errorMsg.add('Gateway connection failed while attempting a "' + this.action + '" transaction.');
				errorMsg.add('The gateway API URL (' + baseURL + ') is not setup as an authorized remote site.');
				errorMsg.add('Please check Setup->Security Controls->Remote Site Settings, and try again.');
				throw new Merchant.ConfigurationException(String.join(errorMsg, ' '), ce);
			} else {
				
				// Throw gateway connection exception
				String[] errorMsg = new String[] {};
				errorMsg.add('Gateway connection failed while attempting a "' + this.action + '" transaction.');
				errorMsg.add('Problem details: ' + ce.getMessage());
				throw new Merchant.GatewayConnectionException(String.join(errorMsg, ' '), ce);
			}
		}
	}
}
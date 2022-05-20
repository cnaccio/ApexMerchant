/**
* @author Charles Naccio
* @date 09/05/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description Unit tests for Merchant.
*/
@isTest
private class merchant_Tests {
    
    /**
     * Merchant Usage Tests
     */

    @isTest
    static void itShouldTestMerchantUsage() {

        
        /**
         * Given (initialize data)
         */

        // Setup gateway options
        Map<String, Object> options = new Map<String, Object> {
            'login' => 'sk_live_41Y6cbbMW9MQciBRf84hs84j',
            'password' => 'sk_test_RSylZfxqhm65G0yGh4jks94jf',
            'testMode' => 'true'
        }

        // Setup new instance of merchant passing in your gateway name (Stripe, AuthorizeDotNet, PayPal)
        Merchant merchant = new Merchant('Stripe', options);

        // Setup credit card payment source
        Map<String, Object> source = new Map<String, Object> {
            'name' => 'Card',
            'firstName' => 'Charles',
            'lastName' => 'Naccio',
            'cardNumber' => '4444333322221111',
            'cvv' => '123',
            'month' => '12',
            'year' => '2017',
            'postalCode' => '75070'
        };

        // Amount to charge in cents i.e. $1.00 = 100 cents
        Integer amount = 100;

        
        /**
         * When
         */
        
        // ...
        List<edge_GetOpportunityDefaultsAction.Result> results = edge_GetOpportunityDefaultsAction.getOpportunityDefaults(
            requests
        );


        /**
         * Then
         */
        
        // Validate test results
        System.assert(
            results.size() > 0,
            'Expected at least one Opportunity Defaults result, but received "' +
            results.size() +
            '".'
        );
        System.assert(
            results.get(0).isPointOfSaleOnly == false,
            'Expected admin user NOT to be a Pro Star Only user.'
        );
    }	
}
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
        };

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
        
        // Start test
        Test.startTest();

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new merchant_Mocks());

        // Merchant transaction actions
        merchant.purchase(amount, source);
        String chargeId = merchant.authorize(amount, source).reference;
        Map<String, Object> reference = new Map<String, Object> {
            'name' => 'Reference',
            'reference' => chargeId
        };
        merchant.capture(amount, reference);
        merchant.void(reference);
        merchant.refund(amount, reference);
        Boolean creditFailed = false;
        try {
            merchant.credit(amount, source);
        } catch (Exception ex) {
            creditFailed = true;
        }
        String customerId = merchant.store(source).reference;
        reference = new Map<String, Object> {
            'name' => 'Token',
            'token' => customerId
        };
        merchant.unstore(reference);
        Boolean verified = merchant.verify();

        // Stop test
        Test.stopTest();

        /**
         * Then
         */
        
        // Validate test results
        System.assert(
            verified,
            'Merchant gateway verification failed.'
        );
        System.assert(
            creditFailed,
            'Expected "credit" transaction to fail for Stripe.'
        );
    }	
}
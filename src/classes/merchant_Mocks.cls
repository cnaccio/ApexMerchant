/**
* @author Charles Naccio
* @date 09/05/2015
*
* @group Merchant
* @group-content ../../ApexDocContent/Merchant.htm
*
* @description Mock HTTP response generators for unit testing.
*/
@isTest
public class merchant_Mocks implements HttpCalloutMock {
    
    // Implement respond interface method
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        /**
         * Support Various APIs
         */

        // Stripe API
        System.debug('>>> request endpoint: ' + req.getEndpoint());
        if (req.getEndpoint().toLowerCase().contains('stripe')) {
            
            // All responses are in JSON format
            res.setHeader('Content-Type', 'application/json');

            // Assume requests are successful, unless changed below
            res.setStatusCode(200);

            // Charges
            if (req.getEndpoint().contains('/charges')) {
                
                // Mock POST response from /charges endpoint
                res.setBody(
                    '{' +
                    '    "id": "ch_3K2KQlKTIpx1Cy0o08ShEMnz",' +
                    '    "object": "charge",' +
                    '    "amount": 2000,' +
                    '    "amount_captured": 100,' +
                    '    "amount_refunded": 0,' +
                    '    "application": null,' +
                    '    "application_fee": null,' +
                    '    "application_fee_amount": null,' +
                    '    "balance_transaction": "txn_1K4Ej2KTIpx1Cy0olFmY2bJN",' +
                    '    "billing_details": {' +
                    '        "address": {' +
                    '        "city": null,' +
                    '        "country": null,' +
                    '        "line1": null,' +
                    '        "line2": null,' +
                    '        "postal_code": null,' +
                    '        "state": null' +
                    '        },' +
                    '        "email": null,' +
                    '        "name": null,' +
                    '        "phone": null' +
                    '    },' +
                    '    "calculated_statement_descriptor": "PALADIN INDUSTRIES",' +
                    '    "captured": true,' +
                    '    "created": 1638471295,' +
                    '    "currency": "usd",' +
                    '    "customer": null,' +
                    '    "description": "My First Test Charge (created for API docs at https://www.stripe.com/docs/api)",' +
                    '    "disputed": false,' +
                    '    "failure_balance_transaction": null,' +
                    '    "failure_code": null,' +
                    '    "failure_message": null,' +
                    '    "fraud_details": {},' +
                    '    "invoice": null,' +
                    '    "livemode": false,' +
                    '    "metadata": {},' +
                    '    "on_behalf_of": null,' +
                    '    "outcome": {' +
                    '        "network_status": "approved_by_network",' +
                    '        "reason": null,' +
                    '        "risk_level": "normal",' +
                    '        "risk_score": 36,' +
                    '        "seller_message": "Payment complete.",' +
                    '        "type": "authorized"' +
                    '    },' +
                    '    "paid": true,' +
                    '    "payment_intent": null,' +
                    '    "payment_method": "card_1K2KPVKTIpx1Cy0oX8La3Ww4",' +
                    '    "payment_method_details": {' +
                    '        "card": {' +
                    '        "brand": "visa",' +
                    '        "checks": {' +
                    '            "address_line1_check": null,' +
                    '            "address_postal_code_check": null,' +
                    '            "cvc_check": "pass"' +
                    '        },' +
                    '        "country": "US",' +
                    '        "exp_month": 12,' +
                    '        "exp_year": 2022,' +
                    '        "fingerprint": "K30EZ5Votm2Zks3u",' +
                    '        "funding": "credit",' +
                    '        "installments": null,' +
                    '        "last4": "4242",' +
                    '        "mandate": null,' +
                    '        "network": "visa",' +
                    '        "three_d_secure": null,' +
                    '        "wallet": null' +
                    '        },' +
                    '        "type": "card"' +
                    '    },' +
                    '    "receipt_email": null,' +
                    '    "receipt_number": null,' +
                    '    "receipt_url": "https://pay.stripe.com/receipts/acct_1K1uAuKTIpx1Cy0o/ch_3K2KQlKTIpx1Cy0o08ShEMnz/rcpt_KhjuX4rkhC378lCXRPPZF8PN3PLCYnx",' +
                    '    "refunded": false,' +
                    '    "refunds": {' +
                    '        "object": "list",' +
                    '        "data": [],' +
                    '        "has_more": false,' +
                    '        "url": "/v1/charges/ch_3K2KQlKTIpx1Cy0o08ShEMnz/refunds"' +
                    '    },' +
                    '    "review": null,' +
                    '    "shipping": null,' +
                    '    "source_transfer": null,' +
                    '    "statement_descriptor": null,' +
                    '    "statement_descriptor_suffix": null,' +
                    '    "status": "succeeded",' +
                    '    "transfer_data": null,' +
                    '    "transfer_group": null,' +
                    '    "source": "tok_visa"' +
                    '}'
                );
            }

            // Customers
            if (req.getEndpoint().contains('/customers')) {
                
                // Mock DELETE response from /customers endpoint
                if (req.getMethod() == 'DELETE') {
                    res.setBody(
                        '{' +
                        '    "id": "cus_LiqYWfkZWKSznr",' +
                        '    "object": "customer",' +
                        '    "deleted": true' +
                        '}'
                    );
                }
                
                // Mock all other responses from /customers endpoint
                else {
                    res.setBody(
                        '{' +
                        '    "id": "cus_LiqYWfkZWKSznr",' +
                        '    "object": "customer",' +
                        '    "address": null,' +
                        '    "balance": 0,' +
                        '    "created": 1653026332,' +
                        '    "currency": "usd",' +
                        '    "default_source": null,' +
                        '    "delinquent": false,' +
                        '    "description": "My First Test Customer (created for API docs at https://www.stripe.com/docs/api)",' +
                        '    "discount": null,' +
                        '    "email": null,' +
                        '    "invoice_prefix": "DDE9597",' +
                        '    "invoice_settings": {' +
                        '        "custom_fields": null,' +
                        '        "default_payment_method": null,' +
                        '        "footer": null' +
                        '    },' +
                        '    "livemode": false,' +
                        '    "metadata": {},' +
                        '    "name": null,' +
                        '    "next_invoice_sequence": 1,' +
                        '    "phone": null,' +
                        '    "preferred_locales": [],' +
                        '    "shipping": null,' +
                        '    "tax_exempt": "none",' +
                        '    "test_clock": null' +
                        '}'
                    );
                }
            }

            // Refunds
            if (req.getEndpoint().contains('/refunds')) {
                
                // Mock POST response from /refunds endpoint
                res.setBody(
                    '{' +
                    '    "id": "re_3K2KQlKTIpx1Cy0o02g309YH",' +
                    '    "object": "refund",' +
                    '    "amount": 100,' +
                    '    "balance_transaction": null,' +
                    '    "charge": "ch_3K2KQlKTIpx1Cy0o08ShEMnz",' +
                    '    "created": 1653026334,' +
                    '    "currency": "usd",' +
                    '    "metadata": {},' +
                    '    "payment_intent": null,' +
                    '    "reason": null,' +
                    '    "receipt_number": null,' +
                    '    "source_transfer_reversal": null,' +
                    '    "status": "succeeded",' +
                    '    "transfer_reversal": null' +
                    '}'
                );
            }
        } else {
            
            // Return generic response
            res.setBody('{"foo": "bar"}');
        }

        // Return mock response
        return res;
    }
}
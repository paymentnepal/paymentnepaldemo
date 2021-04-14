API client for Paymentnepal
=============

#### Init service

Service can be inited two ways:

* providing serviceId and secret:

```objective-c
	GPSPayService * payService = [[GPSPayService alloc] initWithServiceId:@"12345" andSecret:@"abcd1234"];
```

* providing  serviceId and key:

```objective-c
	GPSPayService * payService = [[GPSPayService alloc] initWithServiceId:@"12345" andKey:@"abcd1234"];
```

To make payment with bank card a toked containing card data must be generated. This token will be used to init payment. Data needed for token creating is provided in GPSCardTokenRequest.
If card is involved into 3-D secure, then paymentResponse.card3ds will contain data for POST request to card issuer.

#### Getting card token

Init GPSCardTokenRequest:

```objective-c
   	GPSCardTokenRequest * cardTokenRequest = [[GPSCardTokenRequest alloc] initWithServiceId:payService.serviceId andCard:@"<card number>" andExpMonth:@"<exp date month>" andExpYear:@"<exp date year>" andCvc:@"<CVC>" andCardHolder:@"<cardholder>"];
        GPSCardTokenResponse * cardTokenResponse = [payService createCardToken:cardTokenRequest isTest:YES];
```

Request card token.Method **[GPSPayService createCardToken: isTest: successBlock: failure:]** is async. In case of successful response from bank successBlock is called, otherwise failure is called:

```objective-c
	[payService createCardToken:cardTokenRequest isTest:YES successBlock:^(GPSCardTokenResponse *response) {
		// handling bank response
	} failure:^(NSDictionary *error) {
  		// handling error response
	}];
```

If cardTokenResponse.hasErrors == NO, init transaction:

```objective-c
        // Generate payment request
        GPSPaymentRequest * paymentRequest = [[GPSPaymentRequest alloc] init];

        // Собираем необходимые параметры для платежа
        paymentRequest.paymentType = @"spg_test";     // Possible values: mc, qiwi, spg, spg_test
        paymentRequest.email = @"<Email>";            // May be required depending on service settings
        paymentRequest.cost = @"<amount>";             // int
        paymentRequest.name = @"<payment_name>";        
        paymentRequest.phone = @"<customer_phone>";   // Required if paymentType in (mc, qiwi)
        paymentRequest.orderId = @"<unique order_id>";   // orderId must be unique. Additional field
        paymentRequest.background = @"1";             // Always 1
        paymentRequest.cardToken = cardTokenResponse.token;       // If paymentType is spg or spg_test        
        paymentRequest.comment = @"<payment_comment>";    // Additional field
```

In case of recurrent payment additional params described in GPSReccurentParams must be provided in paymentRequest. Recurrent payment consists of two operations:
	
* Payment with registering recurrent payment (for the first recurrent payment)

```objective-c
	NSString *url = @"<Terms and rules of payment service link>";
	NSString *comment = @"<Text description of purpose of recurrent payment registration>";
	GPSReccurentParams *reccurentParams = [GPSReccurentParams firstWithUrl:url andComment:comment];
```

* Recurrent payment by request (second and further payments)

```objective-c
	NSString *reccurentOrderId = @"<order_id>";
	GPSReccurentParams *reccurentParams = [GPSReccurentParams nextWithOrderId:reccurentOrderId];
```

After that you must provide recurrent payment params into payment request:

```objective-c
	paymentRequest.reccurentParams = reccurentParams;
```

To cancel recurrent payments:

```objective-c
 	[payService cancelRecurrentPaymentWithOrderId:reccurentOrderId successBlock:^{
 		// handling bank response
 	} failure:^(NSDictionary *error) {
 		// handling error response
 	}];
```

If you need to add invoice data for fiscalization you'll need to implement GPSInvoiceData object and provide it into paymentRequest:

```objective-c
 	GPSInvoiceData *invoiceData = [GPSInvoiceData new];
 	invoiceData.vatTotal = @(<amount>);
 	
 	GPSInvoiceItem *firstItem = [GPSInvoiceItem new];
 	firstItem.code = @"<item code>";
 	firstItem.name = @"<item name>";
 	firstItem.unit = @"<unit of measurment>";
 	firstItem.vatMode = @"<VAT amount>";
 	firstItem.price = @(<cost per unit>);
 	firstItem.quantity = @(<quantity>);
 	firstItem.sum = @(<total amount>);
 	firstItem.vatAmount = @(<VAT total>);
 	firstItem.discountRate = @(<Discount (percent)>);
 	firstItem.discountAmount = @(<Discount total>);

 	GPSInvoiceItem *secondItem = [GPSInvoiceItem new];
 	secondItem.code = @"<item code>";
 	...
 
 	invoiceData.items = @[firstItem, secondItem];

 	paymentRequest.invoiceData = invoiceData;
```

#### Init payment request to bank

Method **[GPSPayService paymentInit: successBlock: failure:]** is async. In case of successful response from bank successBlock is called, otherwise failure is called:

```objective-c
   	[payService paymentInit:paymentRequest successBlock:^(GPSPaymentResponse *response) {
   		// handling bank response
	} failure:^(NSDictionary *error) {
		// handling error response
	}];
```

If paymentResponse.hasErrors doesn't contain errors, get transaction ID

```objective-c
  	NSString * transactionId = paymentResponse.transactionId;
```

#### Get transaction init state

```objective-c
 	NSString * status = paymentResponse.status;
```

#### Get additional payment text (for paymentType 'mc' only):

```objective-c
	NSString * help = paymentResponse.help;
```

#### If 3DS is needed:

```objective-c
	if(paymentResponse.card3ds) {
		//3DS handling
	}
```

If 3-D secure id needed you need to send POST request to paymentResponse.card3ds.ACSUrl URL with next params:

        PaReq - with paymentResponse.card3ds.PaReq value
        MD - with paymentResponse.card3ds.MD value
        TermUrl - your site handler URL, customer will be redirected onto it after 3DS authorization
        
        To check 3DS authorization result you need to send POST request to https://partner.rficb.ru/alba/ack3ds/ with next params:
        service_id;
        tid or order_id;
        emitent_response - card issuer response data in JSON-encoded format (can be obtained from paymentResponse.card3ds)
        check - electronic sign for request
        version=2.0 - API version
                

#### Electroic sign example

```objective-c
        NSString * check = [GPSSigner sign:@"string to sign"
                                       url:@"requested URL"
                             requestParams: @{}
                                 secretKey: payService.secret];
```

You can also use our standard TermUrl with providing params:

        https://secure.rficb.ru/acquire?sid=<service_id>&oid=<transaction_id>&op=pay
                
In case of test payment:

        https://test.rficb.ru/acquire?sid=<service_id>&oid=<transaction_id>&op=pay
          
Get transaction info. Method **[GPSPayService transactionDetails: successBlock: failure:]** is async. In case of successful response from bank successBlock is called, otherwise failure is called:

```objective-c
 	[payService transactionDetails: transactionId successBlock:^(GPSPaymentResponse *response) {
 		// handling bank response
	} failure:^(NSDictionary *error) {
		// handling error response
	}];
```

Transaction init state success:

```objective-c
        NSString * transactionStatus = transactionDetails.status;
```

Payment state open, error, payed, success

```objective-c
        NSString * transactionPayStatus = transactionDetails.transactionStatus;
```

#### 3DS state check method

```objective-c
- (void) check3DSStatusForService: (NSString *) serviceId
                          orderId: (NSNumber *) orderId
                  emitentResponse: (NSDictionary *) emitentResponse
                     andSecretKey: (NSString *) secretKey
      {
    
      NSString *checkURL = @"https://pay.paymentnepal.com/alba/ack3ds";
    
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:emitentResponse
                                                       options:0
                                                         error:&error];
    
      NSString *emitentResponseJSON;
   
      emitentResponseJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
      NSMutableDictionary *paymentParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"service_id": serviceId,
                                                                                         @"tid": [orderId stringValue],
                                                                                         @"emitent_response": emitentResponseJSON,
                                                                                         @"version": @"2.0"
                                                                                         }];
    
      GPSRestRequester *requester = [[GPSRestRequester alloc] init];
    
      [requester request:checkURL andMethod:@"post" andParams: paymentParams andSecret:secretKey];

      NSLog(@"Ответ 3ds: %@",requester.responseJSONData);  
}
```

#### Get transaction state:

```objective-c
       TransactionDetails details = service.transactionDetails(response.getSessionKey());
       if (details.getStatus() == TransactionStatus.PAYED || details.getStatus() == TransactionStatus.SUCCESS) {
          // successfully payed
       } else {
          // not payed
       }
```


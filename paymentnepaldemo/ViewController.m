
#import "ViewController.h"

#import "FSGPSAPI.h"
#import "GPSPayService.h"
#import "GPSTransactionDetails.h"
#import "GPSReccurentParams.h"

#import <SVProgressHUD/SVProgressHUD.h>

// Your service data
#warning Put your data below

#define GPS_SERVICE_ID @"<00000>"
#define GPS_KEY @"<RFI_KEY>"
#define GPS_SECRET @"<RFI_SECRET>"

#define FORM_ERROR_DESCRIPTION @"Error filling form"
#define FORM_WRONG_FIELD_FORMAT @"Invalid field value \"%@\""

@interface ViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *orderIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderSumTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderCommentTextField;

@property (weak, nonatomic) IBOutlet UITextField *PANTextField;
@property (weak, nonatomic) IBOutlet UITextField *expiryDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardholderTextField;
@property (weak, nonatomic) IBOutlet UITextField *CVCTextField;

@property (strong, nonatomic) FSGPSAPI *paymentAPI;

@property (weak, nonatomic) UIButton *closeWebViewButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}

- (FSGPSAPI *) paymentAPI
{
    if (_paymentAPI == nil)
    {
//        _paymentAPI = [[FSGPSAPI alloc] initWithServideId:GPS_SERVICE_ID key:GPS_KEY andTestMode:YES];
        _paymentAPI = [[FSGPSAPI alloc] initWithServideId:GPS_SERVICE_ID secret:GPS_SECRET andTestMode:YES];
    }
    
    return _paymentAPI;
}


#pragma mark - User interactions

- (IBAction)makePayment:(id)sender {
    
    NSError *error;
    if (![self isFormValid:&error])
    {
        [self showAlertWithError:error];
        return;
    }
    
    [self makePayment];
}

- (void) closeWebView: (UIButton *) sender
{
    [sender removeFromSuperview];
    
    // Найдем среди сабвью WebView
    for (id view in self.view.subviews)
    {
        if ([view isKindOfClass:[UIWebView class]])
        {
            UIWebView *webView = (UIWebView *) view;
            [UIView animateWithDuration:0.4
                                  delay:0
                                options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 
                                 CGRect frame = webView.frame;
                                 frame.origin.y = -1000;
                                 webView.frame = frame;
                                 
                             }completion:^(BOOL finished) {
                                 if (finished)
                                 {
                                     [webView removeFromSuperview];
                                 }
                             }];
            break; // По логике, вебвью один и дальше искать смысла нет
        }
    }
}

#pragma mark - Payment processing

#pragma mark 3D Secure

- (void) showWebViewWithHTMLString: (NSString *) rawHTML
{
    // Тут мы создаем веб-вью за пределами экрана и показываем его с анимацией
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(40, -1024, screenSize.width-30, screenSize.height-80);
    UIWebView *webView = [[UIWebView alloc] initWithFrame: frame];
    
    webView.delegate = self;
    webView.layer.cornerRadius = 10.0;
    webView.clipsToBounds = YES;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(webView.frame.size.width-3, 0, 30, 30);
    
    _closeWebViewButton = closeButton;
    
    [self.view addSubview:webView];
    
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         CGRect frame = webView.frame;
                         frame.origin.y = 25;
                         webView.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             [self.view addSubview:closeButton];
                         }
                     }];
    
    [closeButton addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];
    
    [webView loadHTMLString:rawHTML baseURL:nil];
}

#pragma mark Payment

- (void) makePayment
{
    NSArray<NSString *> *expityDateComponents = [_expiryDateTextField.text componentsSeparatedByString:@"/"];
    
    FSCreditCard *card = [FSCreditCard cardWithPAN:_PANTextField.text
                                     expirityMonth:expityDateComponents[0]
                                      expirityYear:expityDateComponents[1]
                                               CVC:_CVCTextField.text
                                     andCardholder:_cardholderTextField.text];
    
    [SVProgressHUD showWithStatus:@"Sending request to bank"];
    [self.paymentAPI makePaymentWithCard:card
                          orderId:_orderIdTextField.text
                        orderName:_orderNameTextField.text
                          comment:_orderCommentTextField.text
                           andSum:@([_orderSumTextField.text floatValue])
                  successCallback:^{
                      [SVProgressHUD dismiss];
                      [self showSuccessMessage];
                  } secureCallback:^(NSString *htmlFormData) {
                      [SVProgressHUD dismiss];
                      [self showWebViewWithHTMLString: htmlFormData];
                  } failCallback:^(NSError *error) {
                      [SVProgressHUD dismiss];
                      [self showAlertWithError:error];
                  }];
}

// Recurrent payment
- (void) makeReccurentPayment: (NSString *) reccurentOrderId
{
    [SVProgressHUD showWithStatus:@"Sending request to bank"];
    
    [self.paymentAPI makeReccurentPayment:reccurentOrderId
                                orderName:_orderNameTextField.text
                                  comment:_orderCommentTextField.text
                                   andSum:@([_orderSumTextField.text floatValue])
                         successCallback:^{
                             [SVProgressHUD dismiss];
                             [self showSuccessMessage];
                         }
                         failCallback:^(NSError *error) {
                             [SVProgressHUD dismiss];
                             [self showAlertWithError:error];
                         }];
}

- (void) checkTransaction
{
    [SVProgressHUD showWithStatus:@"Checking payment"];
    
    GPSPayService *payService = [[GPSPayService alloc] initWithServiceId:GPS_SERVICE_ID  andKey: GPS_KEY];
    
    [payService transactionDetailsWithSessionKey: [self.paymentAPI sessionKey] successBlock:^(GPSTransactionDetails *transactionDetails) {
        
        [SVProgressHUD dismiss];
        
        if ([transactionDetails.status isEqualToString:@"success" ])
        {
            [self showSuccessMessage];
        }else{
            NSLog(@"status is %@", transactionDetails.status);
            NSError *error = [self errorWithDescription:@"Payment error" andReason:@"Unable to finish payment. Make suer there is sufficient funds on your bank card or refer to your card issuer to figure out the reason of decline."];
            [self showAlertWithError:error];
        }
    }
     failure:^(NSDictionary * error){
            [SVProgressHUD dismiss];
         NSError *error1 = [self errorWithDescription:@"Payment error" andReason:@"Unknown error"];
         [self showAlertWithError:error1];
     }];
}

#pragma mark - Form validation

- (BOOL) isFormValid:(NSError  **) outError {
    
    // Simple form validation
    // This validation is not suitable for production service, do not attempt to copy it!
    
    if ([_orderIdTextField.text intValue] <= 0)
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                     andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Order id"]];
        return NO;
    }
    
    if ([_orderNameTextField.text length] == 0)
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Name"]];
        return NO;
    }
    
    if ([_orderSumTextField.text floatValue] <= .0f)
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Order id"]];
        return NO;
    }
    
    if ([_PANTextField.text length] < 16)
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Card number"]];
        return NO;
    }
    
    NSArray<NSString *> *expityDateComponents = [_expiryDateTextField.text componentsSeparatedByString:@"/"];
    if (expityDateComponents.count != 2 ||
        [expityDateComponents[0] intValue] < 1 ||
        [expityDateComponents[0] intValue] > 12 ||
        [expityDateComponents[1] intValue] < 17
        )
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Card exp date"]];
        return NO;
    }
    
    NSArray<NSString *> *cardholderNameComponents = [_cardholderTextField.text componentsSeparatedByString:@" "];
    if (cardholderNameComponents.count != 2)
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"Cardholder"]];
        return NO;
    }
    
    if ([_CVCTextField.text length] != 3 ||
        ([_CVCTextField.text intValue] == 0 && ![_CVCTextField.text isEqualToString:@"000"] ) )
    {
        *outError = [self errorWithDescription:FORM_ERROR_DESCRIPTION
                                                          andReason:[NSString stringWithFormat:FORM_WRONG_FIELD_FORMAT, @"CVC"]];
        return NO;
    }
    
    return YES;
}

#pragma mark - Helpers

- (void) showSuccessMessage
{
    [self showAlertWithTitle:@"Successful payment!" andMessage:@"Payment was finished successfully!"];
}

- (void) showAlertWithError: (NSError *) error
{
    [self showAlertWithTitle:error.userInfo[NSLocalizedDescriptionKey] andMessage:error.userInfo[NSLocalizedFailureReasonErrorKey]];
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSError *) errorWithDescription: (NSString *) description andReason: (NSString *) reason
{
    return [NSError errorWithDomain:@"paymentnepaltest" code:100 userInfo:@{
                                                                   NSLocalizedDescriptionKey: description,
                                                                   NSLocalizedFailureReasonErrorKey: reason
                                                                   }];
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView.request.URL.absoluteString isEqualToString:self.paymentAPI.termURL])
    {
        [self closeWebView:_closeWebViewButton];
        [self checkTransaction];
    }
}


@end

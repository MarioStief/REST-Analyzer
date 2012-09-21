//
//  ViewController.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/NSJSONSerialization.h>
#import <Foundation/NSXMLParser.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate> {
    NSArray *httpVerbs;
    NSInteger methodId;
    NSString *urlString;
    NSString *baseUrl;
    NSString *resourcePath;
    NSString *requestHeader;
    NSString *responseHeader;
    NSString *requestBody;
    NSString *responseBody;
    NSMutableString *parsedText;
    NSString *logPath;
    NSDictionary *parsedResponseAsDictionary;
    NSHTTPURLResponse *response;
    NSData *bodyData;
    NSMutableArray *foundResources;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *httpHeaders;
@property (weak, nonatomic) IBOutlet UITextView *headerScrollViewText;
@property (weak, nonatomic) IBOutlet UITextView *contentScrollViewText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outputSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *detectedJSON;
@property (weak, nonatomic) IBOutlet UIImageView *detectedXML;
@property (weak, nonatomic) IBOutlet UIImageView *detectedHTML;
@property (weak, nonatomic) IBOutlet UIImageView *detectedXHTML;
@property (weak, nonatomic) IBOutlet UISegmentedControl *authentication;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *statusCode;
@property (weak, nonatomic) IBOutlet UIScrollView *logOutputView;
@property (weak, nonatomic) IBOutlet UITextView *logOutputViewText;
@property (weak, nonatomic) IBOutlet UITextField *contentType;
@property (weak, nonatomic) IBOutlet UITextField *encoding;
@property (weak, nonatomic) IBOutlet UITableView *resourceTableView;
@property (weak, nonatomic) IBOutlet UITableViewCell *resourceTableViewCell;
@property (weak, nonatomic) IBOutlet UIButton *showResourcesButton;

- (IBAction)go:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (IBAction)logRefreshButton:(id)sender;
- (IBAction)logClearButton:(id)sender;
- (void)startRequest:(NSString*)requestMethodString;
- (void)parseResponse;
- (void)checkStatusCode:(NSInteger)code;

@end
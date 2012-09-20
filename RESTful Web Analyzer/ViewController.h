//
//  ViewController.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/RKJSONParserJSONKit.h>
#import <Foundation/NSJSONSerialization.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, RKRequestDelegate> {
    NSArray *httpVerbs;
    NSString *urlString;
    NSString *baseUrl;
    NSString *resourcePath;
    NSString *requestText;
    NSString *responseText;
    NSMutableString *parsedText;
    NSString *logPath;
    NSArray *parsedJSONResponseKeysAsArray;
    NSDictionary *parsedJSONResponseAsDictionary;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *httpHeaders;
@property (weak, nonatomic) IBOutlet UITextView *scrollViewText;
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
@property (weak, nonatomic) IBOutlet UIScrollView *resourcesScrollView;
@property (weak, nonatomic) IBOutlet UITableView *resourcesTableView;

- (IBAction)go:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (IBAction)logRefreshButton:(id)sender;
- (IBAction)logClearButton:(id)sender;
- (void)startRequest:(NSInteger)methodId;
- (void)get;
//- (void)post;
//- (void)put;
//- (void)delete;
- (void)head;
- (void)processResponse:(RKResponse*)response;

@end
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
#import "ResourcesTableViewController.h"
#import "XMLParser.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
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
    NSIndexPath *indexPath;
    NSInteger numberOfRows;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *headerScrollViewText;
@property (weak, nonatomic) IBOutlet UITextView *contentScrollViewText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outputSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *detectedJSON;
@property (weak, nonatomic) IBOutlet UIImageView *detectedXML;
@property (weak, nonatomic) IBOutlet UIImageView *detectedHTML;
@property (weak, nonatomic) IBOutlet UIImageView *detectedXHTML;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *statusCode;
@property (weak, nonatomic) IBOutlet UIScrollView *logOutputView;
@property (weak, nonatomic) IBOutlet UITextView *logOutputViewText;
@property (weak, nonatomic) IBOutlet UITextField *authentication;
@property (weak, nonatomic) IBOutlet UITextField *contentType;
@property (weak, nonatomic) IBOutlet UITextField *encoding;
@property (weak, nonatomic) IBOutlet UIButton *showResourcesButton;
@property (weak, nonatomic) IBOutlet UITableView *headersTableView;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (weak, nonatomic) IBOutlet UITextField *fontSize;

- (IBAction)go:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (IBAction)loggingOutput:(id)sender;
- (IBAction)logRefreshButton:(id)sender;
- (IBAction)logClearButton:(id)sender;
- (IBAction)addKeyValue:(id)sender;
- (void)startRequest:(NSString*)requestMethodString;
//- (void)parseResponse;
- (void)checkStatusCode:(NSInteger)code;
- (IBAction)fontSizeSliderMove:(id)sender;
- (void)switchSegmentIndex;

@end
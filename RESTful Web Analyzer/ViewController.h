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
#import "HistoryElement.h"
#import "LogOutputViewController.h"
#import "HeaderKeysViewController.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSArray *httpVerbs;
    NSInteger methodId;
//    NSString *baseUrl;
//    NSMutableString *resourcePath;
    NSString *requestHeader;
    NSString *responseHeader;
    NSString *requestBody;
    NSString *responseBody;
    NSMutableString *parsedText;
    NSString *logPath;
    NSMutableArray *keyArray;
    NSMutableArray *valueArray;
    NSHTTPURLResponse *response;
    NSMutableData *responseBodyData;
    NSMutableArray *foundResourceKeys;
    NSMutableArray *foundResourceValues;
    NSMutableDictionary *foundResourcesValidateConnections;
    //NSIndexPath *indexPath;
    NSInteger numberOfRows;
    HistoryElement *historyElement;
    NSArray *generalHeaders;
    NSArray *requestHeaders;
    NSInteger responseLength;
    NSTimer *awaitingResponse;
    NSMutableString *iter;
    NSTimer *orientationChangeTimer;
    UIDeviceOrientation preTimerOrientation;
    NSMutableArray *headerKeysArray;
    NSMutableArray *headerValuesArray;
    BOOL validatingResourcesState;
    NSInteger resourcesToValidate;
    NSInteger validatedResources;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *headerScrollViewText;
@property (weak, nonatomic) IBOutlet UITextView *contentScrollViewText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outputSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *detectedJSON;
@property (weak, nonatomic) IBOutlet UIImageView *detectedXML;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *statusCode;
@property (weak, nonatomic) IBOutlet UITextField *authentication;
@property (weak, nonatomic) IBOutlet UITextField *contentType;
@property (weak, nonatomic) IBOutlet UITextField *encoding;
@property (weak, nonatomic) IBOutlet UIButton *showResourcesButton;
@property (weak, nonatomic) IBOutlet UITableView *headersTableView;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (weak, nonatomic) IBOutlet UITextField *fontSize;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIProgressView *loadProgressBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicatorView;
@property (weak, nonatomic) IBOutlet UITextField *addMethodTextField;
@property (weak, nonatomic) IBOutlet UISwitch *logToFileSwitch;
@property (weak, nonatomic) IBOutlet UILabel *verboseLogLabel;
@property (weak, nonatomic) IBOutlet UISwitch *verboseLogSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logFileButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bodyHeaderSwitch;
@property (weak, nonatomic) IBOutlet UILabel *progressBarDescription;


- (IBAction)go:(id)sender;
- (IBAction)bodyHeaderToggle:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (IBAction)loggingOutput:(id)sender;
- (IBAction)addKeyValue:(id)sender;
- (void)startRequest:(NSString*)requestMethodString;
- (void)parseResponse;
- (void)checkStatusCode:(NSInteger)code;
- (IBAction)fontSizeSliderMove:(id)sender;
- (void)switchSegmentIndex;
- (IBAction)backButton:(id)sender;
- (IBAction)baseUrlButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
- (IBAction)clearUrlField:(id)sender;
- (NSString*)urlPart:(NSString*)urlString definePart:(NSString*)part;
- (IBAction)addMethodButton:(id)sender;
- (IBAction)logToFileSwitch:(id)sender;
- (IBAction)Impressum:(id)sender;

@end
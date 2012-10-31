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
    // justification for being global variables:
    
    // needed for the picker view:
    NSArray *httpVerbs;
    // needed for table view:
    NSInteger numberOfRows;
    // needed for the headers table view:
    NSArray *generalHeaders;
    NSArray *requestHeaders;
    // data containing objects - needed for the mvc architecture
    NSMutableArray *headerKeysArray;
    NSMutableArray *headerValuesArray;

    // for being able to be loaded into scroll view anytime:
    NSString *requestHeader;
    NSString *responseHeader;
    NSString *requestBody;
    NSString *responseBody;
    NSMutableString *parsedText;
    
    // is accessed from invoked methods you can't pass a variable to
    NSString *logPath;
    
    // Basic structure concept of all keys/values...
    NSMutableArray *keyArray;
    NSMutableArray *valueArray;
    // ... its resource candidates...
    NSMutableDictionary *foundResourcesValidateConnections;
    // ... and the confirmed resources.
    NSMutableArray *foundResourceKeys;
    NSMutableArray *foundResourceValues;

    // add up data for unfinished responses for processing when load did finish
    NSMutableData *responseBodyData;
    
    // actual active history element with connection to its pre- and postdecessors
    HistoryElement *historyElement;
    
    // didReceiveData needs to know the length for calculating the progress bar
    // or the indicator view - cannot pass parameters to that methos
    NSInteger responseLength;
    
    // NO: "normal" state, YES: "validating resources" state
    BOOL validatingResourcesState;
    
    // didReceiveResponse can't receive parameters either,
    // needed to know actual progress of validating
    NSInteger resourcesToValidate;
    NSInteger validatedResources;
    
    // because the check for valid resources is a asynchronous request and the responsed comes without order
    // adding the resources at the right index keeps an order for them
    NSInteger staticIndex;
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

- (void)viewDidLoad;
- (void)viewDidUnload;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (NSInteger)tableView:(UITableView *)headersTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)headersTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (IBAction)clearUrlField:(id)sender;
- (IBAction)addKeyValue:(id)sender;
- (void)tableView:(UITableView*)headersTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)headersTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)path;
- (void)switchSegmentIndex;
- (IBAction)outputToggle:(id)sender;
- (IBAction)loggingOutput:(id)sender;
- (IBAction)fontSizeSliderMove:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)baseUrlButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
- (IBAction)bodyHeaderToggle:(id)sender;
- (IBAction)go:(id)sender;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (NSString*)urlPart:(NSString*)urlString definePart:(NSString*)part;
- (IBAction)addMethodButton:(id)sender;
- (IBAction)logToFileSwitch:(id)sender;
- (IBAction)Impressum:(id)sender;
- (void)startRequest:(NSString*)requestMethodString
        withMethodId:(NSInteger)methodId;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)parseResponse;
- (void)processKeys:(NSArray*)localKeys
         withValues:(NSArray*)localValues
          iteration:(NSMutableString*)iter;
- (void)validateURL:(NSURL*)link
            withKey:(NSString*)key
          withIndex:(NSInteger)i;
- (void)validateDidFinish;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (void)checkStatusCode:(NSInteger)code;

@end
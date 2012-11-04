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
    
    // actual active history element with connection to its pre- and sucessors
    HistoryElement *historyElement;
    
    // didReceiveData needs to know the length for calculating the progress bar
    // or the indicator view - cannot pass parameters to that methods
    NSInteger responseLength;
    
    // didReceiveResponse can't receive parameters either,
    // needed to know actual progress of validating
    NSInteger resourcesToValidate;
    NSInteger validatedResources;
    
    // because the check for valid resources is a asynchronous request and the responded comes without order
    // adding the resources at the right index keeps an order for them
    NSInteger staticIndex;
}

// changing state: NO = "normal" state, YES = "validating resources" state
@property (nonatomic) BOOL validatingState;

// upper area: input and info fields
@property (nonatomic) IBOutlet UITextField *url;
@property (nonatomic) IBOutlet UITextField *username;
@property (nonatomic) IBOutlet UITextField *password;
@property (nonatomic) IBOutlet UITextField *statusCode;
@property (nonatomic) IBOutlet UITextField *authentication;
@property (nonatomic) IBOutlet UITextField *contentType;
@property (nonatomic) IBOutlet UITextField *encoding;
@property (nonatomic) IBOutlet UITextField *keyTextField;
@property (nonatomic) IBOutlet UITextField *valueTextField;
@property (nonatomic) IBOutlet UIImageView *detectedJSON;
@property (nonatomic) IBOutlet UIImageView *detectedXML;

// opening the detected resources here
@property (nonatomic) IBOutlet UIButton *showResourcesButton;

// history
@property (nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic) IBOutlet UIButton *forwardButton;
@property (nonatomic) IBOutlet UIButton *logFileButton;

// method picker
@property (nonatomic) IBOutlet UIPickerView *requestMethod;
@property (nonatomic) IBOutlet UITextField *addMethodTextField;

// header table view
@property (nonatomic) IBOutlet UITableView *headersTableView;

// main request/response/parsed output for header and body
@property (nonatomic) IBOutlet UIScrollView *scrollView; // container
@property (nonatomic) IBOutlet UISegmentedControl *bodyHeaderSwitch;
@property (nonatomic) IBOutlet UITextView *headerScrollViewText;
@property (nonatomic) IBOutlet UITextView *contentScrollViewText;
@property (nonatomic) IBOutlet UIProgressView *loadProgressBar;
@property (nonatomic) IBOutlet UILabel *progressBarDescription;
@property (nonatomic) IBOutlet UIActivityIndicatorView *loadIndicatorView;
@property (nonatomic) IBOutlet UISegmentedControl *outputSwitch;
@property (nonatomic) IBOutlet UITextField *fontSize;
@property (nonatomic) IBOutlet UISlider *fontSizeSlider;

// logging corner
@property (nonatomic) IBOutlet UISwitch *logToFileSwitch;
@property (nonatomic) IBOutlet UISwitch *verboseLogSwitch;
@property (nonatomic) IBOutlet UILabel *verboseLogLabel;

/* UIPicker methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
*/

/* UITableView methods
- (NSInteger)tableView:(UITableView *)headersTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)headersTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)headersTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)headersTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)path;
*/

// ********* Buttons and Switches *********
- (IBAction)clearUrlField:(id)sender;
- (IBAction)addKeyValue:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (IBAction)loggingOutput:(id)sender;
- (IBAction)fontSizeSliderMove:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)baseUrlButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
- (IBAction)bodyHeaderToggle:(id)sender;
- (IBAction)go:(id)sender;
- (IBAction)addMethodButton:(id)sender;
- (IBAction)logToFileSwitch:(id)sender;
- (IBAction)Impressum:(id)sender;
// ****************************************

// ******************************** implementations responding to a system generated message ********************************
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
// **************************************************************************************************************************

// *********************** additional methods ***********************
- (void)switchSegmentIndex;
- (NSString*)urlPart:(NSString*)urlString definePart:(NSString*)part;
- (void)startRequest:(NSString*)requestMethodString
        withMethodId:(NSInteger)methodId;
- (void)parseResponse;
- (void)processKeys:(NSArray*)localKeys
         withValues:(NSArray*)localValues
          iteration:(NSMutableString*)iter;
- (void)validateURL:(NSURL*)link
            withKey:(NSString*)key
          withIndex:(NSInteger)i;
- (void)validateDidFinish;
- (void)checkStatusCode:(NSInteger)code;
// ******************************************************************

@end
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

@interface ViewController : UIViewController <UITextFieldDelegate, RKRequestDelegate> {
    NSArray *httpVerbs;
    NSString* urlString;
    NSString* baseUrl;
    NSString* resourcePath;
    NSString* requestText;
    NSString* responseText;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
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

- (IBAction)go:(id)sender;
- (IBAction)outputToggle:(id)sender;
- (void)startRequest:(NSInteger)methodId;
- (void)splitUrl;
- (void)get;
//- (void)post;
//- (void)put;
//- (void)delete;
- (void)head;
- (void)processResponse:(RKResponse*)response;

@end
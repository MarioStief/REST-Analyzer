//
//  ViewController.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import <UIKit/UIKit.h>
#import "ObjectMapper.h"
#import <RestKit/ObjectMapping.h>

@interface ViewController : UIViewController <UITextFieldDelegate> {
    NSArray *httpVerbs;
    ObjectMapper* mapper;
}

@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIPickerView *requestMethod;
- (IBAction)go:(id)sender;
- (void)startRequest:(NSInteger)methodId;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITableView *httpHeaders;

@end
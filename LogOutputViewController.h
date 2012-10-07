//
//  LogOutputViewController.h
//  REST Analyzer
//
//  Created by Mario Stief on 10/7/12.
//
//

#import <UIKit/UIKit.h>

@interface LogOutputViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *logOutputViewText;
@property (nonatomic, strong) NSString *referenceToLogPath;


- (IBAction)logClearButton:(id)sender;

@end
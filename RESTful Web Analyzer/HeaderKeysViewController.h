//
//  HeaderKeysViewController.h
//  REST Analyzer
//
//  Created by Mario Stief on 10/9/12.
//
//

#import <UIKit/UIKit.h>

@interface HeaderKeysViewController : UITableViewController <UITextFieldDelegate> {
}

@property (strong, nonatomic) NSArray *generalHeaders;
@property (strong, nonatomic) NSArray *requestHeaders;
@property (strong, nonatomic) UITextField *referenceToHeaderKey;
@property (strong, nonatomic) UITextField *referenceToHeaderValue;
@property (nonatomic, strong) UIPopoverController *referenceToPopoverController;

@end

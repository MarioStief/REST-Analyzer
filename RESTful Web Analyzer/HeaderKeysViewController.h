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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end

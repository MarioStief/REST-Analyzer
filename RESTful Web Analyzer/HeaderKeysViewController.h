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

@property (nonatomic) NSArray *generalHeaders;
@property (nonatomic) NSArray *requestHeaders;
@property (nonatomic) UITextField *referenceToHeaderKey;
@property (nonatomic) UITextField *referenceToHeaderValue;
@property (nonatomic) UIPopoverController *referenceToPopoverController;

- (void)viewDidLoad;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end

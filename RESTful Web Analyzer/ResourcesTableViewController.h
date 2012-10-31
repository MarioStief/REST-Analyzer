//
//  ResourcesTableViewController.h
//  REST Analyzer
//
//  Created by Mario Stief on 9/24/12.
//
//

#import <UIKit/UIKit.h>

@interface ResourcesTableViewController : UITableViewController {
    NSArray *resourcesAsArray;
}

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSArray *values;
// passed references to work with the underlying view
@property (nonatomic, strong) UITextField *referenceToUrl;
@property (nonatomic, strong) UIPopoverController *referenceToPopoverController;
@property (nonatomic, strong) NSString *referenceToHighestDir;
@property (nonatomic, strong) NSString *referenceToBaseUrl;

- (id)initWithStyle:(UITableViewStyle)style;
- (void)viewDidLoad;
- (NSArray *)dissectURL:(NSString *)urlString;
- (void)didReceiveMemoryWarning;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (void)viewDidUnload;

@end

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

@property (nonatomic) NSArray *keys;
@property (nonatomic) NSArray *values;
// passed references to work with the underlying view
@property (nonatomic) UITextField *referenceToUrl;
@property (nonatomic) UIPopoverController *referenceToPopoverController;
@property (nonatomic) NSString *referenceToHighestDir;
@property (nonatomic) NSString *referenceToBaseUrl;

- (NSArray *)dissectURL:(NSString *)urlString;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

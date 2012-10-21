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

- (NSArray *)dissectURL:(NSString *)urlString;

@end

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

@property (nonatomic, strong) NSDictionary *resourcesAsDictionary;
// passed references to work with the underlying view
@property (nonatomic, strong) UITextField *referenceToUrl;
@property (nonatomic, strong) UIPopoverController *referenceToPopoverController;
@property (nonatomic, strong) NSString *referenceToBaseUrl;

- (NSArray *)dissectURL:(NSString *)urlString;

@end

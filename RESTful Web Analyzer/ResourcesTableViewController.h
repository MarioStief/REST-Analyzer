//
//  ResourcesTableViewController.h
//  REST Analyzer
//
//  Created by Mario Stief on 9/24/12.
//
//

#import <UIKit/UIKit.h>

@interface ResourcesTableViewController : UITableViewController {
    //NSDictionary *_resourcesAsDictionary;
}

@property(nonatomic,retain)NSDictionary *resourcesAsDictionary;

- (id)initWithDictionary:(NSDictionary*)dic;

@end

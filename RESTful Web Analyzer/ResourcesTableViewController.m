//
//  ResourcesTableViewController.m
//  REST Analyzer
//
//  Created by Mario Stief on 9/24/12.
//
//

#import "ResourcesTableViewController.h"


@implementation ResourcesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray *)dissectURL:(NSString *)urlString {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *resourcePath;
    // ********** Begin URL Processing **********
    
    // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])
        urlString = ([[NSString alloc] initWithFormat:@"http://%@", urlString]);
    
    // URL endet mit "/" -> weg damit.
    if ([urlString hasSuffix:@"/"])
        urlString = [urlString substringToIndex:[urlString length]-1];
    
    // Trennung in BaseURL und ResourceURL
    NSArray *urlComponents = [[NSArray alloc] initWithArray:[urlString pathComponents]];
    [array addObject:[NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]]];
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    [array addObject:resourcePath];
    
    // ********** End URL Processing **********

    return array;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [_keys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Resources";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...

    NSString *key = [[NSString alloc] initWithFormat:@"%@",[_keys objectAtIndex:[indexPath row]]]; // stürzt nicht ab im Gegensatz zu InitWithString wenn nil
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:[_values objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *resource = [_values objectAtIndex:[indexPath row]];
    
    // passing resource to url text field in the main view
    if ([resource hasPrefix:@"http://"] || [resource hasPrefix:@"https://"])
        // Is a URL. Passing to main controller.
        [_referenceToUrl setText:resource];
    else if ([resource hasPrefix:@"/"])
        // prefix / - use the former base URL in combination with that.
        [_referenceToUrl setText:[[NSString alloc] initWithFormat:@"%@%@",_referenceToBaseUrl,resource]];
    else
        // Neither http nor / as prefix
        [_referenceToUrl setText:[[NSString alloc] initWithFormat:@"%@%@",_referenceToHighestDir,resource]];
    
    // Use the passed reference to the popover cntroller to dismiss this view.
    [_referenceToPopoverController dismissPopoverAnimated:YES];
}
/*
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    //[self dismissViewControllerAnimated:YES completion:NULL];
    //or better yet
    [self dismissModalViewControllerAnimated:YES];
    //the latter works fine for Modal segues
}*/

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

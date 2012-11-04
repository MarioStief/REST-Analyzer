//
//  HeaderKeysViewController.m
//  REST Analyzer
//
//  Created by Mario Stief on 10/9/12.
//
//

#import "HeaderKeysViewController.h"

@implementation HeaderKeysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _generalHeaders = [[NSArray alloc]initWithObjects:@"Cache-Control",@"Connection",@"Content-Encoding",@"Content-Language",@"Content-Length",@"Content-Location",@"Content-MD5",@"Content-Range",@"Content-Type",@"Pragma",@"Trailer",@"Via",@"Warning",@"Transfer-Encoding",@"Upgrade",nil];
    _requestHeaders = [[NSArray alloc]initWithObjects:@"Accept",@"Accept-Charset",@"Accept-Encoding",@"Accept-Language",@"Accept-Ranges",@"Authorization",@"Depth",@"Destination",@"Expect",@"From",@"Host",@"If",@"If-Match",@"If-Modified-Since",@"If-None-Match",@"If-Range",@"If-Unmodified-Since",@"Lock-Token",@"Max-Forwards",@"Overwrite",@"Proxy-Authorization",@"Range",@"Referer",@"TE",@"Timeout",@"User-Agent",nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return [_generalHeaders count];
    else
        return [_requestHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"General Headers";
    else
        return @"Request Headers";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSString *cellText;
    if ([indexPath section] == 0)
        cellText = [[NSString alloc] initWithFormat:@"%@",[_generalHeaders objectAtIndex:[indexPath row]]];
    else
        cellText = [[NSString alloc] initWithFormat:@"%@",[_requestHeaders objectAtIndex:[indexPath row]]];
    
    [[cell textLabel] setText:cellText];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0)
        [_referenceToHeaderKey setText:[_generalHeaders objectAtIndex:[indexPath row]]];
    else
        [_referenceToHeaderKey setText:[_requestHeaders objectAtIndex:[indexPath row]]];
    // Use the passed reference to the popover controller to dismiss this view.
    [_referenceToHeaderValue becomeFirstResponder];
    [_referenceToPopoverController dismissPopoverAnimated:YES];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    //or better yet
    [self dismissModalViewControllerAnimated:YES];
    //the latter works fine for Modal segues
}

@end

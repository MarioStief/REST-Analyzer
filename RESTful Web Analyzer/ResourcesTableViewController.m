//
//  ResourcesTableViewController.m
//  REST Analyzer
//
//  Created by Mario Stief on 9/24/12.
//
//

#import "ResourcesTableViewController.h"


@implementation ResourcesTableViewController

/*
- (id)initWithDictionary:(NSDictionary*)dic {
    if (self = [super init])
        //resourcesAsDictionary = [[NSDictionary alloc] initWithDictionary:dic];
        resourcesAsDictionary = [dic copy];
    NSLog(@"resource table created with %i entries.",[resourcesAsDictionary count]);
    return self;
}
 */

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //NSLog(@"resourcesAsDictionary count: %i",[self.resourcesAsDictionary count]);
    //NSLog(@"resourcesAsArray count: %i", [resourcesAsArray count]);
    //NSLog(@"resourcesAsDictionary: %@", self.resourcesAsDictionary);
    //NSLog(@"resourcesAsArray: %@", resourcesAsArray);

# pragma mark dissecting url in baseUrl and resource
    /*
    for (int i = 0; i < [resourcesAsArray count]; i++) {
        NSString *key = [[NSString alloc] initWithString:[resourcesAsArray objectAtIndex:i]];
        NSLog(@"key %i: %@",i, key);
        NSString *value = [[NSString alloc] initWithString:[self.resourcesAsDictionary valueForKey:key]];
        NSLog(@"value %i: %@",i, value);
        NSArray *array = [self dissectURL:value];
        NSLog(@"array %i: %@",i, array);
        //NSLog(@"%@",array);
    }
     */
    
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

/*
 - (void)viewWillAppear:(BOOL)animated {
//    _keys = [[NSArray alloc] initWithArray:[_resourcesAsDictionary allKeys]];
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
/*
    NSLog(@"indexPath row: %d",[indexPath row]);
    NSLog(@"objectAtIndex:[indexPath row]: %@",[resourcesAsArray objectAtIndex:[indexPath row]]);
*/
    NSString *key = [[NSString alloc] initWithFormat:@"%@",[_keys objectAtIndex:[indexPath row]]]; // stürzt nicht ab im Gegensatz zu InitWithString wenn nil
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [_values objectAtIndex:[indexPath row]];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSString *resource = [_values objectAtIndex:[indexPath row]];
    
    // passing resource to url text field in the main view
    if ([resource hasPrefix:@"http://"])
        // Is a URL. Passing to main controller.
        _referenceToUrl.text = resource;
    else if ([resource hasPrefix:@"/"])
        // It's just the resource. Use the former base URL in combination with that.
        _referenceToUrl.text = [[NSString alloc] initWithFormat:@"%@%@",_referenceToBaseUrl,resource];
    else
        // Neither url nor resource. Should not be possible to land here. But in case... 
        NSLog(@"This shouldn't be happening.");
    
    // Use the passed reference to the popover cntroller to dismiss this view.
    [_referenceToPopoverController dismissPopoverAnimated:YES];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    //or better yet
    [self dismissModalViewControllerAnimated:YES];
    //the latter works fine for Modal segues
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

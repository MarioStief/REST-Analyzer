//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import "ViewController.h"

@implementation ViewController
@synthesize scrollView;
@synthesize scrollViewText;
@synthesize httpHeaders;
@synthesize outputSwitch;
@synthesize detectedJSON;
@synthesize detectedXML;
@synthesize detectedHTML;
@synthesize detectedXHTML;
@synthesize authentication;
@synthesize username;
@synthesize password;
@synthesize statusCode;
@synthesize logOutputView;
@synthesize logOutputViewText;
@synthesize resourcesScrollView;
@synthesize resourcesTableView;
@synthesize requestMethod;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Logging to File
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
     
	// Do any additional setup after loading the view, typically from a nib.
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
    parsedText = [[NSMutableString alloc] init];
    self.navigationItem.title = @"Parsed Resources"; // <---------------------------------------- geht auch ohne?
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
}

- (void)viewDidUnload
{
//    [self setUrl:nil];
    [self setRequestMethod:nil];
    [self setScrollView:nil];
    [self setHttpHeaders:nil];
    [self setDetectedJSON:nil];
    [self setDetectedXML:nil];
    [self setDetectedHTML:nil];
    [self setDetectedXHTML:nil];
    [self setOutputSwitch:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setAuthentication:nil];
    [self setScrollViewText:nil];
    [self setStatusCode:nil];
    [self setLogOutputView:nil];
    [self setLogOutputViewText:nil];
    [self setResourcesScrollView:nil];
    [self setResourcesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Das Keyboard wieder verschwinden lassen
    if (textField == self.url) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return [httpVerbs count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [httpVerbs objectAtIndex:row];
}
/*
// The first method we’ll define is “- numberOfSectionsInTableView:”. This is the number of keys in the countries dictionary:
// TableView braucht 2 Delegates: http://www.iosdevnotes.com/2011/10/uitableview-tutorial/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Die Anzahl der Sections
    return 1;
}

// Now we add a way to get the title of a given section:
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[parsedJSONResponseAsDictionary allKeys] objectAtIndex:section];
}
 */

// Next, we provide a way to return the number of rows for a given section. We can use the method we just defined to get the name of the continent:
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Die Anzahl der Spalten pro Section
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [parsedJSONResponseKeysAsArray objectAtIndex:indexPath.row];
    
    return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *continent = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSString *country = [[parsedJSONResponseAsDictionary valueForKey:continent] objectAtIndex:indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You selected %@!", country] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/
- (IBAction)go:(id)sender {
    [self.url resignFirstResponder];        // On-Screen-Tastatur entfernen
    urlString = self.url.text;
    [self startRequest:[requestMethod selectedRowInComponent:0]]; // den Request starten, die Request-ID mitgeben.
}

- (IBAction)outputToggle:(id)sender {
    switch ([outputSwitch selectedSegmentIndex]) {
        case 0:
            scrollViewText.text = requestText;
            break;
        case 1:
            scrollViewText.text = responseText;
            break;
        case 2:
            scrollViewText.text = parsedText;
    }
    // Hyperlinks erkennen
    // scrollViewText.editable = NO;
    // scrollViewText.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypeLink;
}

- (IBAction)logRefreshButton:(id)sender {
    // Log aus der Datei lesen und auf den Output packen
    NSError *err;
    logOutputViewText.text = [[NSString alloc] initWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:&err];
}

- (IBAction)logClearButton:(id)sender {
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"w+",stderr);
    logOutputViewText.text = @"Yes, Master.";
}

- (void)startRequest:(NSInteger)methodId {
    // Setze Authentifizierung
    [RKClient sharedClient].username = username.text;
    [RKClient sharedClient].password = password.text;
    switch ([authentication selectedSegmentIndex]) {
        case 0:
            [RKClient sharedClient].authenticationType = RKRequestAuthenticationTypeNone;
            break;
        case 1:
            [RKClient sharedClient].authenticationType = RKRequestAuthenticationTypeHTTP;
            break;
        case 2:
            [RKClient sharedClient].authenticationType = RKRequestAuthenticationTypeHTTPBasic;
            break;
        case 3:
            // Not implemented (yet)
            break;
    }
    
    // Splitte die URL auf in Base URL und Ressorcenpfad:
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
        urlString = ([[NSString alloc] initWithFormat:@"http://%@", urlString]);
    
    // Trennung in BaseURL und ResourceURL
    NSArray *urlComponents = [urlString pathComponents];
    baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    resourcePath = @"";
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    
    NSLog(@"BaseURL = \"%@\", ResourcePath =\"%@\"", baseUrl, resourcePath);
    NSString *requestBody;

    // Wähle die auszuführende Methode
    switch (methodId) {
        case 0:
            // GET
            [self get];
            break;
        case 1:
            // POST
            requestBody = [[NSString alloc] initWithFormat:@"%@",[self post]];
            break;
        case 2:
            // PUT
            break;
        case 3:
            // DELETE
            break;
        case 4:
            // HEAD
            break;
    }
    
    // Setze Request-Output-Feld
    requestText = [[NSString alloc] initWithFormat:@"%@",requestBody]; // initWithString würde bei einem leeren String abstürzen
    scrollViewText.text = requestText; // damit der Text direkt angezeigt wird, nicht erst nach dem Wechseln auf Response/Parsed und wieer zurück
}

- (void)get {
    // GET auf die Resource
    [RKClient clientWithBaseURLString:baseUrl];
    [[RKClient sharedClient] get:resourcePath delegate:self];
}

- (NSString*)post {
    // POST auf die Resource *** BAUSTELLE ***
    [RKClient clientWithBaseURLString:baseUrl];
    //NSString* putString = [[NSString alloc] init];
    return [[[RKClient sharedClient] get:resourcePath delegate:self] HTTPBodyString];
}

- (void)head {
    // HEAD auf die Resource
    //[RKClient clientWithBaseURLString:baseUrl];
    //[[RKClient sharedClient]???];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
    // Neuer Request: erst mal Reset
    [detectedJSON setHighlighted:NO];
    [detectedXML setHighlighted:NO];
    [detectedHTML setHighlighted:NO];
    [detectedXHTML setHighlighted:NO];
    [outputSwitch setSelectedSegmentIndex:0];
    responseText = @"";
    parsedText = [[NSMutableString alloc] init];
    
    // Statuscode aktualisieren
    switch ([response statusCode]) {
        case 100:
            statusCode.text = [[NSString alloc] initWithFormat:@"100 - Continue"];
            break;
        case 101:
            statusCode.text = [[NSString alloc] initWithFormat:@"101 - Switching Protocols"];
            break;
        case 200:
            statusCode.text = [[NSString alloc] initWithFormat:@"200 - OK"];
            break;
        case 201:
            statusCode.text = [[NSString alloc] initWithFormat:@"201 - Created"];
            break;
        case 202:
            statusCode.text = [[NSString alloc] initWithFormat:@"202 - Accepted"];
            break;
        case 203:
            statusCode.text = [[NSString alloc] initWithFormat:@"203 - Non-Authoritative Information"];
            break;
        case 204:
            statusCode.text = [[NSString alloc] initWithFormat:@"204 - No Content"];
            break;
        case 205:
            statusCode.text = [[NSString alloc] initWithFormat:@"205 - Reset Content"];
            break;
        case 206:
            statusCode.text = [[NSString alloc] initWithFormat:@"206 - Partial Content"];
            break;
        case 207:
            statusCode.text = [[NSString alloc] initWithFormat:@"207 - Multi-Status"];
            break;
        case 300:
            statusCode.text = [[NSString alloc] initWithFormat:@"300 - Multiple Choices"];
            break;
        case 301:
            statusCode.text = [[NSString alloc] initWithFormat:@"301 - Moved Permanently"];
            break;
        case 302:
            statusCode.text = [[NSString alloc] initWithFormat:@"302 - Found"];
            break;
        case 303:
            statusCode.text = [[NSString alloc] initWithFormat:@"303 - See Other"];
            break;
        case 304:
            statusCode.text = [[NSString alloc] initWithFormat:@"304 - Not Modified"];
            break;
        case 305:
            statusCode.text = [[NSString alloc] initWithFormat:@"305 - Use Proxy"];
            break;
        case 307:
            statusCode.text = [[NSString alloc] initWithFormat:@"307 - Temporary Redirect"];
            break;
        case 400:
            statusCode.text = [[NSString alloc] initWithFormat:@"400 - Bad Request"];
            break;
        case 401:
            statusCode.text = [[NSString alloc] initWithFormat:@"401 - Unauthorized"];
            break;
        case 402:
            statusCode.text = [[NSString alloc] initWithFormat:@"402 - Payment Required"];
            break;
        case 403:
            statusCode.text = [[NSString alloc] initWithFormat:@"403 - Forbidden"];
            break;
        case 404:
            statusCode.text = [[NSString alloc] initWithFormat:@"404 - Not Found"];
            break;
        case 405:
            statusCode.text = [[NSString alloc] initWithFormat:@"405 - Method Not Allowed"];
            break;
        case 406:
            statusCode.text = [[NSString alloc] initWithFormat:@"406 - Not Acceptable"];
            break;
        case 407:
            statusCode.text = [[NSString alloc] initWithFormat:@"407 - Proxy Authentication"];
            break;
        case 408:
            statusCode.text = [[NSString alloc] initWithFormat:@"408 - Request Timeout"];
            break;
        case 409:
            statusCode.text = [[NSString alloc] initWithFormat:@"409 - Conflict"];
            break;
        case 410:
            statusCode.text = [[NSString alloc] initWithFormat:@"410 - Gone"];
            break;
        case 411:
            statusCode.text = [[NSString alloc] initWithFormat:@"411 - Length Required"];
            break;
        case 412:
            statusCode.text = [[NSString alloc] initWithFormat:@"412 - Precondition Failed"];
            break;
        case 413:
            statusCode.text = [[NSString alloc] initWithFormat:@"413 - Request Entity Too Large"];
            break;
        case 414:
            statusCode.text = [[NSString alloc] initWithFormat:@"414 - Request-URI Too Long"];
            break;
        case 415:
            statusCode.text = [[NSString alloc] initWithFormat:@"415 - Unsupported Media Type"];
            break;
        case 416:
            statusCode.text = [[NSString alloc] initWithFormat:@"416 - Requested Range Not Satisfiable"];
            break;
        case 417:
            statusCode.text = [[NSString alloc] initWithFormat:@"417 - Expectation Failed"];
            break;
        case 422:
            statusCode.text = [[NSString alloc] initWithFormat:@"422 - Unprocessable Entity"];
            break;
        case 423:
            statusCode.text = [[NSString alloc] initWithFormat:@"423 - Locked"];
            break;
        case 424:
            statusCode.text = [[NSString alloc] initWithFormat:@"424 - Failed Dependency"];
            break;
        case 500:
            statusCode.text = [[NSString alloc] initWithFormat:@"500 - Internal Server Error"];
            break;
        case 501:
            statusCode.text = [[NSString alloc] initWithFormat:@"501 - Not Implemented"];
            break;
        case 502:
            statusCode.text = [[NSString alloc] initWithFormat:@"502 - Bad Gateway"];
            break;
        case 503:
            statusCode.text = [[NSString alloc] initWithFormat:@"503 - Service Unavailable"];
            break;
        case 504:
            statusCode.text = [[NSString alloc] initWithFormat:@"504 - Gateway Timeout"];
            break;
        case 505:
            statusCode.text = [[NSString alloc] initWithFormat:@"505 - HTTP Version Not Supported"];
            break;
        case 507:
            statusCode.text = [[NSString alloc] initWithFormat:@"507 - Insufficient Storage"];
            break;
    }
    
    // Egal welcher Fehlercode, RestKit liefert einen Body
    responseText = [response bodyAsString];
//    NSError *err = nil;
//    NSData *responseBody = [NSJSONSerialization dataWithJSONObject:[response body] options:NSJSONWritingPrettyPrinted error:&err];
//    responseText = [[NSString alloc] initWithData:responseBody encoding:NSASCIIStringEncoding]; // <------------------------------
    

//    NSArray *array = [NSJSONSerialization JSONObjectWithData:[response body] options:NSJSONWritingPrettyPrinted error:&err];

    scrollViewText.text = responseText;
    [outputSwitch setSelectedSegmentIndex:1]; // zum Response-Tab wechseln
    
    if ([response isOK]) {
        if ([request isGET]) {
            // Handling GET /foo.xml
        
            // Success! Let's take a look at the data
            [self processResponse:response];
        
        } else if ([request isPOST]) {
        
            // Handling POST /other.json
            if ([response isJSON]) {
                NSLog(@"Got a JSON response back from our POST!");
            }
        
        } else if ([request isPUT]) {
        
            // Handling PUT
            if ([response isJSON]) {
                NSLog(@"Got a JSON response back from our PUT!");
            }
    
        } else if ([request isDELETE]) {
        
            // Handling DELETE /missing_resource.txt
            if ([response isNotFound]) {
                NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
            }

        } else if ([request isHEAD]) {
        
            // Handling POST /other.json
            if ([response isJSON]) {
                NSLog(@"Got a JSON response back from our HEAD!");
                [self processResponse:response];
            }
        }
    }
}

- (void)processResponse:(RKResponse*)response {
    //Egal, welcher Content angezeigt wird, versuche dennoch zu parsen. Manchmal stimmt der MIME nicht (bsp "text/html" statt "text/json"):
    NSError *err = nil;
//    NSArray *array = [NSJSONSerialization JSONObjectWithData:[response body] options:NSJSONWritingPrettyPrinted error:&err];
    parsedJSONResponseAsDictionary = [NSJSONSerialization JSONObjectWithData:[response body] options:NSJSONWritingPrettyPrinted error:&err];
    parsedJSONResponseKeysAsArray = [parsedJSONResponseAsDictionary allKeys];
    
    if (!parsedJSONResponseKeysAsArray) {
        [parsedText appendString:@"Error in parsing response."];
    } else {
        
        // Erstelle die TableView
        
        
        // Parse die einzelnen Einträge und sortiere nach Key und Value:
        
        for(NSString *item in parsedJSONResponseKeysAsArray) {
            [parsedText appendString:item];
            [parsedText appendString:@": "];
            
            // ********** Arrays: **********
            NSString *string = [[NSString alloc] initWithFormat:@"%@",[parsedJSONResponseAsDictionary valueForKey:item]];
            if ([string hasPrefix:@"{"]) {

                // Array process
                [parsedText appendString:string];
                

                
                
            }
            // *******************************
            else {
                [parsedText appendString:string];
                [parsedText appendString:@", URL: "];
                NSURL *link = [[NSURL alloc] initWithString:string];
                if ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"http"]) {
                    [parsedText appendString:@"yes\n"];
                }
                else
                    [parsedText appendString:@"no\n"];
            }
        }
    }
    
    // Bei erkannten Formaten: Format highlighten, auf geparsten Text switchen
                     
    if ([response isJSON]) {
        [detectedJSON setHighlighted:YES];
        scrollViewText.text = parsedText;           //
        [outputSwitch setSelectedSegmentIndex:2];   // da ja dann fehlerfrei geparst werden kann: wechseln.
    }
    else if ([response isXML])
        [detectedXML setHighlighted:YES];
    else if ([response isHTML])
        [detectedHTML setHighlighted:YES];
    else if ([response isXHTML])
        [detectedXHTML setHighlighted:YES];
}

@end

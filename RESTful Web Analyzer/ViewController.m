//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ********** Begin redirect logging output to file **********
    
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
     */

    // ********** End redirect logging output to file **********

	// Do any additional setup after loading the view, typically from a nib.
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
    parsedText = [[NSMutableString alloc] init];
    foundResources = [[NSMutableArray alloc] init];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0]; // Muss einzeln durchgeführt werden,
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1]; // da sonst das Feld permanent
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2]; // ausgeschaltet ist.
    [_showResourcesButton setEnabled:NO];
}

- (void)viewDidUnload
{
    [self setRequestMethod:nil];
    [self setScrollView:nil];
    [self setDetectedJSON:nil];
    [self setDetectedXML:nil];
    [self setDetectedHTML:nil];
    [self setDetectedXHTML:nil];
    [self setOutputSwitch:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setAuthentication:nil];
    [self setStatusCode:nil];
    [self setLogOutputView:nil];
    [self setLogOutputViewText:nil];
    [self setContentType:nil];
    [self setShowResourcesButton:nil];
    [self setHeaderScrollViewText:nil];
    [self setContentScrollViewText:nil];
    [self setEncoding:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO; // Not yet implemented -> not that important.
}

// ********** Remove the onscreen keyboard after pressing "Go" button: **********
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.url) {
        [textField resignFirstResponder];
    }
    return YES;
}

// ********** Begin Setup Picker View **********

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

// ********** End Setup Picker View **********


// ********** Begin Setup Table View **********

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2; //[foundResources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"resourceCell";
    
    UITableViewCell *resourceTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (resourceTableViewCell == nil) {
        resourceTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    
    resourceTableViewCell.textLabel.text = @"Cell";
    resourceTableViewCell.detailTextLabel.text = @"Description";
    /*
    NSString *cellValue = [foundResources objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    cell.detailTextLabel.text = [parsedResponseAsDictionary valueForKey:cellValue];
    */
    return resourceTableViewCell;
}

// ********** End Setup Table View **********


// ********** Using the Request/Response/Parsed output toggle: **********
- (IBAction)outputToggle:(id)sender {
    switch ([_outputSwitch selectedSegmentIndex]) {
        case 0:
            _headerScrollViewText.text = requestHeader;
            _contentScrollViewText.text = requestBody;
            break;
        case 1:
            _headerScrollViewText.text = responseHeader;
            _contentScrollViewText.text = responseBody;
            break;
        case 2:
            _headerScrollViewText.text = responseHeader;
            _contentScrollViewText.text = parsedText;
    }
}

// ********** "Show Logging Output" -> "Refresh" button pressed: **********
- (IBAction)logRefreshButton:(id)sender {
    // reading log from file
    NSError *err;
    _logOutputViewText.text = [[NSString alloc] initWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:&err];
}

// ********** "Show Logging Output" -> "Clear" button pressed: **********
- (IBAction)logClearButton:(id)sender {
    // empty log file
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"w+",stderr);
    _logOutputViewText.text = @"File emptied.";
}

// ********** GO Button Pressed: **********
- (IBAction)go:(id)sender {
    
    // ********** Remove Keyboard **********
    [self.url resignFirstResponder];
    
    // ********** Reading URL **********
    urlString = _url.text;
    
    // ********** New Request started: Do a full reset to avoid side effects **********
    [_detectedJSON setHighlighted:NO];
    [_detectedXML setHighlighted:NO];
    [_detectedHTML setHighlighted:NO];
    [_detectedXHTML setHighlighted:NO];
    [_outputSwitch setSelectedSegmentIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2];
    baseUrl = [[NSString alloc] init];
    resourcePath = [[NSString alloc] init];
    _contentScrollViewText.text = [[NSString alloc] init];
    _headerScrollViewText.text = [[NSString alloc] init];
    requestBody = [[NSString alloc] init];
    responseBody = [[NSString alloc] init];
    parsedText = [[NSMutableString alloc] init];
    
    // ********** First initializations:  **********
    // Index of the selected HTTP method in the picker view:
    methodId = [_requestMethod selectedRowInComponent:0];
    // HTTP method as String:
    NSString *calledMethodString = [[NSString alloc] initWithFormat:@"%@",[httpVerbs objectAtIndex:methodId]];
    // Start request
    [self startRequest:calledMethodString];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    // ********** Begin Authentication **********
    
    /*
     switch ([_authentication selectedSegmentIndex]) {
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
     */
    
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:_username.text
                                                                    password:_password.text
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
    
    // ********** End Authentication **********

}

- (void)startRequest:(NSString*)requestMethodString {
        
    // ********** Begin URL Processing **********
    
    // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])
        urlString = ([[NSString alloc] initWithFormat:@"http://%@", urlString]);
    
    // URL endet mit "/" -> weg damit.
    if ([urlString hasSuffix:@"/"])
        urlString = [urlString substringToIndex:[urlString length]-1];
    
    // Trennung in BaseURL und ResourceURL
    NSArray *urlComponents = [[NSArray alloc] initWithArray:[urlString pathComponents]];
    baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    
    // ********** End URL Processing **********
    
    NSLog(@"********** New Request **********");
    NSLog(@"%@ -> Base URL: \"%@\", Resource Path: \"%@\"",_url.text,baseUrl,resourcePath);
    
    // ********** Begin Request ********** INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE
    // -> Implement POST, PUT, DELETE, HEAD
    
    NSString *string = [[NSString alloc] initWithFormat:@"%@%@",baseUrl,resourcePath];
    NSURL *url = [[NSURL alloc] initWithString:string];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:requestMethodString];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self];
    NSLog(@"Sending Request: %@ %@%@ (%@)",requestMethodString,baseUrl,resourcePath,connection);

    // ********** End Request ********** INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE
    
    
    // ********** Begin Filling Header + Body Fields: REQUEST **********
    
    requestHeader = [[NSString alloc] initWithFormat:@"%@",[[request allHTTPHeaderFields] description]];
    requestBody = [[NSString alloc] initWithFormat:@"%@",[request HTTPBody]];
    _headerScrollViewText.text = requestHeader;
    _contentScrollViewText.text = requestBody;
    [_outputSwitch setEnabled:YES forSegmentAtIndex:0]; // Request-Tab einschalten
    
    // ********** End Filling Header + Body Fields: REQUEST **********

}

-   (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response {

    // ********** Begin Receiving Response Header **********
    
    response = _response;
    NSLog(@"receiving: %@, type: %@, charset: %@, status code: %i",[response description],[response MIMEType],[response textEncodingName],[response statusCode]);
    
	if ([response respondsToSelector:@selector(allHeaderFields)])
        // (NSDictionary*):[response allHeaderFields] -> (NSDic -> NSString):description -> (NSString*):responseHeader
		responseHeader = [[response allHeaderFields] description];

    // ********** End Receiving Response Header **********
}


-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData {
    
    // ********** Begin Receiving Response Body **********
    
    NSLog(@"processing: %@",[response description]);

    bodyData = _bodyData;
    _contentType.text = [response MIMEType]; // Content Type-Feld setzen
    _encoding.text = [response textEncodingName]; // Encodingfeld setzen
    [self checkStatusCode:[response statusCode]]; // Statuscode aktualisieren
    responseBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];

    // ********** End Receiving Response Body **********
    
    
    // ********** Begin Filling Header + Body Fields: RESPONSE **********
    
    _headerScrollViewText.text = responseHeader;
    _contentScrollViewText.text = responseBody;
    [_outputSwitch setSelectedSegmentIndex:1]; // zum Response-Tab wechseln
    [_outputSwitch setEnabled:YES forSegmentAtIndex:1]; // Request-Tab einschalten
    
    // ********** End Filling Header + Body Fields: RESPONSE **********


    // ********** Begin Looking at Response **********
    
    if ([response statusCode] < 400) {
        
        switch (methodId) {
            case 0:
                // GET
                [self parseResponse];
                break;
            case 1:
                // POST
                //requestBody = [[NSString alloc] initWithFormat:@"%@",[self post]];
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
    }
    // ********** End Looking at Response **********

}

- (void)parseResponse {

    // ********** Begin Parsing Response **********
    // Bei erkannten Formaten: zugehöriger Highlighter aktivieren, dann entsprechend parsen

    BOOL parsingSuccess = NO;
    
    if([[response MIMEType] rangeOfString:@"json"].location != NSNotFound ||
       [[response MIMEType] rangeOfString:@"javascript"].location != NSNotFound) {
        // Ist "json" oder "javascript" im Content Type vorhanden, kann auf valides JSON geschlossen werden:
        // application/json, application/x-javascript, text/javascript, text/x-javascript, text/json, text/x-json
        NSLog(@"Valid JSON found. Parsing...");
        [_detectedJSON setHighlighted:YES];
        
        // JSON parsen und als Wörterbuch abspeichern
        NSError *err = nil;
        parsedResponseAsDictionary = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONWritingPrettyPrinted error:&err];
        
        if (!parsedResponseAsDictionary) {
            [parsedText appendString:@"Error in parsing response."];
        } else {
            
            // Parse die einzelnen Einträge und sortiere nach Key und Value:
            
            for(NSString *item in parsedResponseAsDictionary) {
                [parsedText appendString:item];
                [parsedText appendString:@": "];
                
                // ********** Arrays: **********
                NSString *string = [[NSString alloc] initWithFormat:@"%@",[parsedResponseAsDictionary valueForKey:item]];
                if ([string hasPrefix:@"{"]) {
                    
                    // Array process
                    [parsedText appendString:string];
                    
                    // ********** Begin Processing Array ********** ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL
                    
                    //
                    
                    // ********** End Processing Array ********** ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL
                    
                }
                // *******************************
                else {
                    [parsedText appendString:string];
                    NSURL *link = [[NSURL alloc] initWithString:string];
                    if ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"http"]) {
                        [parsedText appendString:@" -> URL\n"];
                        [foundResources addObject:item]; // Oder vielleicht besser wechseln auf "link"? Ausprobieren!
                    }
                    else if ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"/"]) {
                        [parsedText appendString:@" -> Path\n"];
                        [foundResources addObject:item];
                    }
                    else
                        [parsedText appendString:@"\n"];
                }
            }
        }
        parsingSuccess = YES;
    }
    else if([[response MIMEType] rangeOfString:@"xml"].location != NSNotFound) {
        
        NSLog(@"Valid XML found."); // Parsing...?
        [_detectedXML setHighlighted:YES];
        
        // Parse XML
        
        [parsedText appendString:@"XML parsing not yet implemented."];

    }
    else if([[response MIMEType] rangeOfString:@"xhtml"].location != NSNotFound) {
        NSLog(@"Valid XHTML found."); // Parsing...?
        [_detectedXHTML setHighlighted:YES];
    }
    else if([[response MIMEType] rangeOfString:@"html"].location != NSNotFound) {
        NSLog(@"Valid HTML found."); // Parsing...?
        [_detectedHTML setHighlighted:YES];
    }
    
    // ********** End Parsing Response **********
    
    
    // ********** End Filling Header + Body Fields: PARSED **********
    
    if (parsingSuccess) {
        _contentScrollViewText.text = parsedText;
        [_outputSwitch setEnabled:YES forSegmentAtIndex:2];   // Parsed-Tab enablen
        [_outputSwitch setSelectedSegmentIndex:2];   // auf Parsed-Tab wechseln
    }
    
    // ********** End Filling Header + Body Fields: PARSED **********
    
    
    // ********** Begin Console Output: Found Resources **********
    
    NSLog(@"Found Resources: %i",[foundResources count]);
    for (int i = 0; i < [foundResources count]; i++) {
        NSString *key = [[NSString alloc] init];
        key = [foundResources objectAtIndex:i];
        NSString *resource = [[NSString alloc] init];
        resource = [parsedResponseAsDictionary valueForKey:key];
        NSLog(@"Key: \"%@\", Value: \"%@\"",key,resource);
        if (resource == urlString)
            NSLog(@"This resource.");
    }
    
    // ********** Begin Console Output: Found Resources **********
    
    
    // ********** Begin Building TableView ********** ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL
    
    // TableView can be built: enable "Show Resources" button
    resourceTableViewController = [[ResourcesTableViewController alloc] initWithDictionary:parsedResponseAsDictionary];
    [_showResourcesButton setEnabled:YES];
    
    // ********** End Building TableView ********** ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL * ACTUAL

}

- (void)checkStatusCode:(NSInteger)code {
    
    // ********** Begin diligence **********
    
    switch (code) {
        case 100:
            _statusCode.text = [[NSString alloc] initWithFormat:@"100 - Continue"];
            break;
        case 101:
            _statusCode.text = [[NSString alloc] initWithFormat:@"101 - Switching Protocols"];
            break;
        case 200:
            _statusCode.text = [[NSString alloc] initWithFormat:@"200 - OK"];
            break;
        case 201:
            _statusCode.text = [[NSString alloc] initWithFormat:@"201 - Created"];
            break;
        case 202:
            _statusCode.text = [[NSString alloc] initWithFormat:@"202 - Accepted"];
            break;
        case 203:
            _statusCode.text = [[NSString alloc] initWithFormat:@"203 - Non-Authoritative Information"];
            break;
        case 204:
            _statusCode.text = [[NSString alloc] initWithFormat:@"204 - No Content"];
            break;
        case 205:
            _statusCode.text = [[NSString alloc] initWithFormat:@"205 - Reset Content"];
            break;
        case 206:
            _statusCode.text = [[NSString alloc] initWithFormat:@"206 - Partial Content"];
            break;
        case 207:
            _statusCode.text = [[NSString alloc] initWithFormat:@"207 - Multi-Status"];
            break;
        case 300:
            _statusCode.text = [[NSString alloc] initWithFormat:@"300 - Multiple Choices"];
            break;
        case 301:
            _statusCode.text = [[NSString alloc] initWithFormat:@"301 - Moved Permanently"];
            break;
        case 302:
            _statusCode.text = [[NSString alloc] initWithFormat:@"302 - Found"];
            break;
        case 303:
            _statusCode.text = [[NSString alloc] initWithFormat:@"303 - See Other"];
            break;
        case 304:
            _statusCode.text = [[NSString alloc] initWithFormat:@"304 - Not Modified"];
            break;
        case 305:
            _statusCode.text = [[NSString alloc] initWithFormat:@"305 - Use Proxy"];
            break;
        case 307:
            _statusCode.text = [[NSString alloc] initWithFormat:@"307 - Temporary Redirect"];
            break;
        case 400:
            _statusCode.text = [[NSString alloc] initWithFormat:@"400 - Bad Request"];
            break;
        case 401:
            _statusCode.text = [[NSString alloc] initWithFormat:@"401 - Unauthorized"];
            break;
        case 402:
            _statusCode.text = [[NSString alloc] initWithFormat:@"402 - Payment Required"];
            break;
        case 403:
            _statusCode.text = [[NSString alloc] initWithFormat:@"403 - Forbidden"];
            break;
        case 404:
            _statusCode.text = [[NSString alloc] initWithFormat:@"404 - Not Found"];
            break;
        case 405:
            _statusCode.text = [[NSString alloc] initWithFormat:@"405 - Method Not Allowed"];
            break;
        case 406:
            _statusCode.text = [[NSString alloc] initWithFormat:@"406 - Not Acceptable"];
            break;
        case 407:
            _statusCode.text = [[NSString alloc] initWithFormat:@"407 - Proxy Authentication"];
            break;
        case 408:
            _statusCode.text = [[NSString alloc] initWithFormat:@"408 - Request Timeout"];
            break;
        case 409:
            _statusCode.text = [[NSString alloc] initWithFormat:@"409 - Conflict"];
            break;
        case 410:
            _statusCode.text = [[NSString alloc] initWithFormat:@"410 - Gone"];
            break;
        case 411:
            _statusCode.text = [[NSString alloc] initWithFormat:@"411 - Length Required"];
            break;
        case 412:
            _statusCode.text = [[NSString alloc] initWithFormat:@"412 - Precondition Failed"];
            break;
        case 413:
            _statusCode.text = [[NSString alloc] initWithFormat:@"413 - Request Entity Too Large"];
            break;
        case 414:
            _statusCode.text = [[NSString alloc] initWithFormat:@"414 - Request-URI Too Long"];
            break;
        case 415:
            _statusCode.text = [[NSString alloc] initWithFormat:@"415 - Unsupported Media Type"];
            break;
        case 416:
            _statusCode.text = [[NSString alloc] initWithFormat:@"416 - Requested Range Not Satisfiable"];
            break;
        case 417:
            _statusCode.text = [[NSString alloc] initWithFormat:@"417 - Expectation Failed"];
            break;
        case 422:
            _statusCode.text = [[NSString alloc] initWithFormat:@"422 - Unprocessable Entity"];
            break;
        case 423:
            _statusCode.text = [[NSString alloc] initWithFormat:@"423 - Locked"];
            break;
        case 424:
            _statusCode.text = [[NSString alloc] initWithFormat:@"424 - Failed Dependency"];
            break;
        case 500:
            _statusCode.text = [[NSString alloc] initWithFormat:@"500 - Internal Server Error"];
            break;
        case 501:
            _statusCode.text = [[NSString alloc] initWithFormat:@"501 - Not Implemented"];
            break;
        case 502:
            _statusCode.text = [[NSString alloc] initWithFormat:@"502 - Bad Gateway"];
            break;
        case 503:
            _statusCode.text = [[NSString alloc] initWithFormat:@"503 - Service Unavailable"];
            break;
        case 504:
            _statusCode.text = [[NSString alloc] initWithFormat:@"504 - Gateway Timeout"];
            break;
        case 505:
            _statusCode.text = [[NSString alloc] initWithFormat:@"505 - HTTP Version Not Supported"];
            break;
        case 507:
            _statusCode.text = [[NSString alloc] initWithFormat:@"507 - Insufficient Storage"];
            break;
    }
    
        // ********** End diligence **********
    
}

@end

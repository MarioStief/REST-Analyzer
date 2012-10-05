//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
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
    numberOfRows = 0;
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_fontSize setUserInteractionEnabled:NO]; // field that shows font size shouldn't be able to call the keyboard
    [_showResourcesButton setAlpha:0.5]; // appearing inactive
    [_backButton setEnabled:NO]; // appearing inactive
    [_baseUrlButton setEnabled:NO]; // appearing inactive
    [_forwardButton setEnabled:NO]; // appearing inactive
    requestBody = @"{\"key\":\"value\"}";
    _contentScrollViewText.text = requestBody;
    parsedResponseAsDictionary = [[NSDictionary alloc] init];

}

- (void)viewDidUnload {
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
    [self setHeadersTableView:nil];
    [self setKeyTextField:nil];
    [self setValueTextField:nil];
    [self setFontSizeSlider:nil];
    [self setFontSize:nil];
    [self setAuthentication:nil];
    [self setBaseUrlButton:nil];
    [self setBackButton:nil];
    [self setBaseUrlButton:nil];
    [self setForwardButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //set number of rows
    return [httpVerbs count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //set item per row
    return [httpVerbs objectAtIndex:row];
}

// ********** End Setup Picker View **********


// ********** Begin Setup Table View **********

- (NSInteger)tableView:(UITableView *)headersTableView numberOfRowsInSection:(NSInteger)section {
    return numberOfRows; //[foundResources count];
}

// ********** Begin set up cell **********
- (UITableViewCell *)tableView:(UITableView *)headersTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"resourceCell";
    
    UITableViewCell *resourceTableViewCell = [headersTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (resourceTableViewCell == nil) {
        resourceTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Colorate the HTTP Headers
    // entered header is a valid request header: color green text.
    NSArray *generalHeaders = [[NSArray alloc]initWithObjects:@"Cache-Control",@"Connection",@"Content-Encoding",@"Content-Language",@"Content-Length",@"Content-Location",@"Content-MD5",@"Content-Range",@"Content-Type",@"Pragma",@"Trailer",@"Via",@"Warning",@"Transfer-Encoding",@"Upgrade",nil];
    NSArray *requestHeaders = [[NSArray alloc]initWithObjects:@"Accept",@"Accept-Charset",@"Accept-Encoding",@"Accept-Language",@"Accept-Ranges",@"Authorization",@"Depth",@"Destination",@"Expect",@"From",@"Host",@"If",@"If-Match",@"If-Modified-Since",@"If-None-Match",@"If-Range",@"If-Unmodified-Since",@"Lock-Token",@"Max-Forwards",@"Overwrite",@"Proxy-Authorization",@"Range",@"Referer",@"TE",@"Timeout",@"User-Agent",nil];
    if ([generalHeaders containsObject:_keyTextField.text])
        resourceTableViewCell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    else if ([requestHeaders containsObject:_keyTextField.text])
        resourceTableViewCell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1];
        // if key exists AND value the same: also green text
        /*
        NSString *keyTextFieldString = [[NSString alloc] initWithFormat:@"%@",[parsedResponseAsDictionary objectForKey:_keyTextField.text]];
        if ([keyTextFieldString isEqualToString:_valueTextField.text])
            resourceTableViewCell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
         */
    // if not: red text then.
    else
        resourceTableViewCell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];

    // Assign the text to the cell and return the cell.
    resourceTableViewCell.textLabel.text = _keyTextField.text;
    resourceTableViewCell.detailTextLabel.text = _valueTextField.text;
    return resourceTableViewCell;
}
// ********** End set up cell **********


/*
// ********** let the TableView selection disappear when clicked outside **********
// (important to be able to insert a key-value at the end)
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.headersTableView deselectRowAtIndexPath:[self.headersTableView indexPathForSelectedRow] animated:YES];
}
 */


// ********** "+" button pressed: **********
- (IBAction)addKeyValue:(id)sender {
    // Option 1: no cell selected, new cell should be inserted at the end.
    if (![_headersTableView indexPathForSelectedRow]) {
        [_headersTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:numberOfRows++ inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
    }
    // Option 2: there is a cell selected, new cell should be inserted before that cell, selection should be removed afterwards.
    else {
        NSIndexPath *path = [_headersTableView indexPathForSelectedRow];
        numberOfRows++;
        [_headersTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path]
                                     withRowAnimation:UITableViewRowAnimationFade];
        [_headersTableView deselectRowAtIndexPath:[_headersTableView indexPathForSelectedRow] animated:YES];
    }
}

// ********** Swype cell for delete option **********
-(void)tableView:(UITableView*)headersTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

// ********** Process swype deletion **********
- (void)tableView:(UITableView *)headersTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)path {
    if (editingStyle == UITableViewCellEditingStyleDelete)     {
        numberOfRows--;
        [_headersTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// ********** End Setup Table View **********


// ********** Begin change selected segment index (and refresh text) **********

// outsourced method because it's code is used in "outputToggle" and in "fontSizeSliderMove":
- (void)switchSegmentIndex {
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


// ********** End change selected segment index (and refresh text) **********


// ********** Start using the Request/Response/Parsed output toggle: **********

- (IBAction)outputToggle:(id)sender {
    [self switchSegmentIndex]; // used for the toggle
}

- (IBAction)loggingOutput:(id)sender {
    [self.navigationController pushViewController:self animated:YES];
}

// ********** End using the Request/Response/Parsed output toggle: **********


// ********** Begin use font slider to change text field size **********

- (IBAction)fontSizeSliderMove:(id)sender {
    _headerScrollViewText.font = [UIFont systemFontOfSize:_fontSizeSlider.value];
    _contentScrollViewText.font = [UIFont systemFontOfSize:_fontSizeSlider.value];
    _fontSize.text = [[NSString alloc] initWithFormat:@"%i",(int)_fontSizeSlider.value];
    [self switchSegmentIndex]; // used for the text refresh
}

// ********** End use font slider to change text field size **********



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

// ********** GO button pressed: **********
- (IBAction)go:(id)sender {
//    NSLog(@"ViewController.go: %@: %@", resourceTableViewController, [resourceTableViewController resourcesAsDictionary]);
    
    // ********** Remove Keyboard **********
    [self.url resignFirstResponder];
    
    // ********** Reading URL **********
    urlString = _url.text;
    
    // ********** New Request started: Do a full reset to avoid side effects **********
    [_detectedJSON setHighlighted:NO];
    [_detectedXML setHighlighted:NO];
    [_detectedHTML setHighlighted:NO];
    [_detectedXHTML setHighlighted:NO];
    _contentType.text = [[NSString alloc] init];
    _encoding.text = [[NSString alloc] init];
    [_outputSwitch setSelectedSegmentIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2];
    baseUrl = [[NSString alloc] init];
    resourcePath = [[NSString alloc] init];
    requestBody = _contentScrollViewText.text; // saving writen text field in String
    _contentScrollViewText.text = [[NSString alloc] init];
    _headerScrollViewText.text = [[NSString alloc] init];
    responseBody = [[NSString alloc] init];
    parsedText = [[NSMutableString alloc] init];
    foundResources = [[NSMutableArray alloc] init];
    [_showResourcesButton setAlpha:0.5];
    [_showResourcesButton setEnabled:NO];
    _authentication.textColor = [UIColor blackColor];
    _statusCode.text = [[NSString alloc] init];
    _statusCode.backgroundColor = [UIColor whiteColor];
    
    // ********** First initializations:  **********
    // Index of the selected HTTP method in the picker view:
    methodId = [_requestMethod selectedRowInComponent:0];
    // HTTP method as String:
    NSString *calledMethodString = [[NSString alloc] initWithFormat:@"%@",[httpVerbs objectAtIndex:methodId]];
    // Start request
    [self startRequest:calledMethodString];
}

// receiving a authentication challenge:
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    // NSURLCredential supports HTTP Basic Authentication and HTTP Digest Authentication with username and password.
    // Client Certificate Authentication and Server Trust Authentication not implemented. Maybe later.
    
    // ********** Begin Authentication **********
    
    // setting the authentication text field
    _authentication.text = [challenge description];
    NSLog(@"%@ challenge received.",_authentication.text);
    
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_username.text
                                                                 password:_password.text
                                                              persistence:NSURLCredentialPersistenceNone];
        // Implement Client Certificate Authentication:
        // NSURLCredential *credential = [NSURLCredential credentialWithIdentity:(SecIdentityRef) certificates:(NSArray *) persistence:(NSURLCredentialPersistence)];
        // Implement Server Trust Authentication:
        // NSURLCredential *credential = [NSURLCredential credentialForTrust:(SecTrustRef)];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        _authentication.textColor = [[UIColor alloc] initWithRed:0.75 green:0 blue:0 alpha:1];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message: @"Authentication incorrect."
                                                            delegate:self
                                                   cancelButtonTitle:@"Close"
                                                   otherButtonTitles:nil];
        [alert show];
        _authentication.textColor = [[UIColor alloc] initWithRed:0 green:0.75 blue:0 alpha:1];
    }
    
    // ********** End Authentication **********

}


// ********** Begin set up navigation buttons **********

- (IBAction)backButton:(id)sender {
    if ([_backButton isEnabled]) {
        historyElement = [historyElement previous];
        _url.text = [[NSString alloc] initWithFormat:@"%@%@",[historyElement baseUrl],[historyElement resource]];
        [_forwardButton setEnabled:YES];
        if ([historyElement previous] == nil)
            [_backButton setEnabled:NO];
    }
}

- (IBAction)baseUrlButton:(id)sender {
    _url.text = baseUrl;
}

- (IBAction)forwardButton:(id)sender {
    if ([_forwardButton isEnabled]) {
        historyElement = [historyElement next];
        _url.text = [[NSString alloc] initWithFormat:@"%@%@",[historyElement baseUrl],[historyElement resource]];
        [_backButton setEnabled:YES];
        if ([historyElement next] == nil)
            [_forwardButton setEnabled:NO];
    }
}

// ********** End set up navigation buttons **********


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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setMainDocumentURL:[[NSURL alloc]initWithString:baseUrl]]; // This URL will be used for the “only from same domain as main document” cookie accept policy.
    [request setHTTPMethod:requestMethodString];
    
    // ********** Begin Changing HTTP Headers **********
    
    for (int i = 0; i < numberOfRows; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [_headersTableView cellForRowAtIndexPath:path];
        NSLog(@"adding header: %@:%@",cell.textLabel.text,cell.detailTextLabel.text);
        [request setValue:cell.detailTextLabel.text forHTTPHeaderField:cell.textLabel.text];
    }

    // ********** End Changing HTTP Headers **********

    
    // working with different methods

    switch (methodId) {
            // GET:
            // On Collection URI: List the URIs and perhaps other details of the collection's members.
            // On Element URI: Retrieve a representation of the addressed member of the collection, expressed in an appropriate Internet media type.
            // DELETE:
            // On Collection URI: Delete the entire collection.
            // On Element URI: Delete the addressed member of the collection.
            // HEAD:
            // On Collection URI: Retrieve Header.
            // On Element URI: Retrieve Header.
            
        case 1: // POST
            // On Collection URI: Replace the entire collection with another collection.
            // On Element URI: Replace the addressed member of the collection, or if it doesn't exist, create it.
        case 2: // PUT
            // On Collection URI: Create a new entry in the collection. The new entry's URL is assigned automatically and is usually returned by the operation.
            // On Element URI: Treat the addressed member as a collection in its own right and create a new entry in it.
            
            // Case POST and PUT: Add Body.
            [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"using body: %@",[request HTTPBody]);
            
    }
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"sending request: %@ %@%@ (%@)",requestMethodString,baseUrl,resourcePath,connection);

    // ********** End Request ********** INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE * INCOMPLETE
    
    
    // ********** Begin Filling Header + Body Fields: REQUEST **********
    
    requestHeader = [[NSString alloc] initWithFormat:@"%@",[[request allHTTPHeaderFields] description]];
//    requestBody = [[NSString alloc] initWithFormat:@"%@",[request HTTPBody]];
    _headerScrollViewText.text = requestHeader;
//    _contentScrollViewText.text = requestBody;
    [_outputSwitch setEnabled:YES forSegmentAtIndex:0]; // Request-Tab einschalten
    
    // ********** End Filling Header + Body Fields: REQUEST **********

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *errorLocalizedDescription = [[NSString alloc] initWithFormat:@"%@",[error localizedDescription]];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorLocalizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    NSLog(@"%@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response {

    // ********** Begin Receiving Response Header **********
    
    response = _response;
    _contentType.text = [response MIMEType]; // Content Type-Feld setzen
    _encoding.text = [response textEncodingName]; // Encodingfeld setzen
    [self checkStatusCode:[response statusCode]]; // Statuscode aktualisieren
    if ([response statusCode] < 400) // color status code field
        _statusCode.backgroundColor = [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:0.1];
    else
        _statusCode.backgroundColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.1];

    NSLog(@"receiving response: %@, type: %@, charset: %@, status code: %i",[response description],[response MIMEType],[response textEncodingName],[response statusCode]);
    
//	if ([response respondsToSelector:@selector(allHeaderFields)]) {
        // header is fine, filling header field
		responseHeader = [[response allHeaderFields] description];
        _headerScrollViewText.text = responseHeader;
        [_outputSwitch setSelectedSegmentIndex:1]; // zum Response-Tab wechseln
        [_outputSwitch setEnabled:YES forSegmentAtIndex:1]; // Request-Tab einschalten
//    }

    // Bei erkannten Formaten: zugehöriger Highlighter aktivieren, dann entsprechend parsen
    if([[response MIMEType] rangeOfString:@"json"].location != NSNotFound ||
       [[response MIMEType] rangeOfString:@"javascript"].location != NSNotFound) {
        NSLog(@"Valid JSON found."); // Parsing...?
        // Ist "json" oder "javascript" im Content Type vorhanden, kann auf valides JSON geschlossen werden:
        // application/json, application/x-javascript, text/javascript, text/x-javascript, text/json, text/x-json
        [_detectedJSON setHighlighted:YES];
    }
    else if([[response MIMEType] rangeOfString:@"xml"].location != NSNotFound) {
        NSLog(@"Valid XML found."); // Parsing...?
        [_detectedXML setHighlighted:YES];
    }
    else if([[response MIMEType] rangeOfString:@"xhtml"].location != NSNotFound) {
        NSLog(@"Valid XHTML found."); // Parsing...?
        [_detectedXHTML setHighlighted:YES];
    }
    else if([[response MIMEType] rangeOfString:@"html"].location != NSNotFound) {
        NSLog(@"Valid HTML found."); // Parsing...?
        [_detectedHTML setHighlighted:YES];
    }
    
    // ********** End Receiving Response Header **********
    
    
    // ********** Begin actualize history **********
    if ([response statusCode] < 400) {
        // if the slash had been cut off: still the same url
        BOOL urlIsTheSame = ([_url.text isEqualToString:[[NSString alloc] initWithFormat:@"%@%@",[historyElement baseUrl],[historyElement resource]]] ||
                             [_url.text isEqualToString:[[NSString alloc] initWithFormat:@"%@%@/",[historyElement baseUrl],[historyElement resource]]]);
        if (!historyElement) {
            // new history: initialize
            historyElement = [[HistoryElement alloc] init];
        } else if (!urlIsTheSame) {
            // history exists, and entry is new: initialize new element and connect each other
            HistoryElement *oldElement = historyElement;
            historyElement = [[HistoryElement alloc] init];
            [historyElement setPrevious:oldElement];
            [_backButton setEnabled:YES];
            [historyElement setNext:nil];
            [_forwardButton setEnabled:NO];
            [oldElement setNext:historyElement];
        }
        if (!urlIsTheSame) {
            // if URL is different: set new ones.
            [historyElement setBaseUrl:baseUrl];
            [_baseUrlButton setEnabled:YES];
            [historyElement setResource:resourcePath];
        }
    }
    
    // ********** End actualize history **********
}


-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData {
    
    // ********** Begin Receiving Response Body **********
    
    NSLog(@"processing package: %@",[response description]);

    bodyData = _bodyData;
    responseBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];

    // ********** End Receiving Response Body **********
    
    
    // ********** Filling Body Field: RESPONSE **********
    _contentScrollViewText.text = responseBody;


    // ********** Begin Parsing Response **********

    BOOL parsingSuccess = NO;
    
    if([_detectedJSON isHighlighted]) {
        NSLog(@"Parsing JSON...");
        
        // JSON parsen und als Wörterbuch abspeichern
        NSError *err = nil;
        parsedResponseAsDictionary = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONWritingPrettyPrinted error:&err];
        if ([parsedResponseAsDictionary count] > 0) {
            parsingSuccess = YES;
        }
    }
    else if([_detectedXML isHighlighted]) {
        // Parse XML
        // [parsedText appendString:@"XML parsing not yet implemented."];
        NSLog(@"Parsing XML...");
        
        // XML parsen und als Wörterbuch abspeichern
        NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:bodyData];
        XMLParser *xmlParser = [[XMLParser alloc] initXMLParser];
        [nsXmlParser setDelegate:xmlParser];
        parsingSuccess = [nsXmlParser parse];
        
        if (parsingSuccess) {
            NSLog(@"XML parsing success. Elements count: %i", [[xmlParser parsedElementsAsDictionary] count]);
            parsedResponseAsDictionary = [[NSDictionary alloc] initWithDictionary:[xmlParser parsedElementsAsDictionary]];
        } else {
            NSLog(@"Sorry, the XML parser returned an error.");
        }
    }
    else if([_detectedHTML isHighlighted]) {
        // Parse HTML
        // [parsedText appendString:@"HTML parsing not yet implemented."];
    }
    else if([_detectedXHTML isHighlighted]) {
        // Parse XML
        // [parsedText appendString:@"XHTML parsing not yet implemented."];
    }
    
    // ********** End Parsing Response **********
    
    
    // ********** Begin Filling Header + Body Fields: PARSED **********
    
    if (parsingSuccess) {
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
                        [parsedText appendString:@"\n"];
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
    
    
    // ********** Begin Building TableView **********
    
    if ([foundResources count] > 0) {
        // TableView can now be built: enable "Resources" button
        [_showResourcesButton setAlpha:1];
        [_showResourcesButton setEnabled:YES];
        // when the button "Resources" is pressed, the overwritten method prepareForSegue:sender is called
    }
    
    // ********** End Building TableView **********

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"resourcesTableViewPopover"])
    {
        // Get reference to the destination view controller
        ResourcesTableViewController *resourceTableViewController = [segue destinationViewController];
        
        // Passing the found resources to the storyboard instance
        NSDictionary *foundResourcesAsDic = [parsedResponseAsDictionary dictionaryWithValuesForKeys:foundResources];
        [resourceTableViewController setResourcesAsDictionary:foundResourcesAsDic];
        
        // pass the Table View Controller the reference to the url text field so that it can pass the returning url
        [resourceTableViewController setReferenceToUrl:_url];
        // now pass reference to the popover controller for being able to dismiss it programmatically again
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        [resourceTableViewController setReferenceToPopoverController:[popoverSegue popoverController]];
        // passing the baseURL to the table view in case there is only a resource (not a full)) url that should be loaded
        // and the foll url needs to be built
        [resourceTableViewController setReferenceToBaseUrl:baseUrl];
    }
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

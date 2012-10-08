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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:logPath]) {
        NSLog (@"Existing log file found at %@ - logging enabled.", logPath);
        freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
        [_logToFileSwitch setOn:YES];
        [_logFileButton setEnabled:YES];
        [_verboseLogLabel setEnabled:YES];
        [_verboseLogSwitch setEnabled:YES];
    }
    else
        // all disabled by default, do nothing here
        NSLog (@"No existing log file found, logging disabled.");

    // ********** End redirect logging output to file **********

	// Do any additional setup after loading the view, typically from a nib.
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
    parsedText = [[NSMutableString alloc] init];
    foundResourceKeys = [[NSMutableArray alloc] init];
    foundResourceValues = [[NSMutableArray alloc] init];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0]; // Muss einzeln durchgeführt werden,
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1]; // da sonst das Feld permanent
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2]; // ausgeschaltet ist.
    [_showResourcesButton setEnabled:NO];
    numberOfRows = 0;
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_fontSize setUserInteractionEnabled:NO]; // field that shows font size shouldn't be able to call the keyboard
    [_showResourcesButton setAlpha:0.5]; // more obvious that this is inactive yet
    [_backButton setEnabled:NO]; // appearing inactive
    [_forwardButton setEnabled:NO]; // appearing inactive
    requestBody = @"{\"key\":\"value\"}";
    _contentScrollViewText.text = requestBody;
    generalHeaders = [[NSArray alloc]initWithObjects:@"Cache-Control",@"Connection",@"Content-Encoding",@"Content-Language",@"Content-Length",@"Content-Location",@"Content-MD5",@"Content-Range",@"Content-Type",@"Pragma",@"Trailer",@"Via",@"Warning",@"Transfer-Encoding",@"Upgrade",nil];
    requestHeaders = [[NSArray alloc]initWithObjects:@"Accept",@"Accept-Charset",@"Accept-Encoding",@"Accept-Language",@"Accept-Ranges",@"Authorization",@"Depth",@"Destination",@"Expect",@"From",@"Host",@"If",@"If-Match",@"If-Modified-Since",@"If-None-Match",@"If-Range",@"If-Unmodified-Since",@"Lock-Token",@"Max-Forwards",@"Overwrite",@"Proxy-Authorization",@"Range",@"Referer",@"TE",@"Timeout",@"User-Agent",nil];
    // [_loadProgressBar setHidden:YES]; // storyboard
    // [_loadIndicatorView setHidesWhenStopped:YES]; // storyboard
    //[_loadIndicatorView stopAnimating];
    
    // Todo: finding data
    //    _url.text = @"http://jabber.ccc.de:5222/";
    // Debug: JSON
//    _url.text = @"https://graph.facebook.com/19292868552";
    
}

- (void)viewDidUnload {
    [self setRequestMethod:nil];
    [self setScrollView:nil];
    [self setDetectedJSON:nil];
    [self setDetectedXML:nil];
    [self setOutputSwitch:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setAuthentication:nil];
    [self setStatusCode:nil];
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
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setLoadProgressBar:nil];
    [self setLoadIndicatorView:nil];
    [self setAddMethodTextField:nil];
    [self setLogToFileSwitch:nil];
    [self setVerboseLogSwitch:nil];
    [self setLogFileButton:nil];
    [self setVerboseLogLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO; // Not yet implemented -> not that important.
}

// ********** Remove the onscreen keyboard after pressing "Go" button: **********
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.url)
        [self go:nil];
    else if (textField == self.username)
        [self.password becomeFirstResponder];
    else if (textField == self.keyTextField)
        [self.valueTextField becomeFirstResponder];
    else if (textField == self.valueTextField)
        [self addKeyValue:nil];
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


// ********** Begin header key info button **********

- (IBAction)headerInfo:(id)sender {
    NSString *string = [[NSMutableString alloc] initWithFormat:@"General Headers: %@\nRequest Headers: %@",generalHeaders,requestHeaders];
    //NSMutableString *requestHeaders = [[NSMutableString alloc] initWithString:@"Request Headers: "];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Header Keys"
                                                        message:string
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)clearUrlField:(id)sender {
    _url.text = @"";
    [self.url becomeFirstResponder];
}

// ********** Begin header key info button **********


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
    UIAlertView *alert;
    NSString *errorMessage;
    if ([_keyTextField.text isEqualToString:@""] || [_valueTextField.text isEqualToString:@""]) {
        // don't add empty stuff
        errorMessage = [[NSString alloc] initWithFormat:@"Please specify header and value."];
    }
    for (int i = 0; i < numberOfRows; i++) {
        // check table for duplicates
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [_headersTableView cellForRowAtIndexPath:path];
        NSLog(@"_valueTextField.text: %@",_valueTextField.text);
        if ([_keyTextField.text isEqualToString:cell.textLabel.text]) {
            // key exists
            errorMessage = [[NSString alloc] initWithFormat:@"Key \"%@\" already specified with value \"%@\".\n"
                                      "Delete old one first.",cell.textLabel.text,cell.detailTextLabel.text];
        }
    }
    
    if (errorMessage) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:errorMessage
                                          delegate:self
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles:nil];
        [alert show];
        return;
    }

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


// ********** Begin set up navigation buttons **********

- (IBAction)backButton:(id)sender {
    if ([_backButton isEnabled]) {
        historyElement = [historyElement previous];
        _url.text = [[NSString alloc] initWithFormat:@"%@",[historyElement url]];
        [_forwardButton setEnabled:YES];
        if ([historyElement previous] == nil)
            [_backButton setEnabled:NO];
    }
}

- (IBAction)baseUrlButton:(id)sender {
    _url.text = [self urlPart:_url.text definePart:@"prevPath"];
}

- (IBAction)forwardButton:(id)sender {
    if ([_forwardButton isEnabled]) {
        historyElement = [historyElement next];
        _url.text = [[NSString alloc] initWithFormat:@"%@",[historyElement url]];
        [_backButton setEnabled:YES];
        if ([historyElement next] == nil)
            [_forwardButton setEnabled:NO];
    }
}

// ********** End set up navigation buttons **********


// ********** GO button pressed: **********
- (IBAction)go:(id)sender {
    
    // ********** Remove Keyboard **********
    [self.url resignFirstResponder];
    
    // ********** New Request started: Do a full reset to avoid side effects **********
    [_detectedJSON setHighlighted:NO];
    [_detectedXML setHighlighted:NO];
    _contentType.text = [[NSString alloc] init];
    _encoding.text = [[NSString alloc] init];
    [_outputSwitch setSelectedSegmentIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2];
    _headerScrollViewText.text = [[NSString alloc] init];
    responseBody = [[NSString alloc] init];
    parsedText = [[NSMutableString alloc] init];
    foundResourceKeys = [[NSMutableArray alloc] init];
    foundResourceValues = [[NSMutableArray alloc] init];
    [_showResourcesButton setAlpha:0.5];
    [_showResourcesButton setEnabled:NO];
    _authentication.textColor = [UIColor blackColor];
    _authentication.text = @"No challenge received.";
    _statusCode.text = [[NSString alloc] init];
    _statusCode.backgroundColor = [UIColor whiteColor];
    responseBodyData = [[NSMutableData alloc] init];

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
    NSLog(@"%@ authentication challenge received.",_authentication.text);
    
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


// ********** Begin URL Processing **********

- (NSString*)urlPart:(NSString*)urlString definePart:(NSString*)part {
    
    
    // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])
        urlString = ([[NSString alloc] initWithFormat:@"http://%@", urlString]);
    
    // URL endet mit "/" -> weg damit.
    if ([urlString hasSuffix:@"/"])
        urlString = [urlString substringToIndex:[urlString length]-1];
    
    // Trennung in BaseURL und ResourceURL
    NSArray *urlComponents = [[NSArray alloc] initWithArray:[urlString pathComponents]];
    NSString *baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    
    if ([part isEqualToString:@"baseUrl"]) {
        // only base url is requested; job done.
        return [[NSString alloc] initWithFormat:@"%@/",baseUrl];
    }
    
    if ([urlComponents count] > 2) {
        //
        NSMutableString *resourcePath = [[NSMutableString alloc] init];
        int i = 2; // while instead of for: i will be needed outside this loop.
        while (i < [urlComponents count]-1) {
            [resourcePath appendFormat:@"/%@",[urlComponents objectAtIndex:i]];
            i++;
        }
        if ([part isEqualToString:@"prevPath"]) {
            // previous Path requested. This is it.
            if ([resourcePath isEqualToString:[[NSString alloc] init]])
                // resource ath is empty, prevPath is base url. return with / at the end
                return [[NSString alloc] initWithFormat:@"%@/",baseUrl];
            else
                // longer then base url
                return [[NSString alloc] initWithFormat:@"%@%@",baseUrl,resourcePath];
        }
        // else: full Path requested. Add last url component.
        [resourcePath appendFormat:@"/%@",[urlComponents objectAtIndex:i]];
    }
    return [[NSString alloc] initWithFormat:@"%@",urlString];
}

- (IBAction)addMethodButton:(id)sender {
    NSMutableArray *newHttpVerbs = [[NSMutableArray alloc] initWithArray:httpVerbs];
    [newHttpVerbs replaceObjectAtIndex:[httpVerbs count]-1 withObject:_addMethodTextField.text];
    httpVerbs = [[NSArray alloc] initWithArray:newHttpVerbs];

}

// ********** End URL Processing **********


// ********** Begin log to file **********

- (IBAction)logToFileSwitch:(id)sender {
     // Logging to file switch enabled?
     
     if ([_logToFileSwitch isOn]) {
         freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
         [_logFileButton setEnabled:YES];
         [_verboseLogLabel setEnabled:YES];
         [_verboseLogSwitch setEnabled:YES];
         if ([_verboseLogSwitch isOn]) NSLog (@"Enable logging to %@.", logPath);
     } else {
         NSFileManager *filemgr;
         filemgr = [NSFileManager defaultManager];
         [filemgr removeItemAtPath:logPath error:nil];
         [_verboseLogLabel setEnabled:NO];
         [_verboseLogSwitch setEnabled:NO];
         [_logFileButton setEnabled:NO];
         if ([_verboseLogSwitch isOn]) NSLog(@"Logging disabled. File deleted.");
     }
}

- (IBAction)Impressum:(id)sender {
    NSString *string = [[NSMutableString alloc] initWithFormat:@"Copyright © 2012 Mario Stief\n"
                        "\n"
                        "Generic Client for\n"
                        "RESTful Web Services\n"
                        "\n"
                        "• Testing HTTP Method results\n"
                        "• Parsing XML and JSON\n"
                        "• Analyzing results\n"
                        "\n"
                        "Using free icons from:\n"
                        "• www.vistaico.com\n"
                        "• www.icons-land.com"];
    //NSMutableString *requestHeaders = [[NSMutableString alloc] initWithString:@"Request Headers: "];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Impressum"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

// ********** End log to file **********


- (void)startRequest:(NSString*)requestMethodString {
        
    // ********** Begin Request **********

    NSLog(@"********** New Request **********");
    
    // -> Implement POST, PUT, DELETE, HEAD
    
    NSString *urlString = [[NSString alloc] initWithString:[self urlPart:_url.text definePart:@"fullPath"]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setMainDocumentURL:[[NSURL alloc]initWithString:[self urlPart:_url.text definePart:@"baseUrl"]]]; // This URL will be used for the “only from same domain as main document” cookie accept policy.
    [request setHTTPMethod:requestMethodString];
    
    // ********** Begin Changing HTTP Headers **********
    
    for (int i = 0; i < numberOfRows; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [_headersTableView cellForRowAtIndexPath:path];
        NSLog(@"Adding header: \"%@\":\"%@\"",cell.textLabel.text,cell.detailTextLabel.text);
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

            // Case POST and PUT:
            // saving writen text field in String
            requestBody = _contentScrollViewText.text;
            // Add Body.
            [request setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
            //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];

            // attaching the bodystring encoded as data
            [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
            
    }
    // and empty the contentScrollViewText;
    _contentScrollViewText.text = [[NSString alloc] init];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"Sending request: %@ %@ (%@)",requestMethodString,urlString,connection);

    // ********** End Request **********
    
    
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
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorLocalizedDescription
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
    [alertView show];
    NSLog(@"The following error occured: %@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response {

    // ********** Begin Receiving Response Header **********
    
    response = _response;
    if (![response MIMEType])
        _contentType.text = @"unknown";
    else
        _contentType.text = [response MIMEType]; // Content Type-Feld setzen
    if (![response textEncodingName])
        _encoding.text = @"unknown";
    else
        _encoding.text = [response textEncodingName]; // Content Type-Feld setzen
    responseLength = [response expectedContentLength];
    [self checkStatusCode:[response statusCode]]; // Statuscode aktualisieren
    if ([response statusCode] < 400) // color status code field
        _statusCode.backgroundColor = [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:0.1];
    else
        _statusCode.backgroundColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.1];

    NSLog(@"Receiving response: %@, type: %@, charset: %@, status code: %i",[response description],[response MIMEType],[response textEncodingName],[response statusCode]);
    if ([_verboseLogSwitch isOn]) NSLog(@"Response header: %@",[[response allHeaderFields] description]);

//	if ([response respondsToSelector:@selector(allHeaderFields)]) {
        // header is fine, filling header field
		responseHeader = [[response allHeaderFields] description];
        _headerScrollViewText.text = responseHeader;
        [_outputSwitch setSelectedSegmentIndex:1]; // zum Response-Tab wechseln
        [_outputSwitch setEnabled:YES forSegmentAtIndex:1]; // Request-Tab einschalten
//    }

    // ********** End Receiving Response Header **********
    
    
    // ********** Begin actualize history **********
    if ([response statusCode] < 400) {
        // if the slash had been cut off: still the same url
        BOOL urlIsTheSame = ([_url.text isEqualToString:[[NSString alloc] initWithFormat:@"%@",[historyElement url]]] ||
                             [_url.text isEqualToString:[[NSString alloc] initWithFormat:@"%@/",[historyElement url]]]);
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
            [historyElement setUrl:[self urlPart:_url.text definePart:@"fullPath"]];
        }
    }
    
    // ********** End actualize history **********
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData {
    
    // ********** Begin Receiving Response Body **********
    
    BOOL responseComplete = NO;
    [responseBodyData appendData:_bodyData];
    if (responseLength > -1 ) {
        [_loadProgressBar setHidden:NO];
        float progress = 1.00*[responseBodyData length]/responseLength;
        [_loadProgressBar setProgress:progress animated:NO];
        NSLog(@"%i/%i bytes received.",[responseBodyData length],responseLength);
        if ([responseBodyData length] >= responseLength)
            responseComplete = YES;
    } else {
/*
        if (!awaitingResponse)
            NSLog(@"No content length is specified. Starting timer. If there is no answer for 3 seconds the transmission is assumed to be completed.");
 */
        [_loadIndicatorView startAnimating];
        NSLog(@"%i bytes received.",[responseBodyData length]+[_bodyData length]);
/*
        [awaitingResponse invalidate];
        awaitingResponse = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(responseComplete:) userInfo:nil repeats:NO];
 */
    }


}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Connection succeeded in downloading the request.
    NSLog(@"Loading complete.");
    [_loadProgressBar setHidden:YES];
    [_loadIndicatorView stopAnimating];
    
    // ********** Filling Body Field: RESPONSE **********
    responseBody = [[NSString alloc] initWithData:responseBodyData encoding:NSASCIIStringEncoding];
    _contentScrollViewText.text = responseBody;
    
    // response received -> parsing now if possible.
    [self parseResponse];
}

// ********** End Receiving Response Body **********

- (void)parseResponse {

    responseBody = [[NSString alloc] initWithData:responseBodyData encoding:NSASCIIStringEncoding];
    keyArray = [[NSArray alloc] init];
    valueArray = [[NSArray alloc] init];
    
    // ********** Begin Parsing Response **********

    BOOL parsingSuccess = NO;
    NSDictionary *parsedResponseAsDictionary = [[NSDictionary alloc] init];

    
    
    // Bei erkannten Formaten: zugehöriger Highlighter aktivieren, dann entsprechend parsen
    if([[response MIMEType] rangeOfString:@"json"].location != NSNotFound ||
       [[response MIMEType] rangeOfString:@"javascript"].location != NSNotFound) {
        // Ist "json" oder "javascript" im Content Type vorhanden, kann auf valides JSON geschlossen werden:
        // application/json, application/x-javascript, text/javascript, text/x-javascript, text/json, text/x-json
        if ([_verboseLogSwitch isOn]) NSLog(@"Parsing JSON...");
        
        // JSON parsen und als Wörterbuch abspeichern
        NSError *err = nil;
        parsedResponseAsDictionary = [NSJSONSerialization JSONObjectWithData:responseBodyData options:NSJSONWritingPrettyPrinted error:&err];
        if ([parsedResponseAsDictionary count] > 0) {
            keyArray = [[NSArray alloc] initWithArray:[parsedResponseAsDictionary allKeys]];
            valueArray = [[NSArray alloc] initWithArray:[parsedResponseAsDictionary allValues]];
            NSLog(@"Parsing JSON successful. %i elements found.", [keyArray count]);
            parsingSuccess = YES;
        } else {
            NSLog(@"Error in parsing JSON.");
        }
    } else if([[response MIMEType] rangeOfString:@"xml"].location != NSNotFound) {
        // Parse XML
        // [parsedText appendString:@"XML parsing not yet implemented."];
        if ([_verboseLogSwitch isOn]) NSLog(@"Parsing XML...");
        
        // parse XML and save as dictionary
        NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:responseBodyData];
        XMLParser *xmlParser = [[XMLParser alloc] initXMLParser];
        [nsXmlParser setDelegate:xmlParser];
        if ([_verboseLogSwitch isOn]) [xmlParser setVerbose:YES];
        parsingSuccess = [nsXmlParser parse];
        
        if (parsingSuccess) {
            keyArray = [[NSArray alloc] initWithArray:[xmlParser keyArray]];
            valueArray = [[NSArray alloc] initWithArray:[xmlParser valueArray]];
            NSLog(@"Parsing XML successful. %i elements found.", [keyArray count]);
        } else {
            NSLog(@"Error in parsing XML.");
        }
    }
    
    // ********** End Parsing Response **********
    
    
    // ********** Begin Filling Header + Body Fields: PARSED **********
    
    if (parsingSuccess) {
        
        // process key and values:
        
        for(int i = 0; i < [keyArray count]; i++) {
            NSString *key = [[NSString alloc] initWithString:[keyArray objectAtIndex:i]];
            NSString *value = [[NSString alloc] initWithFormat:@"%@",[valueArray objectAtIndex:i]];
            [parsedText appendString:key];
            [parsedText appendString:@": "];
            
            // ********** Arrays: **********
            NSString *string = [[NSString alloc] initWithFormat:@"%@",value];
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
                BOOL isValidResource = ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"http"] ||
                                        [[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"/"]);
                if (isValidResource) {
                    for (int j = i+1; j < [keyArray count]; j++) {
                        if ([[keyArray objectAtIndex:i] isEqualToString:[keyArray objectAtIndex:j]])
                            key = [[NSString alloc] initWithFormat:@"%@ (%@)", [keyArray objectAtIndex:j], [valueArray objectAtIndex:j]];
                    }
                    [foundResourceKeys addObject:key]; // Oder vielleicht besser wechseln auf "link"? Ausprobieren!
                    [foundResourceValues addObject:string];
                }
            }
            [parsedText appendString:@"\n"];
        }
        
        if([[response MIMEType] rangeOfString:@"json"].location != NSNotFound ||
           [[response MIMEType] rangeOfString:@"javascript"].location != NSNotFound)
            [_detectedJSON setHighlighted:YES];
        else if([[response MIMEType] rangeOfString:@"xml"].location != NSNotFound)
            [_detectedXML setHighlighted:YES];
        
    }
    if ([foundResourceKeys count] > 0) {
        
        _contentScrollViewText.text = parsedText;
        [_outputSwitch setEnabled:YES forSegmentAtIndex:2];   // Parsed-Tab enablen
        [_outputSwitch setSelectedSegmentIndex:2];   // auf Parsed-Tab wechseln
    }
    
    // ********** End Filling Header + Body Fields: PARSED **********
    
    
    // ********** Begin Console Output: Found Resources **********
    
    if ([_verboseLogSwitch isOn]) {
        NSLog(@"Found Resources: %i",[foundResourceKeys count]);
        for (int i = 0; i < [foundResourceKeys count]; i++) {
            NSString *key = [[NSString alloc] initWithString:[foundResourceKeys objectAtIndex:i]];
            NSString *value = [[NSString alloc] initWithString:[foundResourceValues objectAtIndex:i]];
            NSLog(@"Key: \"%@\", Value: \"%@\"",key, value);
        }
    }
    
    // ********** Begin Console Output: Found Resources **********
    
    
    // ********** Begin Building TableView **********
    
    if ([foundResourceKeys count] > 0) {
        // TableView can now be built: enable "Resources" button
        [_showResourcesButton setAlpha:1];
        [_showResourcesButton setEnabled:YES];
        // when the button "Resources" is pressed, the overwritten method prepareForSegue:sender is called
    }
    
    // ********** End Building TableView **********

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"resourcesTableViewPopover"]) {
        // Get reference to the destination view controller
        ResourcesTableViewController *resourceTableViewController = [segue destinationViewController];
        
        // Passing the found resources to the storyboard instance
        [resourceTableViewController setKeys:foundResourceKeys];
        [resourceTableViewController setValues:foundResourceValues];

        // pass the Table View Controller the references for communicating with this view
        // url text field, button, method, so that it can pass the returning url
        [resourceTableViewController setReferenceToUrl:_url];
        // the popover controller for being able to dismiss it programmatically again
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        [resourceTableViewController setReferenceToPopoverController:[popoverSegue popoverController]];
        // baseURL to the table view in case there is only a resource (not a full)) url that should be loaded
        // and the foll url needs to be built
        [resourceTableViewController setReferenceToBaseUrl:[self urlPart:_url.text definePart:@"baseUrl"]];
    } else if ([[segue identifier] isEqualToString:@"logOutputViewPopover"]) {
        // Get reference to the destination view controller again
        LogOutputViewController *logOutputViewController = [segue destinationViewController];
        // passing the logPath
        [logOutputViewController setReferenceToLogPath:logPath];
    } else if ([[segue identifier] isEqualToString:@"HeaderKeysViewPopover"]) {
        HeaderKeysViewController *headerKeysViewController = [segue destinationViewController];
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        [headerKeysViewController setReferenceToPopoverController:[popoverSegue popoverController]];
        [headerKeysViewController setReferenceToHeaderKey:_keyTextField];
        [headerKeysViewController setGeneralHeaders:generalHeaders];
        [headerKeysViewController setRequestHeaders:requestHeaders];
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

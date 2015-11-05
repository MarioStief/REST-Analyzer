//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

// Surpress the timestamp and process name in NSLog, looks less overwhelming
#ifdef DEBUG
#define NSLog(output, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:output, ##__VA_ARGS__] UTF8String]);
#endif

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ******************** Begin redirect logging output to file ********************
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:logPath]) {
        NSLog (@"Existing log file found at %@ - logging to file enabled.", logPath);
        freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
        [_logToFileSwitch setOn:YES];
        [_logFileButton setEnabled:YES];
        [_verboseLogLabel setEnabled:YES];
        [_verboseLogSwitch setEnabled:YES];
    } else
        // no logging by default
        NSLog (@"No existing log file found, logging disabled.");

    // ******************** End redirect logging output to file ********************
    
    
    
	// ******************** Begin additional setup ********************
    
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
    parsedText = [[NSMutableString alloc] init];
    foundResourceKeys = [[NSMutableArray alloc] init];
    foundResourceValues = [[NSMutableArray alloc] init];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0]; // if globally disabled
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1]; // single parts can't
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2]; // separately set enabled
    [_showResourcesButton setEnabled:NO];
    numberOfRows = 0;
    [_fontSize setUserInteractionEnabled:NO]; // field that shows font size shouldn't be able to call the keyboard
    [_showResourcesButton setAlpha:0.5]; // decreased alpha makes it more obvious that this field is still inactive
    [_backButton setEnabled:NO]; // set inactive
    [_forwardButton setEnabled:NO]; // set inactive
    [_contentScrollViewText setText:requestBody];
    [_bodyHeaderSwitch setSelectedSegmentIndex:1];
    generalHeaders = [[NSArray alloc]initWithObjects:@"Cache-Control",@"Connection",@"Content-Encoding",@"Content-Language",@"Content-Length",@"Content-Location",@"Content-MD5",@"Content-Range",@"Content-Type",@"Pragma",@"Trailer",@"Via",@"Warning",@"Transfer-Encoding",@"Upgrade",nil];
    requestHeaders = [[NSArray alloc]initWithObjects:@"Accept",@"Accept-Charset",@"Accept-Encoding",@"Accept-Language",@"Accept-Ranges",@"Authorization",@"Depth",@"Destination",@"Expect",@"From",@"Host",@"If",@"If-Match",@"If-Modified-Since",@"If-None-Match",@"If-Range",@"If-Unmodified-Since",@"Lock-Token",@"Max-Forwards",@"Overwrite",@"Proxy-Authorization",@"Range",@"Referer",@"TE",@"Timeout",@"User-Agent",nil];
    headerKeysArray = [[NSMutableArray alloc] init];
    headerValuesArray = [[NSMutableArray alloc] init];
    
    // ******************** End additional setup ********************
    
#pragma debug
    // Debug: JSON
    // _url setText:@"https://graph.facebook.com/19292868552";
    // _url setText:@"test:test@test.deathangel.net/test.json";
    
}

- (void)viewDidUnload {
    // cleaning the kitchen after cooking ;-)
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
    [self setBodyHeaderSwitch:nil];
    [self setProgressBarDescription:nil];
    [super viewDidUnload];
}

// ******************** Orientation change setup ********************

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// ******************** Remove the onscreen keyboard after pressing "Go" button: ********************

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _url)
        [self go:nil];
    else if (textField == _username)
        [_password becomeFirstResponder];
    else if (textField == _keyTextField)
        [_valueTextField becomeFirstResponder];
    else if (textField == _valueTextField)
        [self addKeyValue:nil];
    return YES;
}



// ******************** Begin Setup Picker View ********************

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    // one column here should satisfy everyone :)
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    // number of rows is the quantity of the http methods
    return [httpVerbs count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // putting the http methods in the picker view
    return [httpVerbs objectAtIndex:row];
}

// ******************** End Setup Picker View ********************



// ******************** Begin Setup Table View ********************

- (NSInteger)tableView:(UITableView *)headersTableView numberOfRowsInSection:(NSInteger)section {
    
    // number of headers for the next request
    return numberOfRows;
}

// ********** Begin set up cell **********

- (UITableViewCell *)tableView:(UITableView *)headersTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"resourceCell";
    
    UITableViewCell *resourceTableViewCell = [headersTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (resourceTableViewCell == nil) {
        resourceTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                       reuseIdentifier:CellIdentifier];
    }
    
    // Assign the text from the Array to the cell.
    NSString *keyString = [headerKeysArray objectAtIndex:[indexPath row]];
    NSString *valueAsString = [headerValuesArray objectAtIndex:[indexPath row]];
    [[resourceTableViewCell textLabel] setText:keyString];
    [[resourceTableViewCell detailTextLabel] setText:valueAsString];

    // Colorate the HTTP Headers
    // entered header is a known general header: color green text.
    if ([generalHeaders containsObject:keyString])
        [[resourceTableViewCell textLabel] setTextColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    // entered header is a known request header: color bluegreen text.
    else if ([requestHeaders containsObject:keyString])
        [[resourceTableViewCell textLabel] setTextColor:[UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1]];
    // unknown: red text then.
    else
        [[resourceTableViewCell textLabel] setTextColor:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:1]];

    return resourceTableViewCell;
}

// ********** End set up cell **********


// ********** Header key info button **********

- (IBAction)clearUrlField:(id)sender {
    [_url setText:@""];
    [_url becomeFirstResponder];
}

// ********** "+" button pressed: **********
- (IBAction)addKeyValue:(id)sender {
    UIAlertView *alert;
    NSString *errorMessage;
    if ([[_keyTextField text] isEqualToString:@""] || [[_valueTextField text] isEqualToString:@""]) {
        // don't add empty stuff
        errorMessage = [[NSString alloc] initWithFormat:@"Please specify header and value."];
    }
    for (int i = 0; i < numberOfRows; i++) {
        // check table for duplicates
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [_headersTableView cellForRowAtIndexPath:path];
        if ([[_keyTextField text] isEqualToString:[[cell textLabel] text]]) {
            // key exists
            errorMessage = [[NSString alloc] initWithFormat:@"Key \"%@\" already specified with value \"%@\".\n"
                                      "Delete old one first.",[[cell textLabel] text],[[cell detailTextLabel] text]];
        }
    }
    
    if (errorMessage) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:errorMessage
                                          delegate:self
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles:nil];
        [alert show];
        [_keyTextField becomeFirstResponder];
        return;
    }

    // retain the cell data
    // keep the underlying model data separately from it's view representation
    [headerKeysArray addObject:[[NSString alloc] initWithString:[_keyTextField text]]];
    [headerValuesArray addObject:[[NSString alloc] initWithString:[_valueTextField text]]];

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
    [_keyTextField setText:@""];
    [_valueTextField setText:@""];
    [_keyTextField becomeFirstResponder];
}

// ********** Swype cell for delete option **********

- (void)tableView:(UITableView*)headersTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

// ********** Process swype deletion **********

- (void)tableView:(UITableView *)headersTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)path {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [headerKeysArray removeObjectAtIndex:[path row]];
        [headerValuesArray removeObjectAtIndex:[path row]];
        numberOfRows--;
        [_headersTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// ******************** End Setup Table View ********************



// ******************** Begin change selected segment index (and refresh text) ********************

// outsourced method because it's code is used in "outputToggle" and in "fontSizeSliderMove":
- (void)switchSegmentIndex {
    switch ([_outputSwitch selectedSegmentIndex]) {
        case 0:
            [_headerScrollViewText setText:requestHeader];
            [_contentScrollViewText setText:requestBody];
            break;
        case 1:
            [_headerScrollViewText setText:responseHeader];
            [_contentScrollViewText setText:responseBody];
            break;
        case 2:
            [_headerScrollViewText setText:responseHeader];
            [_contentScrollViewText setText:parsedText];
    }
}


// ******************** End change selected segment index (and refresh text) ********************



// ******************** Set up Request/Response/Parsed output toggle ********************

- (IBAction)outputToggle:(id)sender {
    [self switchSegmentIndex]; // used for the toggle
}

- (IBAction)loggingOutput:(id)sender {
    [[self navigationController] pushViewController:self animated:YES];
}


// ******************** Begin use font slider to change text field size ********************

- (IBAction)fontSizeSliderMove:(id)sender {
    [_headerScrollViewText setFont:[UIFont systemFontOfSize:[_fontSizeSlider value]]];
    [_contentScrollViewText setFont:[UIFont systemFontOfSize:[_fontSizeSlider value]]];
    [_fontSize setText:[[NSString alloc] initWithFormat:@"%i",(int)[_fontSizeSlider value]]];
    [self switchSegmentIndex]; // used for the text refresh
}

// ******************** End use font slider to change text field size ********************



// ******************** Begin set up navigation buttons ********************

- (IBAction)backButton:(id)sender {
    if ([_backButton isEnabled]) {
        historyElement = [historyElement previous];
        [_url setText:[[NSString alloc] initWithFormat:@"%@",[historyElement url]]];
        [_forwardButton setEnabled:YES];
        if ([historyElement previous] == nil)
            [_backButton setEnabled:NO];
    }
}

- (IBAction)baseUrlButton:(id)sender {
    [_url setText:[historyElement getPart:@"prevPath"]];
}

- (IBAction)forwardButton:(id)sender {
    if ([_forwardButton isEnabled]) {
        historyElement = [historyElement next];
        [_url setText:[[NSString alloc] initWithFormat:@"%@",[historyElement url]]];
        [_backButton setEnabled:YES];
        if ([historyElement next] == nil)
            [_forwardButton setEnabled:NO];
    }
}

// ******************** End set up navigation buttons ********************



// ******************** GO button pressed: ********************
- (IBAction)bodyHeaderToggle:(id)sender {
    if ([_bodyHeaderSwitch selectedSegmentIndex] == 0) {
        [_headerScrollViewText setHidden:NO];
        [_contentScrollViewText setHidden:YES];
    } else if ([_bodyHeaderSwitch selectedSegmentIndex] == 1) {
        [_headerScrollViewText setHidden:YES];
        [_contentScrollViewText setHidden:NO];
    }
}

- (IBAction)go:(id)sender {
    
    // ******************** Remove Keyboard *******************
    [_url resignFirstResponder];
    
    // ******************** New Request started: Do a full reset to avoid side effects ********************
    // buttons/switches
    [_outputSwitch setSelectedSegmentIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:0];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:1];
    [_outputSwitch setEnabled:NO forSegmentAtIndex:2];
    [_showResourcesButton setAlpha:0.5];
    [_showResourcesButton setEnabled:NO];
    [_detectedJSON setHighlighted:NO];
    [_detectedXML setHighlighted:NO];

    // text fields
    [_contentType setText:[[NSString alloc] init]];
    [_encoding setText:[[NSString alloc] init]];
    [_headerScrollViewText setText:[[NSString alloc] init]];
    [_statusCode setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.1]];
    [_authentication setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.1] ];
    [_authentication setTextColor:[UIColor blackColor]];
    [_authentication setText:@"none"];
    [_statusCode setText:[[NSString alloc] init]];
    [_statusCode setBackgroundColor:[UIColor whiteColor]];

    // clean other stuff
    [self setValidatingState:NO];
    validatedResources = 0;
    staticIndex = 0;
    
    // check if scroll view contains an UIImageView from last run
    foundResourcesValidateConnections = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [_contentScrollViewText.subviews count]; i++)
        if ([[[[_contentScrollViewText subviews] objectAtIndex:i] description] hasPrefix:@"<UIImageView"])
            // if so -> delete
            [[[_contentScrollViewText subviews] objectAtIndex:i] removeFromSuperview];

    
    
    // ******************** First initializations:  *******************
    
    responseBody = [[NSString alloc] init];
    parsedText = [[NSMutableString alloc] init];
    responseBodyData = [[NSMutableData alloc] init];

    // Index of the selected HTTP method in the picker view:
    NSInteger methodId = [_requestMethod selectedRowInComponent:0];
    
    // HTTP method as String:
    NSString *calledMethodString = [[NSString alloc] initWithFormat:@"%@",[httpVerbs objectAtIndex:methodId]];
    
    // Start request:
    [self startRequest:calledMethodString withMethodId:methodId];
}

// receiving a authentication challenge:
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    // NSURLCredential supports HTTP Basic Authentication and HTTP Digest Authentication with username and password.
    // Client Certificate Authentication and Server Trust Authentication not implemented. Maybe later.
    
    // ******************** Begin Authentication ********************
    
    // setting the authentication text field
    [_authentication setText:@"required"];

    NSLog(@"%@ received.",[challenge description]);
    
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:[_username text]
                                                                 password:[_password text]
                                                              persistence:NSURLCredentialPersistenceNone];
        // Implement Client Certificate Authentication:
        // NSURLCredential *credential = [NSURLCredential credentialWithIdentity:(SecIdentityRef) certificates:(NSArray *) persistence:(NSURLCredentialPersistence)];
        // Implement Server Trust Authentication:
        // NSURLCredential *credential = [NSURLCredential credentialForTrust:(SecTrustRef)];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Authentication incorrect."
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
        [_authentication setBackgroundColor:[[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.1]];
        [_authentication setText:@"failed"];
        NSLog(@"%@ failed: Authentication incorrect.",[challenge description]);
    }
    
    // ******************** End Authentication ********************
}

- (IBAction)addMethodButton:(id)sender {
    NSMutableArray *newHttpVerbs = [[NSMutableArray alloc] initWithArray:httpVerbs];
    [newHttpVerbs replaceObjectAtIndex:[httpVerbs count]-1 withObject:[_addMethodTextField text]];
    httpVerbs = [[NSArray alloc] initWithArray:newHttpVerbs];
    
}

// ******************** Begin log to file ********************

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
    int count = [[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"];
    NSString *string = [[NSMutableString alloc] initWithFormat:@"Copyright © 2012 Mario Stief\n"
                        "\n"
                        "Generic Client for\n"
                        "RESTful Web Services\n"
                        "\n"
                        "• Testing HTTP Method results\n"
                        "• Parsing XML and JSON\n"
                        "• Analyzing results\n"
                        "\n"
                        "Contact adress:\n"
                        "mario.stief@gmail.com\n"
                        "\n"
                        "This app has been started %i times.", count];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Impressum"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:@"Rate this app",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id639570541"]];
}

// ******************** End log to file ********************


- (void)startRequest:(NSString*)requestMethodString
        withMethodId:(NSInteger)methodId {
        
    // ******************** Begin Request ********************

    NSLog(@"********** New Request **********");
    
    // -> Implement POST, PUT, DELETE, HEAD
    
    if (![[_url text] hasPrefix:@"http://"] && ![[_url text] hasPrefix:@"https://"])
        [_url setText:[[NSString alloc] initWithFormat:@"%@%@", @"http://", [_url text]]];
    NSString *urlString = [[NSString alloc] initWithString:[_url text]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //[request setMainDocumentURL:[[NSURL alloc]initWithString:[historyElement getPart:@"baseUrl"]]]; // This URL will be used for the “only from same domain as main document” cookie accept policy.
    [request setHTTPMethod:requestMethodString];
    
    // working with different methods

    switch (methodId) {
        case 1: // POST
        case 2: // PUT
            // saving writen text field in String
            requestBody = [_contentScrollViewText text];
            // Add Body.
            [request setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
            //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];

            // attaching the bodystring encoded as data
            [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
            
            // ********** Change HTTP Headers **********
            
            for (int i = 0; i < [headerKeysArray count]; i++) {
                NSString *key = [headerKeysArray objectAtIndex:i];
                NSString *value = [headerValuesArray objectAtIndex:i];
                if ([_verboseLogSwitch isOn]) NSLog(@"Adding header \"%@\":\"%@\" to request.",key,value);
                [request setValue:value forHTTPHeaderField:key];
            }
            
    }
    // and empty the contentScrollViewText;
    [_contentScrollViewText setText:[[NSString alloc] init]];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"Sending request: %@ %@ (%@)",requestMethodString,urlString,connection);

    // ******************** End Request ********************
    
    
    // ******************** Filling Header + Body Fields: REQUEST ********************
    
    requestHeader = [[NSString alloc] initWithFormat:@"%@",[[request allHTTPHeaderFields] description]];
    [_headerScrollViewText setText:requestHeader];
    [_outputSwitch setEnabled:YES forSegmentAtIndex:0]; // Request-Tab einschalten

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self validatingState]) {
        // error while validating the parsed resources. happens. :)
        validatedResources++;
        return;
    }
    
    NSString *errorLocalizedDescription = [[NSString alloc] initWithFormat:@"%@",[error localizedDescription]];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorLocalizedDescription
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];

    if ([error code] != -1012) // the authentication error alert is handled somewhere else
        [alertView show];
    NSLog(@"The following error occured: %@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {

    // ******************** Begin validating resource ********************

    if ([self validatingState]) {
        if ([_verboseLogSwitch isOn]) {
            NSInteger i = [[foundResourcesValidateConnections objectForKey:[connection description]] integerValue];
            NSLog(@"Receiving response %@ for resource \"%@\": %i -> %@",connection,[valueArray objectAtIndex:i],[response statusCode],([response statusCode] < 400) ? @"valid" : @"not valid");
        }
        validatedResources++;
        // calculate process bar
        float progress = 1.00*validatedResources/resourcesToValidate;
        [_loadProgressBar setProgress:progress animated:NO];
        
        if ([response statusCode] < 400) {

            // add resource to foundResources

            NSNumber *indexNumber = [foundResourcesValidateConnections objectForKey:[connection description]];
            NSInteger index = [indexNumber integerValue];
            NSString *key = [keyArray objectAtIndex:index];
            NSString *value = [valueArray objectAtIndex:index];
            
            [foundResourceKeys replaceObjectAtIndex:index withObject:key];
            NSString *valueAsString = [[NSString alloc] initWithFormat:@"%@",value];
            // should be string because class ResourceTableViewController uses string operations with it
            [foundResourceValues replaceObjectAtIndex:index withObject:valueAsString];
            if ([_verboseLogSwitch isOn]) NSLog(@"Adding #%i \"%@\":\"%@\" to resources... %i %% finished.",index,key,value,100*validatedResources/resourcesToValidate);
        }

        if (validatedResources == resourcesToValidate)
            [self validateDidFinish];
        return;
    }
    
    // ******************** End validating resource ********************

    // ******************** Begin Receiving Response Header ********************
    
    if (![response MIMEType])
        [_contentType setText:@"unknown"];
    else
        [_contentType setText:[response MIMEType]]; // Content Type-Feld setzen
    if (![response textEncodingName])
        [_encoding setText:@"unknown"];
    else
        [_encoding setText:[response textEncodingName]]; // Content Type-Feld setzen
    responseLength = (NSInteger) [response expectedContentLength];
    [self checkStatusCode:[response statusCode]]; // Statuscode aktualisieren
    if ([response statusCode] < 400) // color status code field
        [_statusCode setBackgroundColor:[[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:0.1]];
    else
        [_statusCode setBackgroundColor:[[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.1]];

    NSLog(@"Receiving response: %@, type: %@, charset: %@, status code: %i",[response description],[response MIMEType],[response textEncodingName],[response statusCode]);
    if ([_verboseLogSwitch isOn]) NSLog(@"Response header: %@",[[response allHeaderFields] description]);

		responseHeader = [[response allHeaderFields] description];
        [_headerScrollViewText setText:responseHeader];
        [_outputSwitch setSelectedSegmentIndex:1]; // zum Response-Tab wechseln
        [_outputSwitch setEnabled:YES forSegmentAtIndex:1]; // Request-Tab einschalten

    // ******************** End Receiving Response Header ********************
    
    
    // ******************** Begin actualize history ********************
    
    if ([response statusCode] < 400) {
        // if the slash had been cut off: still the same url
        BOOL urlIsTheSame = ([[_url text] isEqualToString:[[NSString alloc] initWithFormat:@"%@",[historyElement url]]] ||
                             [[_url text] isEqualToString:[[NSString alloc] initWithFormat:@"%@/",[historyElement url]]]);
        if (!historyElement) {
            // new history: initialize
            historyElement = [[HistoryElement alloc] init];
            [historyElement setUrl:[_url text]];
        } else if (!urlIsTheSame) {
            // history exists, and entry is new: initialize new element and connect each other
            HistoryElement *oldElement = historyElement;
            historyElement = [[HistoryElement alloc] init];
            [historyElement setUrl:[_url text]];
            [historyElement setPrevious:oldElement];
            [_backButton setEnabled:YES];
            [historyElement setNext:nil];
            [_forwardButton setEnabled:NO];
            [oldElement setNext:historyElement];
        }
        if (!urlIsTheSame) {
            // if URL is different: set new ones.
            [historyElement setUrl:[historyElement getPart:@"fullPath"]];
        }
        
        if([[response MIMEType] rangeOfString:@"json"].location != NSNotFound ||
           [[response MIMEType] rangeOfString:@"javascript"].location != NSNotFound ||
           [[historyElement url] hasSuffix:@".json"])
            [_detectedJSON setHighlighted:YES];
        else if([[response MIMEType] rangeOfString:@"xml"].location != NSNotFound ||
                [[historyElement url] hasSuffix:@".xml"])
            [_detectedXML setHighlighted:YES];

    }
    
    // ******************** End actualize history ********************
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_bodyData {
    
    if (validatedResources)
        // just validating urls. not interested in bodys.
        // strange thing this method is called when receiven a head-response...
        return;
    
    // ******************** Begin Receiving Response Body ********************
    
    [responseBodyData appendData:_bodyData];
    if (responseLength > -1 ) {
        [_loadProgressBar setHidden:NO];
        [_progressBarDescription setText:@"Loading Resource..."];
        [_progressBarDescription setHidden:NO];
        float progress = 1.00*[responseBodyData length]/responseLength;
        [_loadProgressBar setProgress:progress animated:NO];
        if ([_verboseLogSwitch isOn]) NSLog(@"%i/%i bytes received.",[responseBodyData length],responseLength);
    } else {
        [_loadIndicatorView startAnimating];
        NSLog(@"%i bytes received.",[responseBodyData length]+[_bodyData length]);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if ([self validatingState])
        // while validating, this is not relevant
        return;

    // Connection succeeded in downloading the request.
    NSLog(@"Loading complete.");
    [_progressBarDescription setHidden:YES];
    [_loadProgressBar setHidden:YES];
    [_loadIndicatorView stopAnimating];
    
    // ********** Filling Body Field: RESPONSE **********

    uint8_t c;
    [responseBodyData getBytes:&c length:1];
    NSString *imageType;
    switch (c) {
        case 0xFF:
            imageType = @"image/jpeg";
            break;
        case 0x89:
            imageType = @"image/png";
            break;
        case 0x47:
            imageType = @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            imageType = @"image/tiff";
    }
    if (imageType) {
        // Image detected. Showing this instead of text.
        NSLog(@"%@ detected.",imageType);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[_contentScrollViewText bounds]];
        [imageView setImage:[UIImage imageWithData:responseBodyData]];
        [_contentScrollViewText addSubview:imageView];
        return;
    } else
        // No image. Guess text instead.
        responseBody = [[NSString alloc] initWithData:responseBodyData encoding:NSASCIIStringEncoding]; // UTF8 won't show some sites here, for example www.google.de
        [_contentScrollViewText setText:responseBody];
    
    // response received -> parsing now if possible.
    [self parseResponse];
    
    // program finished - flush cache to file
    fflush(stderr);
}

// ******************** End Receiving Response Body ********************

- (void)parseResponse {

    keyArray = [[NSMutableArray alloc] init];
    valueArray = [[NSMutableArray alloc] init];
    
    // ******************** Begin Parsing Response ********************

    BOOL parsingSuccess = NO;
    NSDictionary *parsedResponseAsDictionary;

    
    
    // Bei erkannten Formaten: zugehöriger Highlighter aktivieren, dann entsprechend parsen
    if([_detectedJSON isHighlighted]) {
        // Ist "json" oder "javascript" im Content Type vorhanden, kann auf valides JSON geschlossen werden:
        // application/json, application/x-javascript, text/javascript, text/x-javascript, text/json, text/x-json
        if ([_verboseLogSwitch isOn]) NSLog(@"Parsing JSON...");
        
        // JSON parsen und als Wörterbuch abspeichern
        NSError *err = nil;
        parsedResponseAsDictionary = [NSJSONSerialization JSONObjectWithData:responseBodyData options:NSJSONWritingPrettyPrinted error:&err];
        if ([parsedResponseAsDictionary count] > 0) {
            keyArray = [[NSMutableArray alloc] initWithArray:[parsedResponseAsDictionary allKeys]];
            valueArray = [[NSMutableArray alloc] initWithArray:[parsedResponseAsDictionary allValues]];
            resourcesToValidate = [keyArray count];
            NSLog(@"Parsing JSON successful. %i elements found.", resourcesToValidate);
            parsingSuccess = YES;
            if (!requestBody)
                // if request body is still empty and a json site has been requested, provide a simple json syntax as request
                requestBody = @"{\n\t\"key\":\"value\"\n}";
        } else {
            NSLog(@"Error in parsing JSON.");
        }
    } else if([_detectedXML isHighlighted]) {
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
            keyArray = [[NSMutableArray alloc] initWithArray:[xmlParser keyArray]];
            valueArray = [[NSMutableArray alloc] initWithArray:[xmlParser valueArray]];
            resourcesToValidate = [keyArray count];
            NSLog(@"Parsing XML successful. %i elements found.", resourcesToValidate);
            if (!requestBody)
                // if request body is still empty and a json site has been requested, provide a simple json syntax as request
                requestBody = @"<?xml version=\"1.0\"?>\n\n<tag xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n\t<element attribute=\"\">\n\t\tkey\n\t</element>\n</tag>";
        } else {
            NSLog(@"Error in parsing XML.");
        }
    }
    
    // ******************** End Parsing Response ********************

    
    // ******************** Filling Header + Body Fields: PARSED ********************
    
    if (parsingSuccess) {

        foundResourceKeys = [[NSMutableArray alloc] initWithCapacity:resourcesToValidate];
        foundResourceValues = [[NSMutableArray alloc] initWithCapacity:resourcesToValidate];
        for (int i = 0; i < resourcesToValidate; i++) {
            [foundResourceKeys addObject:@""];
            [foundResourceValues addObject:@""];
        }
        
        [self processKeys:keyArray withValues:valueArray iteration:nil];
        
        // ********** End Filling Header + Body Fields: PARSED **********
    }
}


// ******************** Begin building Found Resources ********************

- (void)processKeys:(NSArray*)localKeys
         withValues:(NSArray*)localValues
          iteration:(NSMutableString*)iter {

    // Reactivate progress bar:
    [_contentScrollViewText setText:@""];
    [_progressBarDescription setText:@"Validating resource candidates..."];
    float progress = 1.00*validatedResources/resourcesToValidate;
    [_loadProgressBar setProgress:progress animated:NO];
    [_progressBarDescription setHidden:NO];
    [_loadProgressBar setHidden:NO];
    
    // shifting on the "parsed" tab for nice printing if an array is found:
    
    if (!iter)
        iter = [[NSMutableString alloc] init];
    else
        [iter appendString:@"\t"];
    
    // process key and values:
    
    NSLog(@"Validating potential resources for well-formedness and reachability...");
    
    for(int i = 0; i < [localKeys count]; i++) {
        
        NSString *key = [[NSString alloc] initWithString:[localKeys objectAtIndex:i]];
        NSString *value = [[NSString alloc] initWithFormat:@"%@",[localValues objectAtIndex:i]];
        
        [parsedText appendFormat:@"%@%@",iter,key];
        [parsedText appendString:@": "];
        NSString *string = [[NSString alloc] initWithFormat:@"%@",value];

        if ([string hasPrefix:@"{"] || [string hasPrefix:@"("]) {
            // An array has been found
            resourcesToValidate--;
            if ([_verboseLogSwitch isOn]) NSLog(@"Array found while parsing.");
            
            NSDictionary *dic = [string propertyListFromStringsFileFormat];
            if ([dic count] == 0) {
                [parsedText appendString:string];
                if ([_verboseLogSwitch isOn]) NSLog(@"Error in parsing array.");
                if ([string hasPrefix:@"{"] || [string hasPrefix:@"("]) {
                    #pragma mark Array in array detected - room for improvement."
                    NSLog(@"Array in array detected - room for improvement.");
                    // string parsen. string hat muster: ({…},{…},…) oder so ähnlich
                    // in substrings aufteilen
                    // für jeden substring: NSDictionary *dic = [substring propertyListFromStringsFileFormat];
                    // dann die else hier drunter
                }
            } else {
                ([string hasPrefix:@"{"]) ? [parsedText appendString:@"{\n"] : [parsedText appendString:@"(\n"];
                NSMutableArray *keys = [[NSMutableArray alloc] initWithArray:[dic allKeys]];
                NSArray *values = [[NSArray alloc] initWithArray:[dic allValues]];
                if ([_verboseLogSwitch isOn]) NSLog(@"Parsing array successful. %i elements found.", [keys count]);

                // insert new keys and values into keyArray and valueArray
                
                for (int j = 0; j < [keys count]; j++) {
                    // add path to key:
                    NSString *newKeyWithArrayPath = [[NSString alloc] initWithFormat:@"%@/%@",[localKeys objectAtIndex:i],[keys objectAtIndex:j]];
                    [keys replaceObjectAtIndex:j withObject:newKeyWithArrayPath];
                    // insert new objects into global key- and value-arrays to be processed in the next loop iteration
                    [keyArray insertObject:[keys objectAtIndex:j] atIndex:staticIndex+j+1];
                    [valueArray insertObject:[values objectAtIndex:j] atIndex:staticIndex+j+1];
                    //NSLog(@"object at index %i: %@",staticIndex+j+1,[keyArray objectAtIndex:staticIndex+j+1]);
                    resourcesToValidate++;
                    [foundResourceKeys addObject:@""];
                    [foundResourceValues addObject:@""];
                }
                
                // remove the array containing key:value pair
                [keyArray removeObjectAtIndex:staticIndex];
                [valueArray removeObjectAtIndex:staticIndex];
                [foundResourceKeys removeObjectAtIndex:staticIndex];
                [foundResourceValues removeObjectAtIndex:staticIndex];
                
                
                // call this method recursively
                [self processKeys:keys withValues:values iteration:iter];
                i += [keys count];
                // undo the last increase from the processKeys iteration
                i--;
                staticIndex--;
                
                iter = [[NSMutableString alloc] initWithString:[iter substringToIndex:[iter length]-1]];
                ([string hasPrefix:@"{"]) ? [parsedText appendString:@"}"] : [parsedText appendString:@")"];


            }
            
        } else {
            // No array.
            [parsedText appendString:string];

            NSURL *link = [[NSURL alloc] initWithString:string];            
        
            [self validateURL:link withKey:key withIndex:staticIndex];
        }
        [parsedText appendString:@"\n"];
        staticIndex++;
    }
}

- (void)validateURL:(NSURL*)link
           withKey:(NSString*)key
         withIndex:(NSInteger)i {
    
    if (link == nil) {
        // URL is invalid.
        validatedResources++;
        if ([_verboseLogSwitch isOn]) NSLog(@"\"%@\" cannot be part of a well-formed url. (%i/%i)",[valueArray objectAtIndex:i],validatedResources,resourcesToValidate);
        return;
    }
    
    NSURL *candidate;
    if ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"http"])
        // Link beginnt mit http beginnt
        candidate = [link copy];
    else if ([[[NSString alloc] initWithFormat:@"%@",link] hasPrefix:@"/"]) {
        // Link beginnt mit /, teste base url + link auf valide Resource
        NSString *candidateString = [[NSString alloc] initWithFormat:@"%@%@",[historyElement getPart:@"baseUrl"],link];
        candidate = [[NSURL alloc] initWithString:candidateString];
    }
    else {
        // Link beginnt weder mit http noch mit /, teste aktuelles Verzeichnis + link auf valide Resource
        NSString *prevPath = [historyElement getPart:@"highestDir"];
        NSString *candidateString;
        if ([prevPath hasSuffix:@"/"])
            candidateString = [[NSString alloc] initWithFormat:@"%@%@",prevPath,link];
        else
            candidateString = [[NSString alloc] initWithFormat:@"%@/%@",prevPath,link];
        candidate = [[NSURL alloc] initWithString:candidateString];
    }
    if (candidate && [candidate scheme] && [candidate host]) {
        // well-formed
    
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:candidate];
        [request setHTTPMethod:@"HEAD"];
    
        [self setValidatingState:YES];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
        NSNumber *iAsNSNumber = [[NSNumber alloc] initWithInt:i];
        // ARC doesn't allow cast from NSInteger to id.  But NSInteger -> NSNumber -> id is valid.
        
        [foundResourcesValidateConnections setValue:iAsNSNumber forKey:[connection description]];

        if ([_verboseLogSwitch isOn]) NSLog(@"#%i: link %@ -> %@ is well-formed. Checking reachability...", i, link, candidate);
    } else {
        validatedResources++;
        if ([_verboseLogSwitch isOn]) NSLog(@"Testing link %@ -> %@: well-formed: no (%i/%i)", link, candidate,validatedResources,resourcesToValidate);
    }
}

- (void)validateDidFinish {
    
    // Connection succeeded in downloading the request.
    NSLog(@"Loading complete.");
    [_progressBarDescription setHidden:YES];
    [_loadProgressBar setHidden:YES];
    [_loadIndicatorView stopAnimating];
    if ([parsedText length] > 0) {
        [_contentScrollViewText setText:parsedText];
        [_outputSwitch setEnabled:YES forSegmentAtIndex:2];   // Parsed-Tab enablen
        [_outputSwitch setSelectedSegmentIndex:2];   // auf Parsed-Tab wechseln
    }
    
    // trim arrays, fields with empty strings should be deleted
    for (int i = 0; i < [foundResourceKeys count]; i++) {
        if ([[foundResourceKeys objectAtIndex:i] isEqualToString:@""]) {
            [foundResourceKeys removeObjectAtIndex:i];
            [foundResourceValues removeObjectAtIndex:i];
            i--;
        }
    }
    
    NSLog(@"%i resources added.",[foundResourceKeys count]);

    // ******************** Begin Console Output: Found Resources ********************
    
    if ([_verboseLogSwitch isOn]) {
        NSLog(@"Found Resources: %i",[foundResourceKeys count]);
        for (int i = 0; i < [foundResourceKeys count]; i++) {
            NSString *key = [[NSString alloc] initWithString:[foundResourceKeys objectAtIndex:i]];
            NSString *value = [[NSString alloc] initWithFormat:@"%@",[foundResourceValues objectAtIndex:i]];
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

// ******************** End building Found Resources ********************


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"resourcesTableViewPopover"]) {
        // Get reference to the destination view controller
        ResourcesTableViewController *resourceTableViewController = [segue destinationViewController];
        
        // Passing the found resources to the destination view
        [resourceTableViewController setKeys:foundResourceKeys];
        [resourceTableViewController setValues:foundResourceValues];

        // pass the Table View Controller the references for communicating with this view
        [resourceTableViewController setReferenceToUrl:_url];

        // pass reference to the the popover controller for being able to dismiss the new view from "here"
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        [resourceTableViewController setReferenceToPopoverController:[popoverSegue popoverController]];
        
        // baseURL to the table view in case there is only a resource (not a full)) url that should be loaded
        // and the full url needs to be built
        [resourceTableViewController setReferenceToBaseUrl:[historyElement getPart:@"baseUrl"]];
        [resourceTableViewController setReferenceToHighestDir:[historyElement getPart:@"highestDir"]];
        
    } else if ([[segue identifier] isEqualToString:@"logOutputViewPopover"]) {
        LogOutputViewController *logOutputViewController = [segue destinationViewController];
        
        // passing the logPath
        [logOutputViewController setReferenceToLogPath:logPath];
        
    } else if ([[segue identifier] isEqualToString:@"headerKeysViewPopover"]) {
        HeaderKeysViewController *headerKeysViewController = [segue destinationViewController];
        
        // passing the data to the destination view
        [headerKeysViewController setGeneralHeaders:generalHeaders];
        [headerKeysViewController setRequestHeaders:requestHeaders];
        
        // passing references for working with main view
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        [headerKeysViewController setReferenceToPopoverController:[popoverSegue popoverController]];
        [headerKeysViewController setReferenceToHeaderKey:_keyTextField];
        [headerKeysViewController setReferenceToHeaderValue:_valueTextField];
    }
}


- (void)checkStatusCode:(NSInteger)code {
    
    // ******************** Begin diligence ********************
    
    switch (code) {
        case 100:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"100 - Continue"]];
            break;
        case 101:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"101 - Switching Protocols"]];
            break;
        case 200:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"200 - OK"]];
            break;
        case 201:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"201 - Created"]];
            break;
        case 202:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"202 - Accepted"]];
            break;
        case 203:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"203 - Non-Authoritative Information"]];
            break;
        case 204:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"204 - No Content"]];
            break;
        case 205:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"205 - Reset Content"]];
            break;
        case 206:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"206 - Partial Content"]];
            break;
        case 207:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"207 - Multi-Status"]];
            break;
        case 300:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"300 - Multiple Choices"]];
            break;
        case 301:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"301 - Moved Permanently"]];
            break;
        case 302:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"302 - Found"]];
            break;
        case 303:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"303 - See Other"]];
            break;
        case 304:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"304 - Not Modified"]];
            break;
        case 305:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"305 - Use Proxy"]];
            break;
        case 307:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"307 - Temporary Redirect"]];
            break;
        case 400:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"400 - Bad Request"]];
            break;
        case 401:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"401 - Unauthorized"]];
            break;
        case 402:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"402 - Payment Required"]];
            break;
        case 403:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"403 - Forbidden"]];
            break;
        case 404:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"404 - Not Found"]];
            break;
        case 405:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"405 - Method Not Allowed"]];
            break;
        case 406:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"406 - Not Acceptable"]];
            break;
        case 407:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"407 - Proxy Authentication"]];
            break;
        case 408:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"408 - Request Timeout"]];
            break;
        case 409:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"409 - Conflict"]];
            break;
        case 410:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"410 - Gone"]];
            break;
        case 411:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"411 - Length Required"]];
            break;
        case 412:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"412 - Precondition Failed"]];
            break;
        case 413:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"413 - Request Entity Too Large"]];
            break;
        case 414:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"414 - Request-URI Too Long"]];
            break;
        case 415:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"415 - Unsupported Media Type"]];
            break;
        case 416:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"416 - Requested Range Not Satisfiable"]];
            break;
        case 417:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"417 - Expectation Failed"]];
            break;
        case 422:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"422 - Unprocessable Entity"]];
            break;
        case 423:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"423 - Locked"]];
            break;
        case 424:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"424 - Failed Dependency"]];
            break;
        case 500:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"500 - Internal Server Error"]];
            break;
        case 501:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"501 - Not Implemented"]];
            break;
        case 502:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"502 - Bad Gateway"]];
            break;
        case 503:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"503 - Service Unavailable"]];
            break;
        case 504:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"504 - Gateway Timeout"]];
            break;
        case 505:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"505 - HTTP Version Not Supported"]];
            break;
        case 507:
            [_statusCode setText:[[NSString alloc] initWithFormat:@"507 - Insufficient Storage"]];
            break;
    }
    
        // ********** End diligence **********
    
}

@end
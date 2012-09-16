//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import "ViewController.h"

@implementation ViewController
@synthesize scrollview;
@synthesize httpHeaders;
@synthesize scrollViewText;
@synthesize outputSwitch;
@synthesize detectedJSON;
@synthesize detectedXML;
@synthesize detectedHTML;
@synthesize detectedXHTML;
@synthesize authentication;
@synthesize username;
@synthesize password;
@synthesize requestMethod;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
}

- (void)viewDidUnload
{
//    [self setUrl:nil];
    [self setRequestMethod:nil];
    [self setScrollview:nil];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
    return httpVerbs.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [httpVerbs objectAtIndex:row];
}


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
    }
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
    }
    
    // Splitte die URL auf in Base URL und Ressorcenpfad:
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
        urlString = ([[NSString alloc] initWithFormat:@"http://%@", urlString]);
    
    // Trennung in BaseURL und ResourceURL
    NSArray* urlComponents = [urlString pathComponents];
    baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    
    NSLog(@"BaseURL = \"%@\", ResourcePath =\"%@\"", baseUrl, resourcePath);

    // Setze Request-Output-Feld
    requestText = [[NSString alloc] initWithFormat:@"%@ %@%@",[httpVerbs objectAtIndex:methodId], baseUrl, resourcePath];
    scrollViewText.text = requestText;
    [outputSwitch setSelectedSegmentIndex:0];
    
    // Wähle die auszuführende Methode
    switch (methodId) {
        case 0:
            // GET
            [self get];                        // die Ressource in ein lokales Objekt mappen
            break;
        case 1:
            // POST
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

- (void)splitUrl {
    

}

- (void)get {
    // GET auf die Resource
    [RKClient clientWithBaseURLString:baseUrl];
    [[RKClient sharedClient]get:resourcePath delegate:self];
}

- (void)head {
    // HEAD auf die Resource
    //[RKClient clientWithBaseURLString:baseUrl];
    //[[RKClient sharedClient]???];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
    // Detections resetten
    [detectedJSON setHighlighted:NO];
    [detectedXML setHighlighted:NO];
    [detectedHTML setHighlighted:NO];
    [detectedXHTML setHighlighted:NO];
    scrollViewText.text = @"";
    
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            responseText = [response bodyAsString];
            [self processResponse:response];
        }
        
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

- (void)processResponse:(RKResponse*)response {
    scrollViewText.text = responseText;
    [outputSwitch setSelectedSegmentIndex:1];
    if ([response isJSON]) {
        [detectedJSON setHighlighted:YES];
        // PARSEN !!!
        //RKJSONParserJSONKit* parser = [[RKJSONParserJSONKit alloc] init];
        //NSError* error = [[NSError alloc] init];
        //[parser objectFromString:[response bodyAsString] error:&error];
    }
    else if ([response isXML])
        [detectedXML setHighlighted:YES];
    else if ([response isHTML])
        [detectedHTML setHighlighted:YES];
    else if ([response isXHTML])
        [detectedXHTML setHighlighted:YES];
}

@end

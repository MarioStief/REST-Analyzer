//
//  ViewController.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 8/18/12.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollview;
@synthesize httpHeaders;
@synthesize url;
@synthesize requestMethod;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    httpVerbs = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
}

- (void)viewDidUnload
{
    [self setUrl:nil];
    [self setRequestMethod:nil];
    [self setScrollview:nil];
    [self setHttpHeaders:nil];
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
    [self startRequest:[requestMethod selectedRowInComponent:0]]; // den Request starten, die Request-ID mitgeben.
}

- (void)startRequest:(NSInteger)methodId {
    switch (methodId) {
        case 0:
            // GET
            mapper = [[ObjectMapper alloc] init];   // Speicher allokieren, Objektinstanz erstellen
            [mapper setUrl:self.url.text];          // URL an mapper übergeben
            if ([mapper splitUrl] == 1) {           // aufteilen in Base URL und Resource URL, Abbruch bei invalider URL
                NSLog(@"Error: URL invalid.");
                break;
            }
            [mapper get];                        // die Resoure in ein lokales Objekt mappen
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

@end

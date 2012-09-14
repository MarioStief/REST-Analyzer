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
    requestMethods = [[NSArray alloc] initWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"HEAD", nil];
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
    return requestMethods.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [requestMethods objectAtIndex:row];
}


- (IBAction)go:(id)sender {
    /* if (self.url.beginswith("www.") then "http://" + self.url.text;
    NSString *self.url.text = ([[NSString alloc] initWithFormat:@"http://%@", self.url.text]);
     */
    
    [self.url resignFirstResponder];    // On-Screen-Tastatur entfernen
    
    [mapper setUrl:self.url.text];      // URL an mapper übergeben
    [mapper splitUrl];                  // aufteilen in Base URL und Resource URL
    [mapper mapUrl];                    // die Resoure in ein lokales Objekt mappen
}
@end

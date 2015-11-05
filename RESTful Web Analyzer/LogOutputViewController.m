//
//  LogOutputViewController.m
//  REST Analyzer
//
//  Created by Mario Stief on 10/7/12.
//
//

#import "LogOutputViewController.h"

@implementation LogOutputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    // flush cache to file
    fflush(stderr);
    
    NSError *err;
    [_logOutputViewText setText:[[NSString alloc] initWithContentsOfFile:_referenceToLogPath encoding:NSASCIIStringEncoding error:&err]];
}

- (void)viewDidUnload {
    [self setLogOutputViewText:nil];
    [self setLogOutputViewText:nil];
    [super viewDidUnload];
}

// ********** "Show Logging Output" -> "Clear" button pressed: **********
- (IBAction)logClearButton:(id)sender {
    // empty log file
    freopen([_referenceToLogPath cStringUsingEncoding:NSASCIIStringEncoding],"w+",stderr);
    [_logOutputViewText setText:@"File deleted."];
}
@end

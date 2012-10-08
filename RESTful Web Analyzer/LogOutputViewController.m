//
//  LogOutputViewController.m
//  REST Analyzer
//
//  Created by Mario Stief on 10/7/12.
//
//

#import "LogOutputViewController.h"

@interface LogOutputViewController ()

@end

@implementation LogOutputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    NSError *err;
    _logOutputViewText.text = @"bla";
    _logOutputViewText.text = [[NSString alloc] initWithContentsOfFile:_referenceToLogPath encoding:NSASCIIStringEncoding error:&err];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLogOutputViewText:nil];
    [self setLogOutputViewText:nil];
    [super viewDidUnload];
}

// ********** "Show Logging Output" -> "Refresh" button pressed: **********
- (IBAction)logRefreshButton:(id)sender {
    // reading log from file
    NSError *err;
    _logOutputViewText.text = [[NSString alloc] initWithContentsOfFile:_referenceToLogPath encoding:NSASCIIStringEncoding error:&err];
}

// ********** "Show Logging Output" -> "Clear" button pressed: **********
- (IBAction)logClearButton:(id)sender {
    // empty log file
    freopen([_referenceToLogPath cStringUsingEncoding:NSASCIIStringEncoding],"w+",stderr);
    _logOutputViewText.text = @"File deleted.";
}
@end

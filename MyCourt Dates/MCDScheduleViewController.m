//
//  MCDScheduleViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDScheduleViewController.h"

@interface MCDScheduleViewController ()

@end

@implementation MCDScheduleViewController

@synthesize detailItem = _detailItem;
@synthesize caseScheduleWebView = _caseScheduleWebView;

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
    NSLog(@"did we get here?");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MCDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.detailItem=appDelegate.currentEvent;
    NSLog(@"This is the detail item for MCDScheduleViewController: %@", self.detailItem);
    
    [self loadCaseSchedulePage];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma Mark

-(void)loadCaseSchedulePage{
    NSLog(@"Executing in MCDScheduleViewController.m: %@", NSStringFromSelector(_cmd));
    
    NSString *caseScheduleUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/case_summary.asp?sec=history&casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    caseScheduleUrlString = [caseScheduleUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", caseScheduleUrlString);
    
    NSURL *caseScheduleUrl=[[NSURL alloc] initWithString:caseScheduleUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:caseScheduleUrl];

    NSLog(@"The request: %@", theRequest);
    [self.caseScheduleWebView loadRequest:theRequest];
}


@end

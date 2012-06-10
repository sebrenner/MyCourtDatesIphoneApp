//
//  MCDCaseDetailsViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDCaseDetailsViewController.h"

@interface MCDCaseDetailsViewController ()

@end

@implementation MCDCaseDetailsViewController

@synthesize detailItem = _detailItem;
@synthesize caseHistoryWebView = _caseHistoryWebView;

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
    MCDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.detailItem=appDelegate.currentEvent;
    
    [self loadCaseHistoryPage];
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

-(void)loadCaseHistoryPage{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    
    NSString *caseHistoryUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/case_summary.asp?sec=history&casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    caseHistoryUrlString = [caseHistoryUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", _caseHistoryWebView);
    
    NSURL *caseHistoryUrl=[[NSURL alloc] initWithString:caseHistoryUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:caseHistoryUrl];
    
    [self.caseHistoryWebView loadRequest:theRequest];
}

@end

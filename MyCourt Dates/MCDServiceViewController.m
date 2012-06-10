//
//  MCDServiceViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDServiceViewController.h"

@interface MCDServiceViewController ()

@end

@implementation MCDServiceViewController


@synthesize caseServiceWebView = _caseServiceWebView;
@synthesize detailItem = _detailItem;

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
    
    [self loadCaseServicePage];
    
}

- (void)viewDidUnload
{
    [self setCaseServiceWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma Mark

-(void)loadCaseServicePage{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    
    NSString *caseServiceUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/certified_case_check.asp?casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    caseServiceUrlString = [caseServiceUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", caseServiceUrlString);
    
    NSURL *caseServiceUrl=[[NSURL alloc] initWithString:caseServiceUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:caseServiceUrl];
    
    [self.caseServiceWebView loadRequest:theRequest];
}

@end

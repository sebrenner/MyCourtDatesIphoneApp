//
//  MCDPartiesViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDPartiesViewController.h"

@interface MCDPartiesViewController ()

@end

@implementation MCDPartiesViewController

@synthesize detailItem=_detailItem;
@synthesize casePartiesWebView=_casePartiesWebView;

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
    
    [self loadCasePartiesPage];
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

-(void)loadCasePartiesPage{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    
    NSString *casePartiesUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/case_summary.asp?sec=party&casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    casePartiesUrlString = [casePartiesUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", self.casePartiesWebView);
    
    NSURL *casePartiesUrl=[[NSURL alloc] initWithString:casePartiesUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:casePartiesUrl];
    
    [self.casePartiesWebView loadRequest:theRequest];
}

@end

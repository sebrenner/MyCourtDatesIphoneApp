//
//  MCDDocumentsViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDDocumentsViewController.h"

@interface MCDDocumentsViewController ()

@end

@implementation MCDDocumentsViewController
@synthesize detailItem=_detailItem;
@synthesize documentWebView;

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
    [self setDocumentWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma Mark

-(void)loadCaseHistoryPage{
    NSLog(@"Executing %@ in docsview for case number: %@", NSStringFromSelector(_cmd),[self.detailItem objectForKey:@"caseNumber"]);
    
    NSString *caseHistoryUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/case_summary.asp?sec=history&casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    caseHistoryUrlString = [caseHistoryUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", documentWebView);
    
    NSURL *caseHistoryUrl=[[NSURL alloc] initWithString:caseHistoryUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:caseHistoryUrl];
    
    [self.documentWebView loadRequest:theRequest];
}

@end

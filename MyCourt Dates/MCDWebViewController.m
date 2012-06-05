//
//  MCDWebViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDWebViewController.h"

@interface MCDWebViewController ()

@end

@implementation MCDWebViewController

@synthesize detailItem = _detailItem;
@synthesize caseHistoryWebView;

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
    [self setCaseHistoryWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setDetailItem:(id)newDetailItem
{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self loadCaseHistoryPage];
    }
    
//    if (self.masterPopoverController != nil) {
//        [self.masterPopoverController dismissPopoverAnimated:YES];
//    }        
}
#pragma Mark

-(void)loadCaseHistoryPage{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));

    NSString *caseHistoryUrlString = [[NSString alloc]initWithFormat:@"http://www.courtclerk.org/case_summary.asp?sec=history&casenumber=%@", [self.detailItem objectForKey:@"caseNumber"]];
    caseHistoryUrlString = [caseHistoryUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"The url: %@", caseHistoryWebView);
    
    NSURL *caseHistoryUrl=[[NSURL alloc] initWithString:caseHistoryUrlString];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:caseHistoryUrl];
        
    [self.caseHistoryWebView loadRequest:theRequest];
}

@end

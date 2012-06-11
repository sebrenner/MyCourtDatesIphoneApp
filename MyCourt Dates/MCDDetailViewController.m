//
//  MCDDetailViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDDetailViewController.h"

@interface MCDDetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MCDDetailViewController

@synthesize detailItem = _detailItem;

@synthesize eventCaseCaption = _eventCaseCaption;
@synthesize eventCaseNumber = _eventCaseNumber;
@synthesize eventDateTime = _eventDateTime;
@synthesize eventSetting = _eventSetting;
@synthesize eventLocation = _eventLocation;

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    // Update the user interface for the detail item.
    
    
    if (self.detailItem) {
        NSDictionary *theEvent = self.detailItem;
        
        if ([theEvent objectForKey:@"plaintiffs"]==@"STATE OF OHIO") {
            self.eventCaseCaption.text=[[NSString alloc]
                                   initWithFormat:@"State v.%@", 
                                   [theEvent objectForKey:@"defendants"]];
        }else {
            self.eventCaseCaption.text=[[NSString alloc]
                                   initWithFormat:@"%@ v.%@", 
                                   [theEvent objectForKey:@"plaintiffs"],
                                   [theEvent objectForKey:@"defendants"]];
        }
        
        self.eventCaseNumber.text=[theEvent objectForKey:@"caseNumber"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm EEE, MMM d, yyyy"];
        self.eventDateTime.text=[dateFormat stringFromDate:[theEvent objectForKey:@"timeDate"]];
        self.eventSetting.text=[theEvent objectForKey:@"setting"];
        self.eventLocation.text=[theEvent objectForKey:@"location"];
        
        //  save this code for async dispatches
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString *imageUrl = [[theEvent objectForKey:@"user"] objectForKey:@"profile_image_url"];
//            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.profileImage.image = [UIImage imageWithData:data];
//            });
//        });
    }    
    
//  Scott commented out this code.
//    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
//    }
}

- (void)viewDidLoad
{
    NSLog(@"Executing in detailView: %@", NSStringFromSelector(_cmd));
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // get the current event from the appdelegate
    MCDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.detailItem=appDelegate.currentEvent;
    [self configureView];
}

- (void)viewDidUnload
{
    [self setEventDateTime:nil];
    [self setEventSetting:nil];
    [self setEventLocation:nil];
    [self setEventCaseCaption:nil];
    [self setEventCaseNumber:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end

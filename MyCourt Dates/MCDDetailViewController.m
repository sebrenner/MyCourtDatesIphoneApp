//
//  MCDDetailViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDDetailViewController.h"

@interface MCDDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetLabel;




@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MCDDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize profileImage = _profileImage;
@synthesize nameLabel = _nameLabel;
@synthesize tweetLabel = _tweetLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
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
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSDictionary *tweet = self.detailItem;
        
        NSString *text = [[tweet objectForKey:@"user"] objectForKey:@"name"];
        NSString *name = [tweet objectForKey:@"text"];
        
        self.tweetLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.tweetLabel.numberOfLines = 0;
        
        self.nameLabel.text = text;
        self.tweetLabel.text = name;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage.image = [UIImage imageWithData:data];
            });
        });
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//  Scott commented out this code.
//    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setProfileImage:nil];
    [self setNameLabel:nil];
    [self setTweetLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
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

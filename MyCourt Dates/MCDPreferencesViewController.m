//
//  MCDPreferencesViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDPreferencesViewController.h"

@interface MCDPreferencesViewController ()

@end

@implementation MCDPreferencesViewController
@synthesize attorneyIdField=_attorneyIdField;

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
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    self.attorneyIdField.text=[userDefaults valueForKey:@"attorneyId"];
}

- (void)viewDidUnload
{
    [self setAttorneyIdField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)storeAttorneyId:(UITextField *)sender
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.attorneyIdField.text forKey:@"attorneyId"];
    //how do I call an update data method in the 
    
}
@end

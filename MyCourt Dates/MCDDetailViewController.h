//
//  MCDDetailViewController.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCDAppDelegate.h"

@interface MCDDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *eventCaseCaption;
@property (strong, nonatomic) IBOutlet UILabel *eventCaseNumber;
@property (strong, nonatomic) IBOutlet UILabel *eventDateTime;
@property (strong, nonatomic) IBOutlet UILabel *eventSetting;
@property (strong, nonatomic) IBOutlet UILabel *eventLocation;

@end

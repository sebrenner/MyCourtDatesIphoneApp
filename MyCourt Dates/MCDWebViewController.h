//
//  MCDWebViewController.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCDAppDelegate.h"

@interface MCDWebViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UIWebView *caseHistoryWebView;

@end

//
//  MCDDocumentsViewController.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCDAppDelegate.h"

@interface MCDDocumentsViewController : UIViewController


//  http://www.courtclerk.org/case_summary.asp?sec=history&casenumber=B102129

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIWebView *documentWebView;

@end

//
//  MCDPreferencesViewController.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCDPreferencesViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *attorneyIdField;
- (IBAction)storeAttorneyId:(UITextField *)sender;

@end

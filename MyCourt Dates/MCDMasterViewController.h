//
//  MCDMasterViewController.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/tree.h>
#import "TFHpple.h"

@class MCDDetailViewController;

#import <CoreData/CoreData.h>

@interface MCDMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>{

    NSMutableDictionary *events;
    NSString *attorneyId;
    NSString *attorneyFName;
    NSString *attorneyMName;
    NSString *attorneyLName;
}

@property (strong, nonatomic) MCDDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
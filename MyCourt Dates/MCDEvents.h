//
//  MCDEvents.h
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCDMasterViewController.h"

@interface MCDEvents : NSObject{
    NSMutableDictionary *events;
}
@property NSString *attorneyId;
@property NSString *fName;
@property NSString *mName;
@property NSString *lName;
@property NSDictionary *theEvents;



// Subclasses must implement this method. It will be invoked on a secondary thread to keep the application responsive.
// Although NSURLConnection is inherently asynchronous, the parsing can be quite CPU intensive on the device, so
// the user interface can be kept responsive by moving that work off the main thread. This does create additional
// complexity, as any code which interacts with the UI must then do so in a thread-safe manner.


- (void)downloadAndParseAttorneyId:(NSString *)theId
                    upDateThisView:(MCDMasterViewController *) theView;

@end

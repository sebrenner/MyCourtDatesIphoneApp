//
//  MCDEvents.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDEvents.h"
#import "MCDMasterViewController.h"

@implementation MCDEvents

@synthesize attorneyId=_attorneyId;
@synthesize fName=_fName;
@synthesize mName=_mName;
@synthesize lName=_lName;
@synthesize theEvents=_theEvents;

- (void)downloadAndParseAttorneyId:(NSString *)theId
                    upDateThisView:(MCDMasterViewController *) theView{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString: [[NSString alloc] initWithFormat:@"http://mycourtdates.com/json.php?id=%@", theId]]];
            //        NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
            NSError* error;
            
            NSArray *rawEvents = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            self->events=[[NSMutableDictionary alloc]initWithCapacity:200];
            
            // Loop through the events and create a dictionary of keyed on date.
            // The values are arrays of events set on that date.
            
            for (NSDictionary *theEvent in rawEvents)
            {
                NSMutableArray *arrayOfEvents;
                NSString *date = [[theEvent objectForKey:@"timeDate"] substringToIndex:10];
                
                if ([self->events objectForKey:date]) {
                    // If there is is an existing dictionary entry
                    arrayOfEvents=[[NSMutableArray alloc]initWithArray:
                                   [self->events objectForKey:date]];
                    [arrayOfEvents addObject:theEvent];
                }else {
                    arrayOfEvents = [[NSMutableArray alloc] initWithObjects:theEvent, nil];
                }
                [self->events setObject:arrayOfEvents forKey:date];
            }
        //        NSLog(@"Events : %@",self->events);
        //        NSLog(@"This should be the size of mutableDictionary of sections : %d",[self->events count]);
        
        
            if ([theView isViewLoaded]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [theView.tableView reloadData];
                });
            }
    });
}



@end

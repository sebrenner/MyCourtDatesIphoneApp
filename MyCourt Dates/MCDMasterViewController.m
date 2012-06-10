//
//  MCDMasterViewController.m
//  MyCourt Dates
//
//  Created by Scott Brenner on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCDMasterViewController.h"
#import "MCDDetailViewController.h"

@interface MCDMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MCDMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self fetchEvents];
    self.navigationItem.title= @"Scott was here";
    
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.detailViewController = (MCDDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

}

- (void)viewDidUnload
{
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

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self->events allKeys] count];
    return [self->events count];
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRow = [[self->events valueForKey:[
                                    [[self->events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]
                                            objectAtIndex:section]] count];
//    NSLog(@"There are %d rows in section %d", numberOfRow,section);

    return numberOfRow;

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerString =[[[self->events allKeys]
                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
//    NSLog(@"This is a section header:%@", headerString); 
    return headerString;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    NSArray *titles =[[self->events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
////    NSLog(@"Title for tableview: %@", titles);
//    return titles;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Added by Scott
    static NSString *CellIdentifier = @"eventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *event = [[self->events valueForKey:[[[self->events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];  

    // Setup case number
    NSString *caseNumber=[event objectForKey:@"caseNumber"];
    if ([caseNumber isEqualToString:@""]) {
        caseNumber=@"Sealed";
    }

    // Setup party names and caption
    NSString *plaintiffs;
    if ([[event objectForKey:@"plaintiffs"] isEqualToString:@"vs."] ) {
        plaintiffs=@"Sealed";
    }else{
        plaintiffs=[[event objectForKey:@"plaintiffs"] capitalizedString];
    }

    NSString *defendants;
    if ([[event objectForKey:@"defendants"] isEqualToString:@""]) {
        defendants=@"Sealed";
    }else {
        defendants=[[event objectForKey:@"defendants"] capitalizedString];
    }
    
    NSString *firstLetter = [caseNumber substringToIndex:1];
    if ([firstLetter isEqualToString:@"B"]) {
//        NSLog(@"Crim Case: This is the string for the plaintiff's key: %@",[event objectForKey:@"plaintiffs"]);
        NSString *caption=[NSString
                           stringWithFormat:@"State v.\n%@", defendants];
        cell.textLabel.text=caption;
    }else {
//        NSLog(@"Non-crim case: This is the string for the plaintiff's key: %@",[event objectForKey:@"plaintiffs"]);
        NSString *caption=[NSString
                           stringWithFormat:@"%@ v.\n%@", plaintiffs,defendants];
        cell.textLabel.text=caption;
    }

    cell.detailTextLabel.text = [[NSString
                                 stringWithFormat:@"%@\nat %@",
                                 [event objectForKey:@"timeDate"],
                                 [event objectForKey:@"location"]]
                                 capitalizedString];
    
    return cell;
    // END added by Scott.  Following code commented out.
    
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    [self configureCell:cell atIndexPath:indexPath];
//    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Just called: %@", NSStringFromSelector(_cmd));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.detailViewController.detailItem = [[self->events valueForKey:[[[self->events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSLog(@"This is the event to be passed to the detailItem: %@", self.detailViewController.detailItem );

        
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        self.detailViewController.detailItem = object;

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Executing: %@", NSStringFromSelector(_cmd));
    NSLog(@"the Sender is: %@", sender);
    if ([[segue identifier] isEqualToString:@"showEvent"]) {
        //  get the section and row number
        NSInteger theSection = [[self tableView].indexPathForSelectedRow section];
        NSInteger theRow = [[self tableView].indexPathForSelectedRow row];
        NSDictionary *theEvent = [[self->events valueForKey:[[[self->events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:theSection]] objectAtIndex:theRow];  

        //  Store the event dictionary in the app delegate
        MCDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];        
        appDelegate.currentEvent = theEvent;
    }    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - JSON Methods

- (void)fetchEvents;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: @"http://mycourtdates.com/json.php?id=71655"]];
//        NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
        NSError* error;
        
        NSArray *rawEvents = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:&error];
        
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


        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}
- (NSString *)getScheduleForAttorneyId:(NSString *)theId{
    
    NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
    [date_formater setDateFormat:@"Z"];
    NSString * tz=[date_formater stringFromDate:[NSDate date]];
    NSLog(@"Zone: %@", tz);    
    
    NSString *htmlStr=[self getHTMLScheduleForAttorneyId:theId];
    NSData *htmlData=[htmlStr dataUsingEncoding:NSUTF8StringEncoding]; 
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements = [xpathParser searchWithXPathQuery:@"/html//table//td//text()"];  // select text of every td of every table  
    
    NSLog(@"Elements: %@", elements);
    
    if ([elements count] <= 0 ) {
        return @"No result returned from xpath query";
    }
    
    // extract attorney info
    NSString *attorneyName = [[NSString alloc] initWithString: [[elements objectAtIndex:7] content]];
    //    NSLog(@"Attorney Name: %@", attorneyName);
    
    // Create a subarray of just the events
    NSRange theRange;
    theRange.location = 16;
    theRange.length = [elements count] - 16;
    NSArray *eventElements = [elements subarrayWithRange:theRange];
    //    NSLog(@"eventElements: %@", eventElements);
    
    
    //    The following block loops through the elements and 
    //    gangs them into event dictionaries and then adds the dictionary to a mutable array.
    NSMutableArray *theEvents=[NSMutableArray arrayWithCapacity:200];
    NSMutableDictionary *theEvent=[NSMutableDictionary dictionaryWithCapacity:6 ];
    NSDate *theDateTime;
    NSString *tempDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm a"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    
    int counter = 0;
    for (TFHppleElement *element in eventElements) {
        //        NSLog(@"%d: %@", counter, [element content]);
        switch (counter) {
            case 1:
                //                NSLog(@"The date: %@", [element content]);
                tempDate = [element content];
                break;
            case 4:
                //                NSLog(@"The time: %@", [element content]);
                tempDate = [tempDate stringByAppendingFormat:@" %@",[element content]];
                //                NSLog(@"tempDate: %@", tempDate);
                theDateTime = [dateFormat dateFromString:tempDate];
                //                NSLog(@"TheDateTime: %@", theDateTime);
                [theEvent setObject:theDateTime forKey:@"timeDate"];
                break;
            case 7:
                // NSLog(@"The case number: %@", [element content]);
                [theEvent setObject:[element content] forKey:@"caseNumber"];
                break;
            case 10:
                //                NSLog(@"The caption: %@", [element content]);
                [theEvent setObject:[element content] forKey:@"caption"];
                break;
            case 13:
                //                NSLog(@"The active: %@", [element content]);
                if ([[element content] isEqualToString:@"A"]) {
                    NSLog(@"active");
                    [theEvent setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
                }else {
                    NSLog(@"active");
                    [theEvent setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
                }
                [theEvent setObject:[element content] forKey:@"activeStr"];
                break;
            case 16:
                //                NSLog(@"The location: %@", [element content]);
                [theEvent setObject:[element content] forKey:@"location"];
                break;
            case 19:
                //                NSLog(@"The setting: %@\n*** New Event ***", [element content]);
                [theEvent setObject:[element content] forKey:@"setting"];
                [theEvents addObject:[theEvent copy]];
                //                NSLog(@"The Event: %@", theEvent);
                //                [theEvent removeAllObjects];
                counter = -5;
                break;
            default:
                //                NSLog(@"Pass: %@", [element content]);
                break;
        } //end of switch
        counter++;
    }//end of for loop
    
    NSString *results = [[NSString alloc] initWithFormat:@"Here is the schedule for %@.  \nBar number %@.  \nThere are %d settings.",attorneyName, theId, [theEvents count] ];
    NSLog(results);
    NSLog(@"The Events: %@", theEvents);
    
    return results;
}

- (NSString *)getHTMLScheduleForAttorneyId:(NSString *)attorneyId{
    NSString *theUrl = [[NSString alloc] initWithFormat:@"http://www.courtclerk.org/attorney_schedule_list_print.asp?court_party_id=%@", attorneyId];
    //    NSLog(@"this is the url:%@", theUrl);
    NSString *html= [NSString stringWithContentsOfURL:[NSURL URLWithString: theUrl] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"this is the html:%@", html);
    
    return html;
    
    return @"<html><head><title>Tracy Winkler - Clerk of Courts</title><meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'><link rel='stylesheet' type='text/css' href='/images/clerkwebss.css'></head><br><table width='775' cellpadding='0' cellspacing='0' border='0'><tr><td valign='top' width='650'><table width='100%' cellpadding='0' cellspacing='0' border='0'><tr><td><table width='100%' cellpadding='5' cellspacing='0' border='1' bordercolor='#003366'><tr class='tableheader'><td colspan='2' align='center'><div class='tableheader'>Schedules for Attorneys</div></td></tr><tr><td align='right'><table width='100%' cellpadding='0' cellspacing='0' border='0'><tr class='row2'><td width='25%'><strong>Attorney Name:</strong></td><td width='75%' align='left'>HEEKIN/THOMAS/D JR</td></tr><tr class='row1'><td><strong>Attorney ID:</strong></td><td>40784</td></tr><tr><td colspan='2'>&nbsp;</td></tr><tr><td colspan='2'><table width='100%' cellpadding='0' cellspacing='0' border='1'><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/21/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/CRB/5307'>C/12/CRB/5307</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. KATIE STENGER </td><td><strong>Status: </strong>I</td></tr><tr class='row1'><td><strong>Location: </strong>RM 124, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>REPORT HEARING</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/CRB/5307'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/22/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>10:30 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/12/TRC/4566'>/12/TRC/4566</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. CORNELL E CLISBY</td><td><strong>Status: </strong>I</td></tr><tr class='row2'><td><strong>Location: </strong>RM 160, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>MOTION TO SUPPRESS</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/12/TRC/4566'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/24/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/TRD/17809'>C/12/TRD/17809</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. THOMAS D HEEKIN</td><td><strong>Status: </strong>I</td></tr><tr class='row1'><td><strong>Location: </strong>RM 154, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/TRD/17809'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/29/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/11/CRB/32404'>/11/CRB/32404</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. JULIAN ROGERS </td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 264, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>NON-JURY TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/11/CRB/32404'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/29/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/12/CRB/5674'>/12/CRB/5674</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. VINCENT MCMULLEN </td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 280, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/12/CRB/5674'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/29/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/11/CRB/28879'>C/11/CRB/28879</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. CHRISTOPHER PRICE </td><td><strong>Status: </strong>C</td></tr><tr class='row2'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 240</td><td><strong>Description: </strong>NON-JURY TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/11/CRB/28879'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>5/31/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:30 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=B 1106899'>B 1106899</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. JEREMY RUBY </td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 485</td><td><strong>Description: </strong>OTHER</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=B 1106899'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/4/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/CRB/5307'>C/12/CRB/5307</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. KATIE STENGER </td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 124, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>REPORT HEARING</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/CRB/5307'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/5/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/TRC/19850'>C/12/TRC/19850</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. AMANDA H DRIGGETT</td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 144, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/TRC/19850'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/6/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/11/TRC/58784'>/11/TRC/58784</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. GWENDALYN MARGARET GATTAS</td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>H.C. COURTHOUSE ROOM 220</td><td><strong>Description: </strong>MOTION TO SUPPRESS</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/11/TRC/58784'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/6/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=B 1202295'>B 1202295</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. RODNEY CURETON </td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 330</td><td><strong>Description: </strong>PLEA</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=B 1202295'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/7/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=B 0511652'>B 0511652</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. ANDREW WARRINGTON </td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 510</td><td><strong>Description: </strong>SENTENCING</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=B 0511652'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/7/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>10:30 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/11/TRC/61410'>/11/TRC/61410</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. JAY S FITTON</td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 154, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>MOTION TO SUPPRESS</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/11/TRC/61410'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/12/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/11/CRB/28879'>C/11/CRB/28879</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. CHRISTOPHER PRICE </td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 240</td><td><strong>Description: </strong>NON-JURY TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/11/CRB/28879'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/15/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/09/TRD/33431'>C/09/TRD/33431</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. DAVID  CARNES</td><td><strong>Status: </strong>I</td></tr><tr class='row1'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/09/TRD/33431'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/15/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/08/TRD/65442'>/08/TRD/65442</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. DAVID CARNES </td><td><strong>Status: </strong>I</td></tr><tr class='row2'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/08/TRD/65442'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/15/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/09/TRD/6432'>/09/TRD/6432</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. DAVID JR CARNES</td><td><strong>Status: </strong>I</td></tr><tr class='row1'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/09/TRD/6432'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/15/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/TRD/17809'>C/12/TRD/17809</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. THOMAS D HEEKIN</td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 154, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/TRD/17809'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/20/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>10:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=B 1202199'>B 1202199</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. KENNETH LAMBERT </td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>H.C. COURT HOUSE ROOM 330</td><td><strong>Description: </strong>MOTIONS</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=B 1202199'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/27/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/11/TRD/61082/A'>C/11/TRD/61082/A</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. MAURICE  ABNEY</td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>STAY</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/11/TRD/61082/A'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>6/27/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>10:30 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/12/TRC/4566'>/12/TRC/4566</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. CORNELL E CLISBY</td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 160, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>MOTION TO SUPPRESS</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/12/TRC/4566'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>7/10/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/08/TRD/65442'>/08/TRD/65442</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. DAVID CARNES </td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/08/TRD/65442'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>7/10/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/09/TRD/33431'>C/09/TRD/33431</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. DAVID  CARNES</td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/09/TRD/33431'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>7/10/2012</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=/09/TRD/6432'>/09/TRD/6432</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>CITY OF CINCINNATI vs. DAVID JR CARNES</td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 174, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>PRE-TRIAL</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=/09/TRD/6432'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row1'><td rowspan='3' align='center'><strong>Date:</strong><BR>2/6/2013</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=B 1105447--1'>B 1105447--1</A></td></tr><tr class='row1'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. KIMBERLY MICHELLE STEM</td><td><strong>Status: </strong>A</td></tr><tr class='row1'><td><strong>Location: </strong>RM 164, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>REPORT HEARING</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=B 1105447'>View Documents</a></td></tr></table></td></tr><tr><td colspan='2'><table cellpadding='0' cellspacing='0' border='0' width='100%'><tr class='row2'><td rowspan='3' align='center'><strong>Date:</strong><BR>4/18/2013</td><td rowspan='3' align='center'><strong>Time:</strong><BR>09:00 AM</td><td colspan='4'><strong>Case Number: </strong><A HREF='/case_summary.asp?casenumber=C/12/CRB/194'>C/12/CRB/194</A></td></tr><tr class='row2'><td colspan='3'><strong>Caption: </strong>STATE OF OHIO vs. MEGAN D FRENCH</td><td><strong>Status: </strong>A</td></tr><tr class='row2'><td><strong>Location: </strong>RM 124, CT HOUSE, 1000 MAIN ST</td><td><strong>Description: </strong>REPORT HEARING</td><td colspan='2'><a HREF='/case_summary.asp?sec=doc&casenumber=C/12/CRB/194'>View Documents</a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr><tr><td>&nbsp;</td></tr></table>&copy;&nbsp;2005 Patricia M. Clancy, Hamilton County Clerk of Courts. All rights reserved.</body></html>";    
}

@end

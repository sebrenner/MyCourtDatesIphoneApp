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

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
}

- (void)viewDidLoad
{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //    NSLog(@"Events Dictionary: %@", self->events);
    //    self.navigationItem.leftBarButtonItem = self.editButtonItem    
    UIBarButtonItem *prefsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showAttorneyIdAlert)];

    self.navigationItem.rightBarButtonItem = prefsButton;

    self.detailViewController = (MCDDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        
    if ([userDefaults valueForKey:@"attorneyId"]) {
        NSLog(@"userDefaults for 'attorneyId' is: %@", [userDefaults valueForKey:@"attorneyId"]);
        self->attorneyId=[userDefaults valueForKey:@"attorneyId"];
    }else {
        NSLog(@"No Attorney Id stored in preferences.  Showing pref alert.");
        [self showAttorneyIdAlert];
    }
    self.navigationItem.title= [[NSString alloc] initWithFormat:@"%@ %@ %@", self->attorneyFName,self->attorneyLName,self->attorneyId];

    //confirm that dictionaries match
    if ([self isScheduleStale:[userDefaults valueForKey:@"attorneyId"]]) {
        [self createScheduleForattorneyId:self->attorneyId];
    }else {
        [self retrieveScheduleDictionary:self];
    }
    
//    NSMutableDictionary *fromScrape = [[NSMutableDictionary alloc] initWithDictionary:[self->events copy]];
//    
//    [self retrieveScheduleDictionary:self->attorneyId];
//    NSMutableDictionary *fromRetrieve = [[NSMutableDictionary alloc] initWithDictionary:[self->events copy]];
//    
//    NSLog(@"The length of the file dictionary: %d\nThe length of the scrape dictionary: %d",
//          [fromRetrieve count], [fromScrape count]);
//    if ([fromScrape isEqualToDictionary:fromRetrieve]) {
//        NSLog(@"Yea they match.");
//    }else {
//        NSLog(@"Yea they don't match.");
//    }
        NSLog(@"The vintage of the schedule on file is %@.", [userDefaults valueForKey:@"scheduleVintage"]);
    //    NSLog(@"The events dictionary loaded from file: %@", self->events);
//    [self.tableView reloadData];
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    // Note this is pulling the key, not the date of the event
    NSString *headerDate=[[[self->events allKeys]
                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    
//    NSLog(@"This is a section header date object:%@", headerDate);

    if ([[dateFormat stringFromDate:[NSDate date]] isEqualToString:headerDate]) {
        return [[NSString alloc] initWithFormat:@"Today - %@", headerDate];
    }
    return headerDate;
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
    // Initialize the formatter.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    NSLog(@"raw date from event: %@", [event objectForKey:@"timeDate"]);
    cell.detailTextLabel.text = [[NSString
                                 stringWithFormat:@"%@\nat %@",
                                 [formatter stringFromDate:[event objectForKey:@"timeDate"]],
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
    NSLog(@"??????????%@", NSStringFromSelector(_cmd));
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Attorney Id Allert

- (void)showAttorneyIdAlert{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIAlertView *alertDialog;
    NSString *title=[[NSString alloc]initWithFormat:@"Current Attorney Id: %@",self->attorneyId];
    alertDialog = [[UIAlertView alloc]
                   initWithTitle: title
                   message:@"Please enter your Clerk of Courts Attorney Id:"
                   delegate: self
                   cancelButtonTitle: @"Ok"
                   otherButtonTitles: nil];
    alertDialog.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alertDialog show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *myattorneyId=[[alertView textFieldAtIndex:0] text];
    if ([myattorneyId isEqualToString:self->attorneyId]) {
        NSLog(@"the attorney id didn't change.");
        return;
    }else {
        NSLog(@"the attorney id changed from %@ to %@.", self->attorneyId, myattorneyId);
        self->attorneyId = myattorneyId;
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setValue:myattorneyId forKey:@"attorneyId"];
        [self->events removeAllObjects];
        NSLog(@"Removed all objects from self->events");
        [self createScheduleForattorneyId:self->attorneyId];
        NSLog(@"Added new events to self->events.");
        [self.tableView reloadData];
        self.navigationItem.title= [[NSString alloc] initWithFormat:@"%@ %@ %@", self->attorneyFName,self->attorneyLName,self->attorneyId];
        NSLog(@"Reloaded table");
    }
}

#pragma mark - Data Retrieval,storage, and processing

- (void)fetchEventsForattorneyId
{
NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr=[[NSString alloc]initWithFormat:@"http://mycourtdates.com/json.php?id=%@", self->attorneyId];
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: urlStr]];
        NSError* error;
        
        NSArray *rawEvents = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:&error];
//        NSLog(@"\n***********\n\nRawEvents from json fetch: %@\n\n\n*********\n", rawEvents);
        
        self->events=[[NSMutableDictionary alloc]initWithCapacity:200];
        
        // Loop through the events and create a dictionary keyed on date.
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
        NSLog(@"Events from fetch func: %@",self->events);
//        NSLog(@"This should be the size of mutableDictionary of sections : %d",[self->events count]);


        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)parseAttorneyName:(NSString *) attorneyName{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];

    NSArray *nameItems = [attorneyName componentsSeparatedByString:@"/"];
    self->attorneyFName = [nameItems objectAtIndex:1];
    [userDefaults setValue:self->attorneyFName forKey:@"attorneyFName"];
    self->attorneyLName = [nameItems objectAtIndex:0];
    [userDefaults setValue:self->attorneyLName forKey:@"attorneyLName"];
    if ([nameItems count] > 2 ) {
        self->attorneyMName = [nameItems objectAtIndex:2];
        [userDefaults setValue:self->attorneyMName forKey:@"attorneyMName"];
    }
    self.navigationItem.title= [[NSString alloc] initWithFormat:@"%@ %@ %@", self->attorneyFName,self->attorneyLName,self->attorneyId];
}

- (NSString *)createScheduleForattorneyId:(NSString *)theId{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));

    //  Get html as data.
    NSData *htmlData=[[self getHTMLScheduleForattorneyId:(NSString *)theId] dataUsingEncoding:NSUTF8StringEncoding]; 
    
    //  Parse table cells to an array of elements.
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [xpathParser searchWithXPathQuery:@"/html//table//td//text()"];  // select text of every td of every table  
    
    if ([elements count] <= 0 ) {
        NSLog(@"No result returned from xpath query");
        return @"No result returned from xpath query";
    }
    
    // create error 'event' for invalid attoney id.
    if ([[[NSString alloc] initWithString:[[elements objectAtIndex:5] content]] 
            isEqualToString:@"The attorney ID that you entered was invalid."]) {
        NSLog(@"%@ is not a valid attorney id.", theId);
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mma"];
        NSString *eventTime = [dateFormat stringFromDate:[NSDate date]];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *dateKey = [dateFormat stringFromDate:[NSDate date]];
        
        // Create an error event to populate the table
        self->events=[[NSMutableDictionary alloc]initWithCapacity:1];
        NSDictionary *todaysErrorMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            @"Invalid Attorney Id", @"caseNumber",
                                            @"Invalid Attorney Id", @"plaintiffs",
                                            @"Invalid Attorney Id", @"defendants",
                                            theId, @"attorneyId",
                                            @"Invalid Attorney Id", @"setting",
                                            @"See CourtClerk.org for more Information", @"location",
                                            eventTime, @"timeDate",
                                            [NSNumber numberWithBool:YES], @"active", nil];
        NSLog(@"The invalid-Id error event:%@", todaysErrorMessage);
        NSArray *arrayOfOneEvent=[[NSArray alloc]initWithObjects:todaysErrorMessage, nil];
        
        [self->events setObject:arrayOfOneEvent forKey:dateKey];
        return [[NSString alloc] initWithFormat:@"%@ is not a valid attorney id.", theId];
    }
        
    // Extract and store attorney name.
    NSString *attorneyName = [[NSString alloc] initWithString: [[elements objectAtIndex:7] content]];
    [self parseAttorneyName:attorneyName];

    // create 'warning' event for valid attorney id with no scheduled cases.
    if ([[[NSString alloc] initWithString:[[elements objectAtIndex:15] content]] isEqualToString:@"No schedules were found for the specified attorney."] ) {
        NSLog(@"No active court dates listed on Clerk's site for %@", theId);
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mma"];
        NSString *eventTime = [dateFormat stringFromDate:[NSDate date]];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *dateKey = [dateFormat stringFromDate:[NSDate date]];
        
        self->events=[[NSMutableDictionary alloc]initWithCapacity:1];
        NSDictionary *todaysWarningMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                        [NSNumber numberWithBool:YES], @"active",
                        theId, @"attorneyId",
                        @"No Court Dates Scheduled", @"caseNumber",
                        @"No Court Dates Scheduled", @"plaintiffs",
                        @"No Court Dates Scheduled", @"defendants",
                        @"No Court Dates Scheduled", @"setting",
                        @"See CourtClerk.org for more Information", @"location",
                        eventTime,@"timeDate", nil];
        NSLog(@"the no-schedule error event:%@", todaysWarningMessage);
        NSArray *arrayOfOneEvent=[[NSArray alloc]initWithObjects:todaysWarningMessage, nil];
        
        [self->events setObject:arrayOfOneEvent forKey:dateKey];
        return @"No active court dates listed on Clerk's site.";
    }
        
    // Create a subarray of just the event elements
    NSArray *eventElements = [elements subarrayWithRange:NSMakeRange(16, [elements count]-16)];

    //    The following block loops through the elements and 
    //    gangs them into an event dictionary and then adds the dictionary to a mutable array.
    //     the mutable array is stored in an mutable dictionary.
    self->events=[[NSMutableDictionary alloc]initWithCapacity:200];
    NSMutableDictionary *theEvent=[NSMutableDictionary dictionaryWithCapacity:6 ];
    NSDate *theDateTime;
    NSString *tempDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm a"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    NSLog(@"This should be the local time: %@", [NSDate date]);
    
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
            case 10:{
                // NSLog(@"The caption: %@", [element content]);
                [theEvent setObject:[[element content]
                                     stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                     forKey:@"caption"];
                NSString *plaintiffs = [[NSString alloc] initWithString:[self extractPlaintiffsFromCaption:[element content]]];
                NSString *defendants = [[NSString alloc] initWithString:[self extractDefendantsFromCaption:[element content]]];
                [theEvent setObject:plaintiffs forKey:@"plaintiffs"];
                [theEvent setObject:defendants forKey:@"defendants"];            
                break;}
            case 13:
                //                NSLog(@"The active: %@", [element content]);
                if ([[element content] isEqualToString:@"A"]) {
//                    NSLog(@"active");
                    [theEvent setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
                }else {
//                    NSLog(@"inactive");
                    [theEvent setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
                }
                break;
            case 16:
                //                NSLog(@"The location: %@", [element content]);
                [theEvent setObject:[element content] forKey:@"location"];
                break;
            case 19:{
                // NSLog(@"The setting: %@\n*** New Event ***", [element content]);
                [theEvent setObject:[element content] forKey:@"setting"];
                [theEvent setObject:theId forKey:@"attorneyId"];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                NSString *dateKey = [dateFormat stringFromDate:[theEvent objectForKey:@"timeDate"]];
                
                NSLog(@"The dateKey:%@.\tThe event timeDate: %@\tThe event: %@", dateKey,[theEvent objectForKey:@"timeDate"], theEvent);
                NSMutableArray *arrayOfEvents;        
            
                if ([self->events objectForKey:dateKey]) {
                    // If there is is an existing dictionary entry get the existing array.
                    arrayOfEvents=[[NSMutableArray alloc]initWithArray:
                                   [self->events objectForKey:dateKey]];
                    // Add the current event to the existing array
                    [arrayOfEvents addObject:[theEvent copy]];
                    NSLog(@"Added an event to an existing array of events.");
                }else {
                    arrayOfEvents = [[NSMutableArray alloc] initWithObjects:theEvent, nil];
                    NSLog(@"Created a new array to hold an event for %@.",dateKey);
                }
                // add the array of events for that date to self->events              
                [self->events setObject:[arrayOfEvents copy] forKey:dateKey];
                [arrayOfEvents removeAllObjects];

                counter = -5;  // reset the counter for parsing the next set of event elements.
                break;}
            default:
//                NSLog(@"Pass: %@", [element content]);
                break;
        } //end of switch
        counter++;
    }//end of for loop
    if ([self storeScheduleDictionary:self]) {
        NSLog(@"events dictionary was successfully stored.");
    } ;
    NSLog(@"Here is the schedule for %@.  \nBar number %@.  \nThere are %d settings.",attorneyName, theId, [self->events count] );
//    NSLog(@"The Events from getSched func: %@", theEvents);
    return @"success";
}


- (NSString *)extractPlaintiffsFromCaption:(NSString *)theCaption{
//    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    NSRange vsPos = [theCaption rangeOfString:@"vs."];    
//    NSLog(@"nsrange location: %u and length: %u", vsPos.location,vsPos.length);
	if (vsPos.location == 0){
		return @"sealed";
	}
    NSRange plaintiffRange; 
    plaintiffRange.location=0;
    plaintiffRange.length=vsPos.location-1;
//    [NSRangeFromString(@"0,%d",vsPos.length);
    NSString *plaintiffs = [[theCaption substringWithRange:plaintiffRange]stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
;
//    NSLog(@"Plaintiffs: %@",plaintiffs);
    return plaintiffs;
}

- (NSString *)extractDefendantsFromCaption:(NSString *)theCaption{
//    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    NSRange vsPos = [theCaption rangeOfString:@"vs."];
	if (vsPos.location == 0){
		return @"sealed";
	}
//    NSLog(@"nsrange location: %u and length: %u", vsPos.location,vsPos.length);
    NSRange defendantRange; 
    defendantRange.location = vsPos.location + vsPos.length + 1;
    defendantRange.length = [theCaption length] - (vsPos.location + vsPos.length)-1;
    
    NSString *defendants = [[theCaption substringWithRange:defendantRange] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSLog(@"Defendants: %@",defendants);
    return defendants;
}

- (NSString *)getHTMLScheduleForattorneyId:(NSString *)theId
{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    NSString *theUrl = [[NSString alloc] initWithFormat:@"http://www.courtclerk.org/attorney_schedule_list_print.asp?court_party_id=%@", self->attorneyId];
    //    NSLog(@"this is the url:%@", theUrl);
    NSString *html= [NSString stringWithContentsOfURL:[NSURL URLWithString: theUrl] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"this is the html:%@", html)
    return html;
    }

- (BOOL)storeScheduleDictionary:(id)sender {
    // this method must be rewritten to allow saving of a separate attorney Id schedules.  Specifically it should take the dictionary of events and the attorney id as parameters and store based on them.  There may come a time when self->events ≠ the attorney's calendar.  self->events may contain more event than just the attorney's.
    
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                            NSDocumentDirectory,
                            NSUserDomainMask, YES)
                            objectAtIndex: 0];
	NSString *scheduleFile = [docDir stringByAppendingPathComponent:
							[[NSString alloc] initWithFormat:@"%@-schedule.txt",self->attorneyId]];
	if  (![[NSFileManager defaultManager] fileExistsAtPath:scheduleFile]) {
		[[NSFileManager defaultManager]
         createFileAtPath:scheduleFile contents:nil attributes:nil];
	}
    if ([self->events writeToFile:scheduleFile atomically:YES]) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setValue:[NSDate date] forKey:@"scheduleVintage"];
        NSLog(@"Just wrote the events dictionary to file.");
        return YES;
    }
    return NO;
}

- (BOOL)retrieveScheduleDictionary:(id)sender {
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                            NSDocumentDirectory,
                            NSUserDomainMask, YES)
                            objectAtIndex: 0];
	NSString *scheduleFile = [docDir stringByAppendingPathComponent:
                            @"schedule.txt"];
	if  ([[NSFileManager defaultManager] fileExistsAtPath:scheduleFile]) {
        self->events=[[NSMutableDictionary alloc]
                      initWithContentsOfFile:scheduleFile];
//        NSLog(@"Here is self->events after retreival from file:\n%@",self->events);
        return YES;
	}
    return NO;
}

-(BOOL)isScheduleStale:(NSString *)theId{
    NSLog(@"In this method: %@", NSStringFromSelector(_cmd));
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDate *vintage = [userDefaults valueForKey:@"scheduleVintage"];
    NSLog(@"The vintage of the schedule on file is %@.", vintage);

    // if there is no vintage, return true.
    if (!vintage) {
        NSLog(@"The vintage (%@) is nil, nul, empty.", vintage);
    }
    // if the vintage is within 90 minutes, return false.
    if ([vintage timeIntervalSinceNow] < 90 ) {
        NSLog(@"The vintage (%@) is more than 90 minutes ago.", vintage);
    }else {
        NSLog(@"The vintage (%@) is less than 90 minutes ago.",vintage);
    }
    
    // if the vintage is after 4:00 today, return false.
    // today + 16 hours.
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    NSDateComponents *todayComps = [calendar components:unitFlags fromDate:[NSDate date]];
    [todayComps setHour:0];
    [todayComps setMinute:0];
    [todayComps setSecond:0];
    NSDate *todayDate = [calendar dateFromComponents:todayComps];    
    NSLog(@"This should be today's date with no time or at the first instant of the day: %@",todayDate);
    
    NSDate *todayAt4 = [NSDate dateWithTimeInterval:57600 sinceDate:todayDate];
    NSLog(@"This should be today's date at 4:00: %@",todayAt4);
    if ([vintage timeIntervalSinceDate:todayAt4] > 0) {
        NSLog(@"The vintage (%@) is after 4:00 today.", vintage);
    }

    // if now is before 8:00am today and the vintage is after 4:00 yesterday, return false.
    // today + 16 hours.
    
    NSDate *todayAt8 = [NSDate dateWithTimeInterval:28800 sinceDate:todayDate];
    NSLog(@"This should be today's at 8:00am: %@",todayAt8);
    NSDate *yesterdayAt4 = [NSDate dateWithTimeInterval:-28800 sinceDate:todayDate];
    NSLog(@"This should be yesterday at 4:00pm: %@",yesterdayAt4);
    if ([[NSDate date] timeIntervalSinceDate:todayAt8] < 0 && 
        [vintage timeIntervalSinceDate:yesterdayAt4] > 0 ) {
        NSLog(@"The vintage (%@) is after 4:00 yesterday and before 8:00 today.", vintage);
    }

    // if now is a weekend and the vintage is after 4:00 friday, return false.
    return NO;
    NSLog(@"No condition was matched.");
}

// snippet from BDDateTransformer.m //
- (id)transformedValue:(NSDate *)date
{
    // Initialize the formatter.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++)
    {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate *referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
        
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
        {
            // Tomorrow
            return [NSString stringWithString:@"Tomorrow"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
        {
            // Today's time (a la iPhone Mail)
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            return [formatter stringFromDate:date];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
        {
            // Today
            return [NSString stringWithString:@"Yesterday"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
        {
            // Day of the week
            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
            return day;
        }
    }
    
    // It's not in those eight days.
    NSString *defaultDate = [formatter stringFromDate:date];
    return defaultDate;
}
                        
                        
@end

//
//  MapNotesAppDelegate.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "MapNotesAppDelegate.h"
#import "RootViewController.h"
#import "NotesViewController.h"
#import "LocationController.h"


@implementation MapNotesAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize sortOrder, sortAscending, infoDisplay;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	// Override point for customization after app launch    
	application.statusBarStyle = UIStatusBarStyleBlackOpaque;
	//application.statusBarStyle = UIStatusBarStyleBlackTranslucent;
	
	// Set the background of the app
	UIView *backgroundView = [[UIView alloc] initWithFrame:window.frame];
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_app_bkgnd.png"]];
	[window addSubview:backgroundView];
	[backgroundView release];
	
	//[self initLocationManager];
	//[[LocationController sharedInstance] init];
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
	}
	
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStyleGrouped];
	rootViewController.managedObjectContext = context;

	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

	//aNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	aNavigationController.navigationBar.tintColor = [UIColor colorWithRed:(129.0/255.0) green:(137.0/255.0) blue:(149.0/255.0) alpha:1.0];
	//aNavigationController.navigationBar.tintColor = [UIColor redColor];
	self.navigationController = aNavigationController;	

	// Push notes view controller since we always start at the Notes list level
	//NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
	//notesViewController.managedObjectContext = managedObjectContext;
	//[self.navigationController pushViewController:notesViewController animated:NO];
	
	[window addSubview:[navigationController view]];
    
	// Show the Quick Add view if loading the notes controller with app start
	//[notesViewController showQuickAddView:NO];
	[rootViewController showAllNotesWithQuickAdd];

	sortOrder = @"dateCreated";
	sortAscending = NO;
	infoDisplay = 0;
	
	[window makeKeyAndVisible];
	
	//[notesViewController release];
	[rootViewController release];
	[aNavigationController release];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"MapNotes.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[sortOrder release];
	
	[window release];
	[super dealloc];
}


@end


//
//  MapNotesAppDelegate.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#define UIAppDelegate \
((MapNotesAppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>

@class RootViewController;
@class QuickAddViewController;

@interface MapNotesAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSString *sortOrder;
	BOOL sortAscending;
	NSInteger infoDisplay;
}

- (IBAction)saveAction:sender;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) NSString *sortOrder;
@property (nonatomic, assign) BOOL sortAscending;
@property (nonatomic, assign) NSInteger infoDisplay;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


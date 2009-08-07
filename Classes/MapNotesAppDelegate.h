//
//  MapNotesAppDelegate.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright Local Matters, Inc. 2009. All rights reserved.
//

#define UIAppDelegate \
((MapNotesAppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RootViewController;
@class QuickAddViewController;

@interface MapNotesAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	CLLocationManager *locationManager;

    UIWindow *window;
    UINavigationController *navigationController;
}

- (IBAction)saveAction:sender;
- (void)updateCurrentLocation;
- (void)initLocationManager;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


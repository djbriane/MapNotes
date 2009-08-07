//
//  LaunchViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

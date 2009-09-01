//
//  GroupsViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/28/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupNameViewController.h"

@class Group;
@class Note;

@interface GroupsViewController : UITableViewController <UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, GroupNameDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	Note *selectedNote;	
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Note *selectedNote;

- (void)editTitle:(Group *)group;
- (void)addToGroup:(Group *)group withNote:(Note *)note;

@end

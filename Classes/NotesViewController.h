//
//  NotesViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright Local Matters, Inc. 2009. All rights reserved.
//

#import "QuickAddViewController.h"

@class QuickAddViewController;
@class Note;

@interface NotesViewController : UITableViewController <QuickAddViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	//NoteDetailController *noteDetailController;
	NSManagedObject *selectedGroup;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *selectedGroup;

//@property (nonatomic, retain) NoteDetailController *noteDetailController;

- (void)showQuickAddView:(BOOL)animated;
- (void)pushNoteDetailViewController:(Note *)note editing:(BOOL)editing animated:(BOOL)animated;


@end

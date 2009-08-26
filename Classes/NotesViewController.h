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

@interface NotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QuickAddViewControllerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *selectedGroup;
	NSMutableArray *notesArray;
	
	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *myTableView;

	NSString *sortOrder;
	BOOL sortAscending;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *selectedGroup;
@property (nonatomic, retain) NSMutableArray *notesArray;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;

@property (nonatomic, retain) NSString *sortOrder;
@property (nonatomic, assign) BOOL sortAscending;

//@property (nonatomic, retain) NoteDetailController *noteDetailController;

- (void)fetchExistingNotes;
- (void)sortExistingNotes;
- (void)showQuickAddView:(BOOL)animated;
- (void)changeSortOrder:(id)sender;
- (void)pushNoteDetailViewController:(Note *)note editing:(BOOL)editing animated:(BOOL)animated;


@end

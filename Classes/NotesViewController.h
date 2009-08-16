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

@interface NotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QuickAddViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	CLLocationManager *locationManager;
	
	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *myTableView;
	
	//NoteDetailController *noteDetailController;
	NSManagedObject *selectedGroup;
	NSString *sortOrder;
	BOOL sortAscending;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *selectedGroup;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSString *sortOrder;
@property (nonatomic, assign) BOOL sortAscending;

//@property (nonatomic, retain) NoteDetailController *noteDetailController;

- (void)showQuickAddView:(BOOL)animated;
- (void)changeSortOrder:(id)sender;
- (void)pushNoteDetailViewController:(Note *)note editing:(BOOL)editing animated:(BOOL)animated;


@end

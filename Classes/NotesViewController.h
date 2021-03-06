//
//  NotesViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "QuickAddViewController.h"

#define kFilename @"prefs.plist"

@class QuickAddViewController;
@class Note;
@class Group;

@interface NotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QuickAddViewControllerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Group *selectedGroup;
	NSMutableArray *notesArray;
	NSMutableDictionary *sectionedDictionaryByFirstLetter;
	NSArray *keys;
	
	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *myTableView;
	IBOutlet UISegmentedControl *sortControl;
	IBOutlet UIBarButtonItem *mapViewButton;

	//NSString *sortOrder;
	//BOOL sortAscending;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Group *selectedGroup;
@property (nonatomic, retain) NSMutableArray *notesArray;
@property (nonatomic, retain) NSMutableDictionary *sectionedDictionaryByFirstLetter;
@property (nonatomic, retain) NSArray *keys;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sortControl;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapViewButton;

//@property (nonatomic, retain) NSString *sortOrder;
//@property (nonatomic, assign) BOOL sortAscending;

//@property (nonatomic, retain) NoteDetailController *noteDetailController;

- (void)fetchExistingNotes;
- (void)sortExistingNotes:(BOOL)animated ;
- (NSSortDescriptor *)getCurrentSortDescriptor;
- (void)showQuickAddView:(BOOL)animated;
- (void)changeSortOrder:(id)sender;
- (void)reloadSections;
- (void)pushNoteDetailViewController:(Note *)note editing:(BOOL)editing animated:(BOOL)animated;
- (IBAction)showMapView:(id)sender;

@end

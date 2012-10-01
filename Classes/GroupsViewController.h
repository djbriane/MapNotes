//
//  GroupsViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/28/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#import "GroupNameViewController.h"

@class Group;
@class Note;

@interface GroupsViewController : UITableViewController <UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, GroupNameDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	Note *selectedNote;
	
	UIView *tableFooterView;
	UIButton *newGroupButton;
	UITableViewCellAccessoryType accessoryType;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Note *selectedNote;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIButton *newGroupButton;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;


- (void)editTitle:(Group *)group;
- (void)addNewGroup;
- (void)addToGroup:(Group *)group withNote:(Note *)note;
- (void)showAllNotesWithGroup:(Group *)group;
- (IBAction)addNewGroup:(id)sender;

@end

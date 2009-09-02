//
//  LaunchViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "NotesViewController.h"

@implementation RootViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	// add 'Edit' button to Nav Bar (left)
	self.navigationItem.leftBarButtonItem = [self editButtonItem];

	// add 'All Notes' button to Nav Bar (right)
	// Obtain a UIButton object and set its background to the UIImage object
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[UIImage imageNamed:@"btn_all-notes-blank.png"] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize: 13];
	//[button setImage:[UIImage imageNamed:@"btn_all-notes.png"] forState:UIControlStateNormal];
	[button setTitle:@"All Notes" forState:UIControlStateNormal];
	button.bounds = CGRectMake(0,0,78, 32);
	[button addTarget:self action:@selector(showAllNotes) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *allNotesItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	
	//UIImage *allNotesImage = [UIImage imageNamed:@"btn_all-notes.png"];
	//UIButton *allNotesView = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 78, 32)];
	//[allNotesView setBackgroundImage:allNotesImage forState:UIControlStateNormal];
	
	// Obtain a UIBarButtonItem object and initialize it with the UIButton object
	//UIBarButtonItem *allNotesItem = [[UIBarButtonItem alloc] initWithCustomView:allNotesView];
	//[allNotesItem addTarget:self action:@selector(showAllNotes) forControlEvents:UIControlEventTouchUpInside];
	
	//newAllNotesItem.title = @"All Notes";
	self.navigationItem.rightBarButtonItem = allNotesItem;

	[allNotesItem release];
}

- (void)showAllNotes {
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
	notesViewController.managedObjectContext = managedObjectContext;

	[self.navigationController pushViewController:notesViewController animated:YES];
	[notesViewController release];
}

- (void)showAllNotesWithQuickAdd {
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
	notesViewController.managedObjectContext = managedObjectContext;

	[self.navigationController pushViewController:notesViewController animated:NO];
	// Show the Quick Add view if loading the notes controller with app start
	[notesViewController showQuickAddView:NO];

	[notesViewController release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[[self.navigationController navigationBar] performSelectorInBackground:@selector(setBackgroundImage:) withObject:image];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_group-header.png"]];;
}

- (void)viewWillDisappear:(BOOL)animated {
	// TODO: This is causing a leak that needs to be fixed
	//[[self.navigationController navigationBar] performSelectorInBackground:@selector(clearBackgroundImage) withObject:nil];
}


- (void)dealloc {
    [super dealloc];
}

@end

//
//  LaunchViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "NotesViewController.h"
#import "StringHelper.h"
#import "Beacon.h"

@implementation RootViewController

@synthesize groupsTitleView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// add 'Edit' button to Nav Bar (left)
	self.navigationItem.leftBarButtonItem = [self editButtonItem];

	self.tableView.allowsSelectionDuringEditing = YES;
	accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	[self showAllNotesItem:NO];
}

- (void)showAllNotesItem:(BOOL)animated {
	// add 'All Notes' button to Nav Bar (right)
	// Obtain a UIButton object and set its background to the UIImage object
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[UIImage imageNamed:@"btn_all-notes-blank.png"] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize: 13];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(-2.0, -3.0, 0, 0)];
	
	//[button setImage:[UIImage imageNamed:@"btn_all-notes.png"] forState:UIControlStateNormal];
	[button setTitle:@"All Notes" forState:UIControlStateNormal];
	button.bounds = CGRectMake(0,0,80, 30);
	[button addTarget:self action:@selector(showAllNotes) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *allNotesItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	[self.navigationItem setRightBarButtonItem:allNotesItem animated:animated];
	[allNotesItem release];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
	
	// Hide the 'All Notes' navigation bar button when in edit mode
	if (editing) {
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
	} else {
		[self showAllNotesItem:YES];	
	}
}

- (void)showAllNotes {
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
	notesViewController.managedObjectContext = managedObjectContext;

	[self.navigationController pushViewController:notesViewController animated:YES];
	[notesViewController release];
	[[Beacon shared] startSubBeaconWithName:@"Groups - Show All Notes" timeSession:NO];
}

- (void)showAllNotesWithQuickAdd {
	self.navigationItem.title = @"Groups";
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
	/*
	UIView *titleWithIcon = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 22.0)];
	UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 0.0, 23.0, 18.0)];
	icon.image = [UIImage imageNamed:@"btn_all-notes-blank.png"];
	[titleWithIcon addSubview:icon];
	[icon release];
	
	NSString *titleText = @"Groups";
	UILabel *mainLabel = [titleText RAD_newSizedCellLabelWithSystemFontOfSize:18.0 withBold:YES];
	[titleWithIcon addSubview:mainLabel];
	self.navigationItem.title = nil;
	[self.navigationItem.titleView addSubview:titleWithIcon];
	[titleWithIcon release];
	 */
	/*
	if (groupsTitleView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"GroupsTitle" owner:self options:nil];
	}
	self.navigationItem.titleView = groupsTitleView;
	*/
	//self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_group-header.png"]];;
}

- (void)viewWillDisappear:(BOOL)animated {
	// TODO: This is causing a leak that needs to be fixed
	//[[self.navigationController navigationBar] performSelectorInBackground:@selector(clearBackgroundImage) withObject:nil];
}


- (void)dealloc {
    [super dealloc];
}

@end

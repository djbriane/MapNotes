//
//  NotesViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright Local Matters, Inc. 2009. All rights reserved.
//

#import "NotesViewController.h"
#import "MapNotesAppDelegate.h"
#import "NoteDetailController.h"
#import "NotesMapViewController.h"
#import "CLLocation+DistanceComparison.h"
#import "LocationController.h"
#import "Note.h"
#import "Group.h"

#define kPhotoViewTag		11
#define kTitleViewTag		12
#define kDetailsViewTag		13

@implementation NotesViewController

@synthesize managedObjectContext, selectedGroup, notesArray;
@synthesize myTableView, toolbar;
@synthesize sortControl, mapViewButton;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.myTableView.rowHeight = 56;
	self.myTableView.backgroundColor = [UIColor clearColor];
	
    /*
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																			   target:self 
																			   action:@selector(showQuickAddView:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	 */
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[UIImage imageNamed:@"btn_plus-orange.png"] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize: 13];
	//[button setTitleEdgeInsets:UIEdgeInsetsMake(-2.0, -3.0, 0, 0)];
	
	//[button setImage:[UIImage imageNamed:@"btn_all-notes.png"] forState:UIControlStateNormal];
	//[button setTitle:@"All Notes" forState:UIControlStateNormal];
	button.bounds = CGRectMake(0,0,33, 30);
	[button addTarget:self action:@selector(showQuickAddView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *quickAddItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	self.navigationItem.rightBarButtonItem = quickAddItem;
	
	[quickAddItem release];
	
	
	if (selectedGroup == nil) {
		self.navigationItem.title = @"All Notes";
	} else {
		self.navigationItem.title = selectedGroup.name;
	}
	
	NSLog(@"Sort Order (load): %@", UIAppDelegate.sortOrder);
	
	[sortControl addTarget:self action:@selector(changeSortOrder:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.backBarButtonItem = nil;

	// Default sorting to date created descending (most recent at top)
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSString *sortOrderPref = [defaults stringForKey:@"sort_order"];
	NSLog(@"Sort Order (appear): %@", UIAppDelegate.sortOrder);
	//self.sortOrder = [defaults objectForKey:@"sort_order"];

	if ([UIAppDelegate.sortOrder isEqual:@"title"]) {
		// A - Z
		[sortControl setSelectedSegmentIndex:1];
	} else if ([UIAppDelegate.sortOrder isEqual:@"geoDistance"]) {
		// Distance
		[sortControl setSelectedSegmentIndex:2];
	} else {
		// Date Created
		[sortControl setSelectedSegmentIndex:0];
	}

	//sortOrder = @"dateCreated";
	
	// disable distance sort if no location
	CLLocation *location = [[LocationController sharedInstance] currentLocation];
	if (!location) {
		[sortControl setEnabled:NO forSegmentAtIndex:2];
	} else {
		[sortControl setEnabled:YES forSegmentAtIndex:2];
	}
	
	[self fetchExistingNotes];
    [self.myTableView reloadData];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	// save current sort as default
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//[defaults setObject:self.sortOrder forKey:@"sort_order"];
	
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (NSSortDescriptor *)getCurrentSortDescriptor {
	CLLocation *location = [[LocationController sharedInstance] currentLocation];

	if ([UIAppDelegate.sortOrder length] == 0) {
		UIAppDelegate.sortOrder = @"dateCreated";
	}
	if (!location && UIAppDelegate.sortOrder == @"geoDistance") {
		// set the sort order to date created since we don't have a location
		UIAppDelegate.sortOrder == @"dateCreated";
	}
	
	// Set self's events array to the mutable array, then clean up.
	NSSortDescriptor *sortDescriptor;
	if (UIAppDelegate.sortOrder == @"geoDistance") {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES selector:@selector(compareToLocation:)];
	} else {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:UIAppDelegate.sortOrder ascending:UIAppDelegate.sortAscending];
	}
	return sortDescriptor;
}

- (void)fetchExistingNotes {
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Order the notes by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortOrder ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	// set up a Predicate if a group has been selected
	if (self.selectedGroup != nil) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group = %@)", self.selectedGroup];
		[request setPredicate: pred];
	}
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"%@:%s Error fetching context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setNotesArray:mutableFetchResults];	
	[mutableFetchResults release];
	[request release];
	
	// sort the notes
	[self sortExistingNotes:NO];
}

- (void)sortExistingNotes:(BOOL)animated {
	//CLLocation *location = [[LocationController sharedInstance] currentLocation];
	if ([notesArray count] != 0) {
		/*
		if (!location && self.sortOrder == @"geoDistance") {
			// set the sort order to date created since we don't have a location
			self.sortOrder == @"dateCreated";
		}
		
		// Set self's events array to the mutable array, then clean up.
		NSSortDescriptor *sortDescriptor;
		if (self.sortOrder == @"geoDistance") {
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES selector:@selector(compareToLocation:)];
		} else {
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortOrder ascending:self.sortAscending];
		}	*/
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[self getCurrentSortDescriptor], nil];
		NSMutableArray *sortedNotesArray = [[self.notesArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
		[self setNotesArray:sortedNotesArray];
		
		//[sortDescriptor release];
		[sortDescriptors release];
		//[sortedNotesArray release];
		
		//[self.myTableView reloadData];
		if (animated) {
			NSIndexPath *indPath = [NSIndexPath indexPathForRow:0 inSection:0];
			[self.myTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
			[NSTimer scheduledTimerWithTimeInterval:.02 target:self 
										   selector:@selector(reloadSections) 
										   userInfo:nil 
											repeats:NO];
		}
	}
}

- (void)reloadSections {
	[self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)showQuickAddView:(BOOL)animated {
	// Set up QuickAdd VC for future use
	//QuickAddViewController *aQuickAddViewController = [[QuickAddViewController alloc] initWithNibName:nil bundle:nil];
	QuickAddViewController *aQuickAddViewController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddView" bundle:nil];
	aQuickAddViewController.managedObjectContext = self.managedObjectContext;
	if (selectedGroup != nil) {
		aQuickAddViewController.selectedGroup = selectedGroup;
	}
	aQuickAddViewController.delegate = self;
	//[aQuickAddViewController.view setFrame: [[UIScreen mainScreen] bounds]];
	//[aQuickAddViewController.view setFrame:[[UIScreen mainScreen] applicationFrame]];
	//[aQuickAddViewController.view setFrame: [[UIScreen mainScreen] bounds]];

	//[UIApplication sharedApplication].statusBarHidden = YES;
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[self presentModalViewController:aQuickAddViewController animated:animated];

	[aQuickAddViewController release];
}

- (void)pushNoteDetailViewController:(Note *)note editing:(BOOL)editing animated:(BOOL)animated {
	NoteDetailController *noteDetailController = [[NoteDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	noteDetailController.view.backgroundColor = [UIColor clearColor];
	noteDetailController.selectedNote = note;
    [self.navigationController pushViewController:noteDetailController animated:animated];
	[noteDetailController setEditing:editing animated:NO];
	[noteDetailController release];
}

- (void)changeSortOrder:(id)sender {
	UISegmentedControl* segCtl = sender;
	NSInteger selectedIndex = [segCtl selectedSegmentIndex];
	
	switch (selectedIndex) {
		case 1:
			// sort by alpha
			UIAppDelegate.sortOrder = @"title";
			UIAppDelegate.sortAscending = YES;
			break;
		case 2:
			if ([[LocationController sharedInstance] currentLocation]) {
				// sort by distance
				UIAppDelegate.sortOrder = @"geoDistance";
				UIAppDelegate.sortAscending = YES;
				break;			
			}
		default:
			// default to sort by date
			UIAppDelegate.sortOrder = @"dateCreated";
			UIAppDelegate.sortAscending = NO;
			break;
	}
	
	// invalidate and re-run the fetch with the new sort descriptor
	[self sortExistingNotes:YES];
}

- (IBAction)showMapView:(id)sender {
	NotesMapViewController *aNotesMapViewController = [[NotesMapViewController alloc] initWithNibName:@"NotesMapView" bundle:nil];
	//aNotesMapViewController.view.backgroundColor = [UIColor clearColor];
	//aNotesMapViewController.notesArray = [[NSMutableArray alloc] initWithArray:notesArray copyItems:YES];
	aNotesMapViewController.notesArray = [NSMutableArray arrayWithArray:notesArray];
	aNotesMapViewController.selectedGroup = selectedGroup;
	
	// change the title of the back button 
	UIBarButtonItem *backBar = [[UIBarButtonItem alloc] initWithTitle:@"List View" style:UIBarButtonItemStyleDone target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBar;
	[backBar release];
	
    [self.navigationController pushViewController:aNotesMapViewController animated:YES];
	[aNotesMapViewController release];
}

#pragma mark -
#pragma mark Quick Add View Controller Methods

- (void)quickAddViewController:(QuickAddViewController *)controller 
				   showNewNote:(Note *)note {
	[self pushNoteDetailViewController:note	editing:YES animated:NO];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// disable sort and map view, show message
	if ([self.notesArray count] == 0) {
		// Date Created
		[self.sortControl setEnabled:NO forSegmentAtIndex:0];
		// A - Z
		[self.sortControl setEnabled:NO forSegmentAtIndex:1];
		// Distance
		[self.sortControl setEnabled:NO forSegmentAtIndex:2];
		[self.mapViewButton setEnabled:NO];
	} else {
		// Date Created
		[self.sortControl setEnabled:YES forSegmentAtIndex:0];
		// A-Z
		[self.sortControl setEnabled:YES forSegmentAtIndex:1];
		// Distance (only if we have a valid location)
		if ([[LocationController sharedInstance] currentLocation]) {
			[self.sortControl setEnabled:YES forSegmentAtIndex:2];
		}
		[self.mapViewButton setEnabled:YES];
	}
	
	return [notesArray count];

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *titleLabel;
	UILabel *detailsLabel;
	UIImageView *photoView;
    static NSString *CellIdentifier = @"NoteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// set up custom cell
		photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(6, 4, 48, 48)] autorelease];
		[cell.contentView addSubview:photoView];
		photoView.tag = kPhotoViewTag;
		//photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
		
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(62, 6, 237, 24)] autorelease];
		[cell.contentView addSubview:titleLabel];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.tag = kTitleViewTag;
		
		detailsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(62, 28, 237, 21)] autorelease];
		[cell.contentView addSubview:detailsLabel];
		detailsLabel.textAlignment = UITextAlignmentLeft;
		detailsLabel.highlightedTextColor = [UIColor whiteColor];
		detailsLabel.font = [UIFont systemFontOfSize:14];
		detailsLabel.textColor = [UIColor grayColor];
		detailsLabel.tag = kDetailsViewTag;
		
	}
    
	// Configure the cell.
	Note *note = (Note *)[notesArray objectAtIndex:indexPath.row];
	
	// if no image is set, adjust the frame
	//if (note.thumbnail == nil) {
	//	titleLabel.frame = CGRectMake(6, 6, 293, 24);
	//	detailsLabel.frame = CGRectMake(6, 28, 293, 21);
	//}
	
	titleLabel = (UILabel *)[cell viewWithTag:kTitleViewTag];
	if ([note.title length] != 0) {
		titleLabel.text = note.title;
		titleLabel.textColor = [UIColor blackColor];
	} else {
		//titleLabel.font = [UIFont italicSystemFontOfSize:16];
		titleLabel.textColor = [UIColor grayColor];
		titleLabel.text = @"No Title";
	}

	photoView = (UIImageView *)[cell viewWithTag:kPhotoViewTag];
	if (note.thumbnail != nil) {
		photoView.image = note.thumbnail;
	} else {
		photoView.image = [UIImage imageNamed:@"img_no-photo_thumb.png"];
	}
	//[cell.imageView.image drawInRect:CGRectMake(4, 4, 48, 48)];

	detailsLabel = (UILabel *)[cell viewWithTag:kDetailsViewTag];
	CLLocation *location = [[LocationController sharedInstance] currentLocation];
	NSString *geoLabel;
	NSString *dateLabel;
	if (!location || !note.location) {
		geoLabel = nil;
	} else {
		geoLabel = [NSString stringWithFormat:@"%1.1f mi", ([note.location getDistanceFrom:location] * 0.000621371192)];
	}
	
	// A date formatter for the creation/modified dates.
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
	dateLabel = [dateFormatter stringFromDate:[note dateCreated]];

	if (UIAppDelegate.sortOrder == @"geoDistance") {
		// show distance if sorted by distance
		if (geoLabel == nil) {
			return cell;
		}
		detailsLabel.text = geoLabel;
	} else if (UIAppDelegate.sortOrder == @"dateCreated") {
		// return the created date if its the first section
		detailsLabel.text = dateLabel;
	} else {
		if (geoLabel == nil) {
			detailsLabel.text = dateLabel;
		} else {
			detailsLabel.text = [NSString stringWithFormat:@"%@ - %@", dateLabel, geoLabel];
		}
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected object to the new view controller.
    /// ...
	
	Note *note = (Note *)[notesArray objectAtIndex:indexPath.row];
	[self pushNoteDetailViewController:note editing:NO animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
											forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObject *noteToDelete = [notesArray objectAtIndex:indexPath.row];

		[managedObjectContext deleteObject:noteToDelete];		
		[notesArray removeObjectAtIndex:indexPath.row];

		// Save the context.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error...
			NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


/*
// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}
*/		
/*
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }

	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Add a NSPedicate for group support
	// NSPredicate *pred = [NSPredicate predicateWithFormat:@"group = %@", self.selectedGroup];
	// [fetchRequest setPredicate:pred];
	// [pred release];
		
	// Change the sort key according to the current sort order
	NSSortDescriptor *sortDescriptor;
	if (self.sortOrder == @"geoDistance") {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:self.sortAscending selector:@selector(compareToLocation:)];
	} else {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortOrder ascending:self.sortAscending];
	}	
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error fetching context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    
*/

- (void)dealloc {
	[toolbar release];
	[managedObjectContext release];
	[notesArray release];
    [super dealloc];
}


@end


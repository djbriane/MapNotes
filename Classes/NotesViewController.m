//
//  NotesViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright Local Matters, Inc. 2009. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteDetailController.h"
#import "CLLocation+DistanceComparison.h"
#import "LocationController.h"
#import "Note.h"

@implementation NotesViewController

@synthesize managedObjectContext, selectedGroup, notesArray;
@synthesize myTableView, toolbar, sortOrder, sortAscending;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Default sorting to date created descending (most recent at top)
	sortOrder = @"dateCreated";
	sortAscending = NO;
	
	// Remove the back button for now, till we get Groups implemented
	[self.navigationItem setHidesBackButton:YES animated:YES];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																			   target:self 
																			   action:@selector(showQuickAddView:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	if (selectedGroup == nil) {
		self.navigationItem.title = @"All Notes";
	}
	
	// Create the sort control as a UISegmentedControl
	UISegmentedControl *sortControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects: @"Date", @"A - Z", @"Distance", nil]];

	sortControl.segmentedControlStyle = UISegmentedControlStyleBar;
	sortControl.backgroundColor = [UIColor clearColor];
	sortControl.tintColor = [UIColor darkGrayColor];
	// default to date sort, should change this to remember sort preference
	sortControl.selectedSegmentIndex = 0;
	
	[sortControl addTarget:self action:@selector(changeSortOrder:) forControlEvents:UIControlEventValueChanged];
	
	sortControl.frame = CGRectMake(10, 6, 300,30);
	[toolbar addSubview:sortControl];
	[sortControl release];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	//[UIApplication sharedApplication].statusBarHidden = NO;
	[self fetchExistingNotes];
    [self.myTableView reloadData];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
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
}

- (void)sortExistingNotes {
	// If it's not possible to get a location, then return.
	//CLLocation *location = [locationManager location];
	CLLocation *location = [[LocationController sharedInstance] currentLocation];
	
	if (!location) {
		return;
	}
	
	// Set self's events array to the mutable array, then clean up.
	NSSortDescriptor *sortDescriptor;
	if (self.sortOrder == @"geoDistance") {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES selector:@selector(compareToLocation:)];
	} else {
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortOrder ascending:self.sortAscending];
	}	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	NSMutableArray *sortedNotesArray = [[self.notesArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
	[self setNotesArray:sortedNotesArray];
	
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedNotesArray release];
	
	//[self.myTableView reloadData];
	NSIndexPath *indPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
	[self.myTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)showQuickAddView:(BOOL)animated {
	// Set up QuickAdd VC for future use
	QuickAddViewController *aQuickAddViewController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddView" bundle:nil];
	aQuickAddViewController.managedObjectContext = self.managedObjectContext;
	aQuickAddViewController.delegate = self;
	
	[UIApplication sharedApplication].statusBarHidden = YES;
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
			self.sortOrder = @"title";
			self.sortAscending = YES;
			break;
		case 2:
			if ([[LocationController sharedInstance] currentLocation]) {
				// sort by distance
				self.sortOrder = @"geoDistance";
				self.sortAscending = YES;
				break;			
			}
		default:
			// default to sort by date
			self.sortOrder = @"dateCreated";
			self.sortAscending = NO;
			break;
	}
	
	// invalidate and re-run the fetch with the new sort descriptor
	[self sortExistingNotes];
}


#pragma mark -
#pragma mark Quick Add View Controller Methods

- (void)quickAddViewController:(QuickAddViewController *)controller 
				   showNewNote:(Note *)note {
	[self pushNoteDetailViewController:note	editing:YES animated:NO];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [notesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NoteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	Note *note = (Note *)[notesArray objectAtIndex:indexPath.row];
	
	cell.textLabel.text = note.title;
	cell.imageView.image = note.thumbnail;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	// show distance if sorted by distance
	CLLocation *location = [[LocationController sharedInstance] currentLocation];
	if (!location || !note.location) {
		return cell;
	}
	if (self.sortOrder == @"geoDistance") {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%4.1f mi", ([note.location getDistanceFrom:location] * 0.000621371192)];
	} else if (self.sortOrder == @"dateCreated") {
		// A date formatter for the creation/modified dates.
		static NSDateFormatter *dateFormatter = nil;
		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		}
		
		// return the created date if its the first section
		cell.detailTextLabel.text = [dateFormatter stringFromDate:[note dateCreated]];
		
	} else {
		cell.detailTextLabel.text = nil;
	}

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
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
	
	// TODO: Add a NSPedicate for group support
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
	[sortOrder release];
	[toolbar release];
	[managedObjectContext release];
    [super dealloc];
}


@end


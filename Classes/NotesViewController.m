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
#import "Note.h"

@implementation NotesViewController

@synthesize fetchedResultsController, managedObjectContext, selectedGroup, myTableView, toolbar, sortOrder, sortAscending, locationManager;

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
	
	//Add the toolbar as a subview to the navigation controller.
	//[self.navigationController.view addSubview:toolbar];
	//[self.view addSubview:toolbar];
	
	// If group is set, then fetch notes from that group, otherwise use fetched results controller
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error fetching context: %@", [self class], _cmd, [error localizedDescription]);
	}
}



- (void)insertNewObject {
	
	// Create a new instance of the entity managed by the fetched results controller.
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	[newManagedObject setValue:@"New Note" forKey:@"title"];
	[newManagedObject setValue:[NSDate date] forKey:@"dateCreated"];
	[newManagedObject setValue:[NSDate date] forKey:@"dateModified"];

	// Save the context.
    NSError *error;
    if (![context save:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
    }

    [self.myTableView reloadData];
}

- (void)showQuickAddView:(BOOL)animated {
	// Set up QuickAdd VC for future use
	QuickAddViewController *aQuickAddViewController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddView" bundle:nil];
	aQuickAddViewController.managedObjectContext = self.managedObjectContext;
	aQuickAddViewController.delegate = self;
	
	//[UIApplication sharedApplication].statusBarHidden = YES;
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
			if (self.locationManager.location) {
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
	self.fetchedResultsController = nil;
	self.fetchedResultsController = [self fetchedResultsController];

	[self.myTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	//[UIApplication sharedApplication].statusBarHidden = NO;
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

#pragma mark -
#pragma mark Qukck Add View Controller Methods

- (void)quickAddViewController:(QuickAddViewController *)controller 
				   showNewNote:(Note *)note {
	[self pushNoteDetailViewController:note	editing:YES animated:NO];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NoteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	Note *note = (Note *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = note.title;
	cell.imageView.image = note.thumbnail;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	// show distance if sorted by distance
	if (note.location != nil && self.locationManager.location != nil) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%4.1f mi", ([note.location getDistanceFrom:self.locationManager.location] * 0.000621371192)];
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
	
	Note *note = [[self fetchedResultsController] objectAtIndexPath:indexPath];
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
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
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

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }

    /*
	 Set up the fetched results controller.
	*/
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
		referenceLocation = self.locationManager.location;
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:self.sortAscending selector:@selector(compareToLocation:)];
		referenceLocation = nil;
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


- (void)dealloc {
	[sortOrder release];
	[toolbar release];
	[locationManager release];
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end


//
//  GroupsViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/28/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "MapNotesAppDelegate.h"
#import "GroupsViewController.h"
#import "NotesViewController.h"
#import "Group.h"
#import "Note.h"

#define kIconImageTag 1

@implementation GroupsViewController

@synthesize fetchedResultsController, managedObjectContext, selectedNote;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if (managedObjectContext == nil) {
		managedObjectContext = [((MapNotesAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext retain];
	}

	
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = [UIColor clearColor];
	//self.tableView.allowsSelectionDuringEditing = YES;
	
	self.navigationItem.title = @"Groups";

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error fetching context: %@", [self class], _cmd, [error localizedDescription]);
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[self setEditing:YES animated:NO];

	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    	
	/*
	 If editing is finished, save the managed object context.
	 */
	if (!editing) {
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}
/*
- (void)insertNewObject {
	// Create a new instance of the entity managed by the fetched results controller.
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	[newManagedObject setValue:@"New Group" forKey:@"name"];
	
	// Save the context.
    NSError *error;
    if (![context save:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
    }
	
    [self.tableView reloadData];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Note Title View Controller Methods
- (void)editTitle:(Group *)group {
	GroupNameViewController *nameController = [[GroupNameViewController alloc] initWithNibName:@"EditName" bundle:nil];
    nameController.delegate = self;
	
	// Make a new group
	//Group *group;
	if (group == nil) {
		group = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group"
													   inManagedObjectContext:managedObjectContext];
	}
	
	nameController.group = group;
    [self.navigationController pushViewController:nameController animated:YES];
	
    [nameController release];
}

- (void)addToGroup:(Group *)group withNote:(Note *)note {

	/* Might need to do this
	if (selectedNote.group != nil && selectedNote.group.name == group.name) {
		return;
	} */
	if (note != nil && note.group != nil) {
		NSLog(@"(addToGroup)Remove from Group: %@", note.group.name);
		[note.group removeNotesObject:note];
	}
	NSLog(@"(addToGroup)Add to Group: %@", group.name);
	[group addNotesObject:note];
}

- (void)groupNameViewController:(GroupNameViewController *)controller 
					didSetTitle:(Group *)group
						didSave:(BOOL)didSave {
	if (didSave == NO) {
		// delete the group before saving
		[managedObjectContext deleteObject:group];
	} else if (selectedNote != nil) {
		// add the note to the group
		[self addToGroup:group withNote:selectedNote];
	}
	
	// save the context
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error...
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// return to appropriate view
	if (didSave == YES && selectedNote != nil) {
		// return to note detail view 
		if ([self.navigationController.viewControllers objectAtIndex:2] != nil) {
			[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
		}
	} else {
		// return to list of groups
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)showAllNotesWithGroup:(Group *)group {
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
	notesViewController.managedObjectContext = managedObjectContext;
	notesViewController.selectedGroup = group;
	
	[self.navigationController pushViewController:notesViewController animated:YES];
	[notesViewController release];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
		return 0;
	} else {
		return 1;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CellIdentifier";
	static NSString *AddCellIdentifier = @"AddCellIdentifier";
	UITableViewCell *cell;
    UIImageView *icon;
	
	if (indexPath.section == 1) {
		// set up add group cell
		cell = [tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
		if (cell == nil) {
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:NoteCellIdentifier] autorelease];
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier] autorelease];
			
			icon = [[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 27.0, 27.0)] autorelease];
			icon.tag = kIconImageTag;
			//photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
			[cell.contentView addSubview:icon];
		} else {
			icon = (UIImageView *)[cell.contentView viewWithTag:kIconImageTag];
		}
		
	} else {
		// All Other Cell Setup
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
	}
    
	// Configure the cell.
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.section == 0) {	
		Group *group = [fetchedResultsController objectAtIndexPath:indexPath];
		/* Not possible to load a table view with a row selected so just ignore this for now
		if (selectedNote != nil && selectedNote.group != nil && [selectedNote.group.name compare:group.name] == NSOrderedSame) {

			//[cell setSelected:YES animated:YES];
			//cell.selected = YES;
			//cell.highlighted = YES;
		} */
		cell.textLabel.text = group.name;
		// TODO: If this is the root view, set the accessoryType to disclosure
	} else {
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = @"New Group";
		cell.imageView.image = [UIImage imageNamed:@"icon_group.png"];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected object to the new view controller.
    /// ...

	/*
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
	NSManagedObject *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	notesViewController.selectedGroup = group;
    [self.navigationController pushViewController:notesViewController animated:YES];
	[notesViewController release];
	*/
	if (indexPath.section == 0) {
		Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		if (selectedNote != nil) {
			// selected an existing group
			[self addToGroup:group withNote:selectedNote];
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			// show list of notes
			[self showAllNotesWithGroup:group];
		}
	} else {
		[self editTitle:nil];
	}

}

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Will Select");
	return indexPath;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		NSLog(@"Tapped");
	}
}
*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	if (indexPath.section == 0) {
		return YES;
	}
 	return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// For this view we don't want to indent the cells so return NO
	if (indexPath.section == 0) {
		return YES;
	}
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
	/* Set up the editing style */
	if (indexPath.section == 0) {
		style = UITableViewCellEditingStyleDelete;
	} 
    return style;
}


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

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		return 0;
	} else {
		return 0;
	}
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

	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
	[selectedNote release];
    [super dealloc];
}

@end


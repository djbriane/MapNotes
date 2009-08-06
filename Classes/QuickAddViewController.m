//
//  QuickAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Local Matters, Inc.. All rights reserved.
//

#import "QuickAddViewController.h"
#import "RootViewController.h"

@implementation QuickAddViewController

@synthesize mapView = _mapView;
@synthesize locationInfo;
@synthesize addNoteButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)addNote {
	/*
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}
	
	// Create and configure a new instance of the Event entity
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:managedObjectContext];
	
	CLLocationCoordinate2D coordinate = [location coordinate];
	
	[note setGeoLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	[note setGeoLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	[note setGeoAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
	
	[note setDateCreated:[NSDate date]];
	[note setTitle:@"New Note"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	 */
}

- (IBAction)newTextNote:(id)sender {
	// do something
	//[self addNote];
}


- (IBAction)viewNotes:(id)sender {
	// do something
	// Disclosure Button
	/*
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithStyle:UITableViewStylePlain];
	notesViewController.managedObjectContext = managedObjectContext;
	
	[self.navigationController pushViewController:notesViewController animated:YES];
	
	[notesViewController release];
	 */
}

- (void)dealloc {
	self.mapView = nil;
	[locationInfo release];
    [super dealloc];
}


@end

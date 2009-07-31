//
//  LaunchViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "NotesViewController.h"
#import "Note.h"

@implementation RootViewController

@synthesize managedObjectContext;
@synthesize mapView = _mapView;
@synthesize locationManager;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self updateCurrentLocation];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}



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

# pragma mark -
# pragma mark Custom Methods

- (void)updateCurrentLocation {
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.distanceFilter = 10.0f;
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[self.locationManager startUpdatingLocation];		
}
	

- (void)setCurrentLocation:(CLLocation *)location {
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.02f;
	region.span.latitudeDelta = 0.02f;
	
	[self.mapView setRegion:region animated:YES];
}

- (IBAction)updateLocation:(id)sender {
	[self updateCurrentLocation];
}

- (void)addNote {
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
}

- (IBAction)newTextNote:(id)sender {
	// do something
	[self addNote];
}


- (IBAction)viewNotes:(id)sender {
	// do something
	// Disclosure Button
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithStyle:UITableViewStylePlain];
	notesViewController.managedObjectContext = managedObjectContext;
	
	[self.navigationController pushViewController:notesViewController animated:YES];
	
	[notesViewController release];
}

# pragma mark -
#pragma mark CoreLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

	locationInfo.text = [NSString stringWithFormat:@"Accuracy: %4.2fm", newLocation.horizontalAccuracy];

	addNoteButton.enabled = YES;
	
	[self setCurrentLocation:newLocation];
	[self.locationManager stopUpdatingLocation];
}

/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    addNoteButton.enabled = NO;
	[self.locationManager stopUpdatingLocation];
}


- (void)dealloc {
	[managedObjectContext release];
	self.mapView = nil;
	[locationManager release];
	[locationInfo release];
    [super dealloc];
}


@end

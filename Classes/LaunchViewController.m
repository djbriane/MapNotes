//
//  LaunchViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LaunchViewController.h"
#import "MapNotesAppDelegate.h"
#import "NotesViewController.h"
#import "Note.h"

@implementation LaunchViewController

@synthesize managedObjectContext;
@synthesize mapView = _mapView;
@synthesize locationManager;
@synthesize locationInfo;


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
	
	self.navigationController.navigationBarHidden = YES;
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.distanceFilter = 10.0f;
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[self.locationManager startUpdatingLocation];	
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

- (void)setCurrentLocation:(CLLocation *)location {
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.15f;
	region.span.latitudeDelta = 0.15f;
	
	[self.mapView setRegion:region animated:YES];
}

- (void)addNote {
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}

	// Create and configure a new instance of the Event entity
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:managedObjectContext];

	//CLLocationCoordinate2D coordinate = [location coordinate];
	
	//[note setGeoLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	//[note setGeoLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	[note setDateCreated:[NSDate date]];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
}

- (IBAction)newTextNote:(id)sender {
	// do something
	[self addNote];
}


- (IBAction)viewNotes:(id)sender {
	// do something
	// Disclosure Button
	MapNotesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NotesViewController *notesViewController = [[NotesViewController alloc] initWithStyle:UITableViewStylePlain];
	notesViewController.managedObjectContext = delegate.managedObjectContext;
	
	[self.navigationController pushViewController:notesViewController animated:YES];
	
	[notesViewController release];
	[delegate release];
}

# pragma mark -
#pragma mark CoreLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

	locationInfo.text = [NSString stringWithFormat:@"%3.5f, %3.5f, %4.2f",
						 newLocation.coordinate.latitude,
						 newLocation.coordinate.longitude,
						 newLocation.horizontalAccuracy];

	[self setCurrentLocation:newLocation];
}


- (void)dealloc {
	[managedObjectContext release];
	self.mapView = nil;
	[locationManager release];
	[locationInfo release];
    [super dealloc];
}


@end

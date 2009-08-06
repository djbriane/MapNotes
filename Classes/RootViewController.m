//
//  LaunchViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "QuickAddViewController.h"
#import "NotesViewController.h"
#import "Note.h"

@implementation RootViewController

@synthesize managedObjectContext;
@synthesize locationManager;

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

	QuickAddViewController *quickAddViewController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddView" bundle:nil];
	//quickAddViewController.managedObjectContext = managedObjectContext;
	
	[self presentModalViewController:quickAddViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
	[self updateCurrentLocation];
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
	/*
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.02f;
	region.span.latitudeDelta = 0.02f;
	
	[self.mapView setRegion:region animated:YES];
	 */
}

- (IBAction)updateLocation:(id)sender {
	[self updateCurrentLocation];
}


# pragma mark -
#pragma mark CoreLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

	//locationInfo.text = [NSString stringWithFormat:@"Accuracy: %4.2fm", newLocation.horizontalAccuracy];

	//addNoteButton.enabled = YES;
	
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
    //addNoteButton.enabled = NO;
	[self.locationManager stopUpdatingLocation];
}


- (void)dealloc {
	[managedObjectContext release];
	[locationManager release];
    [super dealloc];
}


@end

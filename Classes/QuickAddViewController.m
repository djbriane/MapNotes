//
//  QuickAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Local Matters, Inc.. All rights reserved.
//

#import "QuickAddViewController.h"
#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "Note.h"

@implementation QuickAddViewController

@synthesize mapView = _mapView;
@synthesize locationManager, locationTimer, managedObjectContext;
@synthesize addTextNoteButton, addPhotoNoteButton, updateLocationButton, updateLocationActivity;
@synthesize locationInfoLabel;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Get a handle on the location manager from the app delegate
	self.locationManager = ((MapNotesAppDelegate *)[UIApplication sharedApplication].delegate).locationManager;
	self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self 
														selector:@selector(checkAndUpdateLocation) 
														userInfo:nil 
														 repeats:YES];
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

- (void)checkAndUpdateLocation {	
	// check if we have a good location
	if (nil != self.locationManager.location) {
		MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
		region.center = locationManager.location.coordinate;
		region.span.longitudeDelta = 0.02f;
		region.span.latitudeDelta = 0.02f;
		
		[self.mapView setRegion:region animated:NO];
		self.mapView.hidden = NO;
		
		// Update UI to reflect we have a good location
		[self.updateLocationActivity stopAnimating];
		self.updateLocationButton.enabled = YES;
		self.addTextNoteButton.enabled = YES;
		self.addPhotoNoteButton.enabled = YES;
		[self.locationTimer invalidate];
	} else {
		[self.updateLocationActivity startAnimating];
		self.updateLocationButton.enabled = NO;
		self.addTextNoteButton.enabled = NO;
		self.addPhotoNoteButton.enabled = NO;
	}
}

- (IBAction)addTextNote:(id)sender {
	if (!self.locationManager.location) {
		return;
	}
	
	// Create and configure a new instance of the Event entity
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:self.managedObjectContext];
	
	CLLocationCoordinate2D coordinate = [self.locationManager.location coordinate];
	
	[note setGeoLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	[note setGeoLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	[note setGeoAccuracy:[NSNumber numberWithDouble:self.locationManager.location.horizontalAccuracy]];
	
	[note setDateCreated:[NSDate date]];
	[note setTitle:@"New Note"];
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)addPhotoNote:(id)sender {

}

- (IBAction)viewNotes:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)updateLocation:(id)sender {
	[self.locationManager startUpdatingLocation];
}

- (void)dealloc {
	self.mapView = nil;
	[locationTimer release];
	[locationInfoLabel release];
	[locationManager release];
	[managedObjectContext release];
    [super dealloc];
}


@end

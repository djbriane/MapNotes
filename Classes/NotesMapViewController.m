//
//  NotesMapViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 9/3/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "NotesMapViewController.h"
#import "NoteAnnotation.h"
#import "Note.h"

@implementation NotesMapViewController

@synthesize mapView = _mapView;
@synthesize notesArray;

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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
	
	// initialize the map
	if(nil != self.notesArray) {
		for (Note *aNote in self.notesArray) {
			// create an annotation
			NoteAnnotation *aNoteAnnotation;
			aNoteAnnotation = [NoteAnnotation annotationWithNote:aNote];
			aNoteAnnotation.title = aNote.title;
			[self.mapView addAnnotation:aNoteAnnotation];
		}
	}
	if(self.mapView.annotations.count >= 1) {
		[self recenterMap];
	}
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

- (void)setCurrentLocation:(CLLocation *)location {
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.15f;
	region.span.latitudeDelta = 0.15f;
	[self.mapView setRegion:region animated:YES];
}

- (void)recenterMap {
	//NSArray *coordinates = [self.mapView valueForKeyPath:@"annotations.coordinate"];
	
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	for(Note *value in notesArray) {
		CLLocationCoordinate2D coord = {0.0f, 0.0f};
		//[value getValue:&coord];
		coord = value.location.coordinate;
		if(coord.longitude > maxCoord.longitude) {
			maxCoord.longitude = coord.longitude;
		}
		if(coord.latitude > maxCoord.latitude) {
			maxCoord.latitude = coord.latitude;
		}
		if(coord.longitude < minCoord.longitude) {
			minCoord.longitude = coord.longitude;
		}
		if(coord.latitude < minCoord.latitude) {
			minCoord.latitude = coord.latitude;
		}
	}
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
	region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
	CGFloat longDelta = maxCoord.longitude - minCoord.longitude;
	CGFloat latDelta = maxCoord.latitude - minCoord.latitude;
	
	// needed this logic in case only one point or all points in the same location
	if (longDelta != 0.0) {
		region.span.longitudeDelta = longDelta;
	} else {
		region.span.longitudeDelta = .005;
	}
	if (latDelta != 0.0) {
		region.span.latitudeDelta = latDelta;
	} else {
		region.span.latitudeDelta = .005;
	}

	[self.mapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *view = nil;
	if(annotation != mapView.userLocation) {
		view = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
		if(nil == view) {
			view = [[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"] autorelease];
			view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
		[view setPinColor:MKPinAnnotationColorRed];
		[view setCanShowCallout:YES];
		[view setAnimatesDrop:YES];
	} else {
		CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
		[self setCurrentLocation:location];
	}
	return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	// TODO: Show note detail view here
	/*
	NoteAnnotation *ann = (NoteAnnotation *)view.annotation;
	ABPersonViewController *personVC = [[[ABPersonViewController alloc] init] autorelease];
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:personVC] autorelease];
	
	personVC.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
																							   target:self
																							   action:@selector(stopEditingPerson)] autorelease];
	
	personVC.displayedPerson = ann.person;
	personVC.personViewDelegate = self;
	[self presentModalViewController:nav animated:YES];
	 */
}

- (void)dealloc {
	self.mapView = nil;
	self.notesArray = nil;
    [super dealloc];
}


@end

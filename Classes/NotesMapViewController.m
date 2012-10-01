//
//  NotesMapViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 9/3/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "NotesMapViewController.h"
#import "NoteDetailController.h"
#import "NoteAnnotation.h"
#import "Note.h"
#import "Group.h"

@implementation NotesMapViewController

@synthesize mapView = _mapView;
@synthesize notesArray;
@synthesize selectedGroup;

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

	if (selectedGroup != nil) {
		self.navigationItem.title = selectedGroup.name;
	} else {
		self.navigationItem.title = @"All Notes";
	}
	
	// add zoom controls
	// Create the sort control as a UISegmentedControl
	UIImage *zoomInIcon = [UIImage imageNamed:@"img_plus.png"];
	UIImage *zoomOutIcon = [UIImage imageNamed:@"img_minus.png"];

	UISegmentedControl *sortControl = [[UISegmentedControl alloc] initWithItems: 
									   [NSArray arrayWithObjects: zoomInIcon, zoomOutIcon, nil]];
	 
	sortControl.segmentedControlStyle = UISegmentedControlStyleBar;
	sortControl.tintColor = [UIColor colorWithRed:(129.0/255.0) green:(137.0/255.0) blue:(149.0/255.0) alpha:1.0];
	sortControl.momentary = YES;
	// default to date sort, should change this to remember sort preference
	//sortControl.selectedSegmentIndex = nil;
	 
	[sortControl addTarget:self action:@selector(zoomMap:) forControlEvents:UIControlEventValueChanged];
	 
	//sortControl.frame = CGRectMake(10, 6, 250,30);
	UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithCustomView:sortControl];

	self.navigationItem.rightBarButtonItem = zoomButton;
	[sortControl release];
	[zoomButton release];

}

- (void)zoomMap:(id)sender {
	MKCoordinateRegion region;
	MKCoordinateSpan span;  

	UISegmentedControl *segCtl = sender;
	NSInteger selectedIndex = [segCtl selectedSegmentIndex];
	
	switch (selectedIndex) {
		// Zoom In
		case 0: 
			//Set Zoom level using Span
			region.center = self.mapView.region.center;
			
			span.latitudeDelta = self.mapView.region.span.latitudeDelta /2.0002;
			span.longitudeDelta = self.mapView.region.span.longitudeDelta /2.0002;
			region.span = span;
			[self.mapView setRegion:region animated:TRUE];
			break;
			
		// Zoom Out     
        case 1: {
			//Set Zoom level using Span 
			region.center = self.mapView.region.center;
			span.latitudeDelta = self.mapView.region.span.latitudeDelta * 2;
			span.longitudeDelta = self.mapView.region.span.longitudeDelta * 2;
			region.span = span;
			[self.mapView setRegion:region animated:TRUE];
        }
	}	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];

	// initialize the map
	if(nil != self.notesArray && self.mapView.annotations.count == 0) {
		for (Note *aNote in self.notesArray) {
			// create an annotation
			NoteAnnotation *aNoteAnnotation;
			aNoteAnnotation = [NoteAnnotation annotationWithNote:aNote];
			if ([aNote.title length] != 0) {
				aNoteAnnotation.title = aNote.title;
			} else if ([aNote.details length] != 0) {
				aNoteAnnotation.title = aNote.details;
			} else {
				static NSDateFormatter *dateFormatter = nil;
				if (dateFormatter == nil) {
					dateFormatter = [[NSDateFormatter alloc] init];
					[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
					[dateFormatter setDateStyle:NSDateFormatterShortStyle];
				}
				aNoteAnnotation.title = [dateFormatter stringFromDate:[aNote dateCreated]];
			}
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
	// Added 0.05f to give it some padding
	CGFloat longDelta = maxCoord.longitude - minCoord.longitude + 0.005f;
	CGFloat latDelta = maxCoord.latitude - minCoord.latitude + 0.005f;
	
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
	MKAnnotationView *view = nil;
	if(annotation != mapView.userLocation) {
		view = (MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
		
		if(nil == view) {
			view = [[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"] autorelease];
			view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}	

		// add the note thumbnail to the flyout
		NoteAnnotation *noteAnnotation = (NoteAnnotation *)annotation;
		if (noteAnnotation.note.thumbnail != nil) {
			UIImageView *photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)] autorelease];
			view.leftCalloutAccessoryView = photoView;
			photoView.image = noteAnnotation.note.thumbnail;
		}

		if (noteAnnotation.note.group != nil) {
			[view setImage:[noteAnnotation.note.group getPinImage]];	
		} else {
			[view setImage:[UIImage imageNamed:@"node_orange.png"]];
		}
		CGPoint offsetPixels;
		offsetPixels.x = 0;
		offsetPixels.y = -16;
		view.centerOffset = offsetPixels;
		
		[view setCanShowCallout:YES];
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
	NoteAnnotation *ann = (NoteAnnotation *)view.annotation;

	NoteDetailController *noteDetailController = [[NoteDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	noteDetailController.view.backgroundColor = [UIColor clearColor];
	noteDetailController.selectedNote = ann.note;
    [self.navigationController pushViewController:noteDetailController animated:YES];
	[noteDetailController release];
}

- (void)dealloc {
	self.mapView = nil;
	self.notesArray = nil;
	[selectedGroup release];
    [super dealloc];
}


@end

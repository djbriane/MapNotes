//
//  LaunchViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 ocal Matters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
	NSManagedObjectContext *managedObjectContext;

	MKMapView *_mapView;
	CLLocationManager *locationManager;
	IBOutlet UILabel *locationInfo;
	IBOutlet UIButton *addNoteButton;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UILabel *locationInfo;
@property (nonatomic, retain) IBOutlet UIButton *addNoteButton;


- (void)updateCurrentLocation;
- (void)setCurrentLocation:(CLLocation *)location;
- (IBAction)updateLocation:(id)sender;

- (void)addNote;
- (IBAction)newTextNote:(id)sender;
- (IBAction)viewNotes:(id)sender;

@end

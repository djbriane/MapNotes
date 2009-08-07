//
//  QuickAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface QuickAddViewController : UIViewController <MKMapViewDelegate> {
	NSManagedObjectContext *managedObjectContext;
	MKMapView *_mapView;
	CLLocationManager *locationManager;
	NSTimer *locationTimer;
	
	IBOutlet UILabel *locationInfoLabel;
	IBOutlet UIButton *addTextNoteButton;
	IBOutlet UIButton *addPhotoNoteButton;
	IBOutlet UIButton *updateLocationButton;
	IBOutlet UIActivityIndicatorView *updateLocationActivity;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSTimer *locationTimer;

@property (nonatomic, retain) IBOutlet UILabel *locationInfoLabel;
@property (nonatomic, retain) IBOutlet UIButton *addTextNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *addPhotoNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *updateLocationButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *updateLocationActivity;

- (void)checkAndUpdateLocation;

- (IBAction)addPhotoNote:(id)sender;
- (IBAction)addTextNote:(id)sender;
- (IBAction)viewNotes:(id)sender;
- (IBAction)updateLocation:(id)sender;

@end

//@protocol MapNotesAppDelegate <NSObject>

//@optional

//- (void)quickAddViewController:(QuickAddViewController *)controller viewNotes;
//- (void)quickAddViewController:(QuickAddViewController *)controller newTextNote;
//- (void)quickAddViewController:(QuickAddViewController *)controller newPhotoNote;

//@end
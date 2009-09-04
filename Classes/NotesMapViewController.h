//
//  NotesMapViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 9/3/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class NoteAnnotation;

@interface NotesMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	MKMapView *_mapView;
	NSMutableArray *notesArray;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSMutableArray *notesArray;

- (void)setCurrentLocation:(CLLocation *)location;
- (void)recenterMap;

@end

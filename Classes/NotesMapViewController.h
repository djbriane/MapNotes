//
//  NotesMapViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 9/3/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Group;
@class NoteAnnotation;

@interface NotesMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	MKMapView *_mapView;
	NSMutableArray *notesArray;
	Group *selectedGroup;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *notesArray;
@property (nonatomic, retain) Group *selectedGroup;

- (void)setCurrentLocation:(CLLocation *)location;
- (void)recenterMap;

@end

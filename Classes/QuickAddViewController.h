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
	
	IBOutlet UILabel *locationInfo;
	IBOutlet UIButton *addNoteButton;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UILabel *locationInfo;
@property (nonatomic, retain) IBOutlet UIButton *addNoteButton;

- (void)addNote;
/*
- (IBAction)photoNoteButton:(id)sender;
- (IBAction)textNoteButton:(id)sender;
- (IBAction)viewNotesButton:(id)sender;
*/ 

@end

//@protocol MapNotesAppDelegate <NSObject>

//@optional

//- (void)quickAddViewController:(QuickAddViewController *)controller viewNotes;
//- (void)quickAddViewController:(QuickAddViewController *)controller newTextNote;
//- (void)quickAddViewController:(QuickAddViewController *)controller newPhotoNote;

//@end
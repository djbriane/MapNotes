//
//  QuickAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#define kTakePhotoButtonText	@"Take Photo"
#define kChoosePhotoButtonText	@"Choose Existing Photo"
#define kDeletePhotoButtonText	@"Delete Photo"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NoteTitleViewController.h"
#import "NoteDescViewController.h"

@class NoteTitleViewController;

@class Note;
@class Group;

@protocol QuickAddViewControllerDelegate;

@interface QuickAddViewController : UIViewController <MKMapViewDelegate, NoteDescDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	id<QuickAddViewControllerDelegate> delegate;
	
	NSManagedObjectContext *managedObjectContext;
	MKMapView *_mapView;
	NSTimer *locationTimer;
	Group *selectedGroup;
	
	IBOutlet UILabel *locationInfoLabel;
	IBOutlet UIButton *addTextNoteButton;
	IBOutlet UIButton *addPhotoNoteButton;
	IBOutlet UIButton *viewNotesButton;
	IBOutlet UIButton *updateLocationButton;
	IBOutlet UIActivityIndicatorView *updateLocationActivity;
}

@property (nonatomic, assign) id<QuickAddViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSTimer *locationTimer;
@property (nonatomic, retain) Group *selectedGroup;

@property (nonatomic, retain) IBOutlet UIButton *addTextNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *addPhotoNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *viewNotesButton;
@property (nonatomic, retain) IBOutlet UIButton *updateLocationButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *updateLocationActivity;

- (void)checkAndUpdateLocation;
- (void)startUpdatingLocation;
- (Note *)createNewNote;

- (IBAction)addPhotoNote:(id)sender;
- (IBAction)addTextNote:(id)sender;
- (IBAction)viewNotes:(id)sender;
- (IBAction)updateLocation:(id)sender;

@end

@protocol QuickAddViewControllerDelegate <NSObject>

@optional

- (void)quickAddViewController:(QuickAddViewController *)controller showNewNote:(Note *)note;

@end